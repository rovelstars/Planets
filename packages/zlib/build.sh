#!/bin/bash
# Build script for zlib (RunixOS cross-compilation)

configure() {
    cd "$SRC"
    if [ ! -d "zlib" ]; then
        git clone "$REPOSITORY" --branch "v$VERSION" --depth 1 zlib
    fi

    mkdir -p zlib-build && cd zlib-build

    # zlib's configure tests shared-library support by linking a tiny stub
    # against zlib's full --version-script. lld defaults to --no-undefined-version
    # (a hard error) where GNU ld only warns, so the stub fails and configure
    # falls back to building libz.a only. --undefined-version restores the lenient
    # behavior; it is a no-op for the real libz.so (all symbols defined).
    CC="$SYSROOT/Core/Bin/clang --target=x86_64-rovelstars-linux-runixos --sysroot=$SYSROOT" \
    CFLAGS="-Wno-incompatible-pointer-types -Wl,--undefined-version -Wno-unused-command-line-argument" \
    ../zlib/configure \
        --prefix=/Core \
        --libdir=/Core/LibKit \
        --includedir=/Core/APIHeader

    # Use RunixOS .rdl SONAMEs instead of stock libz.so so the library does not
    # collide with the host's libz.so when a host build tool (e.g. cargo) has
    # /Core/LibKit on its RUNPATH. zlib's configure has no knob for this, so
    # rewrite the generated Makefile: libz.so -> libz.rdl throughout (SHAREDLIB,
    # the soname, and the install symlinks).
    sed -i 's/libz\.so/libz.rdl/g' Makefile
}

build() {
    cd "$SRC/zlib-build"
    make -j"$JOBS"
}

install() {
    cd "$SRC/zlib-build"
    # zlib's configure has no --mandir; its Makefile defaults man3 to
    # $prefix/share/man. Override so the man page lands in the RunixOS layout
    # (StoreRoom) instead of a stock /Core/share.
    make install DESTDIR="$OUTPUT" mandir=/Core/StoreRoom/Manual
}
