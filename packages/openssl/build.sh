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
}
