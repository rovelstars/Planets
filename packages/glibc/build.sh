#!/bin/bash
# Build script for glibc (RunixOS)

configure() {
    cd "$SRC"
    if [ ! -d "glibc" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-glibc-$VERSION}" --depth 1 glibc
    fi

    # glibc must be built out-of-tree
    mkdir -p glibc-build && cd glibc-build

    ../glibc/configure \
        --prefix=/Core \
        --bindir=/Core/Bin \
        --sbindir=/Core/Bin \
        --libdir=/Core/LibKit \
        --libexecdir=/Core/LibKit \
        --includedir=/Core/APIHeader \
        --datarootdir=/Core/StoreRoom \
        --sysconfdir=/Core/Config \
        --localstatedir=/Vault/State \
        --host=x86_64-rovelstars-runixos \
        --build=$(gcc -dumpmachine) \
        --with-headers=/Core/APIHeader \
        --enable-shared \
        --enable-static \
        --disable-werror \
        --disable-nscd \
        --disable-timezone-tools \
        libc_cv_slibdir=/Core/LibKit \
        libc_cv_rtlddir=/Core/LibKit
}

build() {
    cd "$SRC/glibc-build"
    make -j"$JOBS"
}

install() {
    cd "$SRC/glibc-build"
    make install DESTDIR="$OUTPUT"
}
