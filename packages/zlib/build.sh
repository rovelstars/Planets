#!/bin/bash
# Build script for zlib (RunixOS cross-compilation)

configure() {
    cd "$SRC"
    if [ ! -d "zlib" ]; then
        git clone "$REPOSITORY" --branch "v$VERSION" --depth 1 zlib
    fi

    mkdir -p zlib-build && cd zlib-build

    CC="$SYSROOT/Core/Bin/clang --target=x86_64-rovelstars-runixos --sysroot=$SYSROOT" \
    CFLAGS="-Wno-incompatible-pointer-types" \
    ../zlib/configure \
        --prefix=/Core \
        --libdir=/Core/LibKit \
        --includedir=/Core/APIHeader
}

build() {
    cd "$SRC/zlib-build"
    make -j"$JOBS"
}

install() {
    cd "$SRC/zlib-build"
    make install DESTDIR="$OUTPUT"
}
