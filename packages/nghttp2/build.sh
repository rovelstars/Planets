#!/bin/bash
# Build script for nghttp2 (RunixOS cross-compilation)

configure() {
    cd "$SRC"
    if [ ! -d "nghttp2" ]; then
        git clone "$REPOSITORY" --branch "v$VERSION" --depth 1 nghttp2
    fi

    mkdir -p nghttp2-build && cd nghttp2-build

    cmake ../nghttp2 -G Ninja \
        -DCMAKE_SYSTEM_NAME=RunixOS \
        -DCMAKE_C_COMPILER="$SYSROOT/Core/Bin/clang" \
        -DCMAKE_C_FLAGS="--target=x86_64-rovelstars-runixos --sysroot=$SYSROOT -Wno-incompatible-pointer-types" \
        -DCMAKE_INSTALL_PREFIX=/Core \
        -DCMAKE_INSTALL_LIBDIR=LibKit \
        -DCMAKE_INSTALL_INCLUDEDIR=APIHeader \
        -DENABLE_LIB_ONLY=ON \
        -DENABLE_STATIC_LIB=ON \
        -DCMAKE_PREFIX_PATH="$SYSROOT/Core" \
        -DCMAKE_BUILD_TYPE=Release
}

build() {
    cd "$SRC/nghttp2-build"
    ninja -j"$JOBS"
}

install() {
    cd "$SRC/nghttp2-build"
    DESTDIR="$OUTPUT" ninja install
}
