#!/bin/bash
# patchelf - native RunixOS build tool (soname/rpath/interpreter surgery used by
# openssl and others). C++ autotools cross build (release tarball has configure).

configure() {
    cd "$SRC"
    if [ ! -d "patchelf-$VERSION" ]; then
        curl -L "$REPOSITORY/releases/download/$VERSION/patchelf-$VERSION.tar.bz2" -o patchelf.tar.bz2
        tar --no-same-owner -xf patchelf.tar.bz2
    fi
    cd "patchelf-$VERSION"

    CXX="$SYSROOT/Core/Bin/clang++ --target=x86_64-rovelstars-linux-runixos --sysroot=$SYSROOT" \
    ./configure \
        --build=x86_64-pc-linux-gnu \
        --host=x86_64-rovelstars-linux-gnu \
        --prefix=/Core \
        --bindir=/Core/Bin \
        --mandir=/Core/StoreRoom/Manual
}

build() {
    cd "$SRC/patchelf-$VERSION"
    make -j"$JOBS"
}

install() {
    cd "$SRC/patchelf-$VERSION"
    make install DESTDIR="$OUTPUT"
}
