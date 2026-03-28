#!/bin/bash
# Build script for expat (RunixOS cross-compilation)

configure() {
    cd "$SRC"
    if [ ! -d "libexpat" ]; then
        git clone "$REPOSITORY" --branch "R_${VERSION//./_}" --depth 1 libexpat
    fi

    mkdir -p expat-build && cd expat-build

    cmake ../libexpat/expat -G Ninja \
        -DCMAKE_SYSTEM_NAME=RunixOS \
        -DCMAKE_C_COMPILER="$SYSROOT/Core/Bin/clang" \
        -DCMAKE_C_FLAGS="--target=x86_64-rovelstars-runixos --sysroot=$SYSROOT -Wno-incompatible-pointer-types" \
        -DCMAKE_INSTALL_PREFIX=/Core \
        -DCMAKE_INSTALL_LIBDIR=LibKit \
        -DCMAKE_INSTALL_INCLUDEDIR=APIHeader \
        -DEXPAT_BUILD_EXAMPLES=OFF \
        -DEXPAT_BUILD_TESTS=OFF \
        -DEXPAT_BUILD_TOOLS=OFF \
        -DCMAKE_BUILD_TYPE=Release
}

build() {
    cd "$SRC/expat-build"
    ninja -j"$JOBS"
}

install() {
    cd "$SRC/expat-build"
    DESTDIR="$OUTPUT" ninja install
}
