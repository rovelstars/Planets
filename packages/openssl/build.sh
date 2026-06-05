#!/bin/bash
# Build script for OpenSSL (RunixOS cross-compilation)

configure() {
    cd "$SRC"
    if [ ! -d "openssl" ]; then
        git clone "$REPOSITORY" --branch "openssl-$VERSION" --depth 1 openssl
    fi

    cd openssl

    # OpenSSL's Configure has no --includedir option (headers are hardcoded to
    # $prefix/include) and silently forwards any unrecognized --flag to the
    # compiler, so passing one leaks into CFLAGS and breaks the build. Install
    # headers under the default Core/include and relocate them to the RunixOS
    # Core/APIHeader in install().
    CC="$SYSROOT/Core/Bin/clang --target=x86_64-rovelstars-linux-runixos --sysroot=$SYSROOT" \
    CFLAGS="-Wno-incompatible-pointer-types" \
    ./Configure linux-x86_64 \
        --prefix=/Core \
        --libdir=LibKit \
        --openssldir=/Core/Config/ssl \
        shared
}

build() {
    cd "$SRC/openssl"
    make -j"$JOBS"
}

install() {
    cd "$SRC/openssl"
    make install_sw install_ssldirs DESTDIR="$OUTPUT"

    # Move headers to the RunixOS Core/APIHeader convention and repoint the
    # pkg-config files so consumers resolve the include path correctly.
    if [ -d "$OUTPUT/Core/include" ]; then
        mkdir -p "$OUTPUT/Core/APIHeader"
        cp -a "$OUTPUT/Core/include/." "$OUTPUT/Core/APIHeader/"
        rm -rf "$OUTPUT/Core/include"
    fi
    for pc in "$OUTPUT/Core/LibKit/pkgconfig"/*.pc; do
        [ -f "$pc" ] && sed -i 's|/include$|/APIHeader|; s|/include}|/APIHeader}|' "$pc"
    done

    # Rename the shared libraries to RunixOS .rdl SONAMEs. OpenSSL's build
    # hardcodes libssl.so.3/libcrypto.so.3, which collide with the host's
    # libssl/libcrypto when a host build tool (e.g. cargo) has /Core/LibKit on
    # its RUNPATH, causing it to load the RunixOS libs (and pull in libc.rdl.6)
    # into a host process. .rdl makes the RunixOS libraries distinct, matching
    # glibc/curl/nghttp2. Rewrite the SONAMEs, the libssl->libcrypto reference,
    # every provider/engine module, the openssl app, and the dev symlinks.
    local lk="$OUTPUT/Core/LibKit"
    if [ -f "$lk/libcrypto.so.3" ]; then
        patchelf --set-soname libcrypto.rdl.3 "$lk/libcrypto.so.3"
        patchelf --set-soname libssl.rdl.3 "$lk/libssl.so.3"
        patchelf --replace-needed libcrypto.so.3 libcrypto.rdl.3 "$lk/libssl.so.3"
        for m in "$lk"/ossl-modules/*.so "$lk"/engines-3/*.so; do
            [ -f "$m" ] && patchelf --replace-needed libcrypto.so.3 libcrypto.rdl.3 "$m"
        done
        if [ -f "$OUTPUT/Core/Bin/openssl" ]; then
            patchelf --replace-needed libssl.so.3 libssl.rdl.3 "$OUTPUT/Core/Bin/openssl"
            patchelf --replace-needed libcrypto.so.3 libcrypto.rdl.3 "$OUTPUT/Core/Bin/openssl"
        fi
        mv "$lk/libcrypto.so.3" "$lk/libcrypto.rdl.3"
        mv "$lk/libssl.so.3" "$lk/libssl.rdl.3"
        rm -f "$lk/libcrypto.so" "$lk/libssl.so"
        ln -sf libcrypto.rdl.3 "$lk/libcrypto.rdl"
        ln -sf libssl.rdl.3 "$lk/libssl.rdl"
    fi
}
