#!/bin/bash
# Native (cross-compiled) build for XZ Utils. Same autotools cross template as
# the GNU tools (cross clang targeting runixos, --host x86_64-rovelstars-linux-gnu).
# Source is the pre-generated release tarball (has ./configure already).

configure() {
    cd "$SRC"
    if [ ! -d "xz-$VERSION" ]; then
        curl -L "$REPOSITORY/releases/download/v$VERSION/xz-$VERSION.tar.xz" -o xz.tar.xz
        tar xf xz.tar.xz
    fi
    cd "xz-$VERSION"

    CC="$SYSROOT/Core/Bin/clang --target=x86_64-rovelstars-linux-runixos --sysroot=$SYSROOT" \
    ./configure \
        --build=x86_64-pc-linux-gnu \
        --host=x86_64-rovelstars-linux-gnu \
        --prefix=/Core \
        --bindir=/Core/Bin \
        --libdir=/Core/LibKit \
        --includedir=/Core/APIHeader \
        --disable-nls \
        --disable-static
}

build() {
    cd "$SRC/xz-$VERSION"
    make -j"$JOBS"
}

install() {
    cd "$SRC/xz-$VERSION"
    make install DESTDIR="$OUTPUT"
}
