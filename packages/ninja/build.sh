#!/bin/bash
# Build script for Ninja (RunixOS native, cross-compiled via the cmake RunixOS
# platform). C++ program; the RovelStars clang driver defaults to libc++ for the
# runixos target, so no -stdlib flag is needed. The host ninja (generator) drives
# the build; the produced ninja is a native RunixOS ELF.

configure() {
    cd "$SRC"
    if [ ! -d "ninja" ]; then
        git clone "$REPOSITORY" --branch "v$VERSION" --depth 1 ninja
    fi

    mkdir -p ninja-build && cd ninja-build

    cmake ../ninja -G Ninja \
        -DCMAKE_SYSTEM_NAME=RunixOS \
        -DCMAKE_CXX_COMPILER="$SYSROOT/Core/Bin/clang++" \
        -DCMAKE_CXX_FLAGS="--target=x86_64-rovelstars-linux-runixos --sysroot=$SYSROOT" \
        -DCMAKE_INSTALL_PREFIX=/Core \
        -DCMAKE_INSTALL_BINDIR=Bin \
        -DCMAKE_FIND_ROOT_PATH="$SYSROOT/Core" \
        -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
        -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
        -DBUILD_TESTING=OFF \
        -DCMAKE_BUILD_TYPE=Release
}

build() {
    cd "$SRC/ninja-build"
    ninja -j"$JOBS"
}

install() {
    cd "$SRC/ninja-build"
    DESTDIR="$OUTPUT" ninja install
}
