#!/bin/bash
# GNU Bison, native cross-compiled (same autotools template as the GNU tools).
# Parser generator needed by glibc's build. Uses native m4 at runtime.

configure() {
    cd "$SRC"
    if [ ! -d "bison-$VERSION" ]; then
        curl -L "$REPOSITORY/bison-$VERSION.tar.xz" -o bison.tar.xz
        tar --no-same-owner -xf bison.tar.xz
    fi
    cd "bison-$VERSION"

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
    cd "$SRC/bison-$VERSION"
    make -j"$JOBS"
}

install() {
    cd "$SRC/bison-$VERSION"
    make install DESTDIR="$OUTPUT"
}
