#!/bin/bash
# Native (cross-compiled) build for a GNU autotools tool. Uses the same template
# as make: cross clang targeting runixos so the binary is a native RunixOS ELF,
# autotools --host x86_64-rovelstars-linux-gnu (config.sub accepts gnu; RunixOS
# is glibc/Linux ABI), RunixOS install layout (CONFIG_SITE supplies man/info/etc).

configure() {
    cd "$SRC"
    if [ ! -d "$NAME-$VERSION" ]; then
        curl -L "$REPOSITORY/$NAME-$VERSION.tar.xz" -o "$NAME.tar.xz"
        tar xf "$NAME.tar.xz"
    fi
    cd "$NAME-$VERSION"

    CC="$SYSROOT/Core/Bin/clang --target=x86_64-rovelstars-linux-runixos --sysroot=$SYSROOT" \
    ./configure \
        --build=x86_64-pc-linux-gnu \
        --host=x86_64-rovelstars-linux-gnu \
        --prefix=/Core \
        --bindir=/Core/Bin \
        --libdir=/Core/LibKit \
        --includedir=/Core/APIHeader \
        --disable-nls
}

build() {
    cd "$SRC/$NAME-$VERSION"
    make -j"$JOBS"
}

install() {
    cd "$SRC/$NAME-$VERSION"
    make install DESTDIR="$OUTPUT"
}
