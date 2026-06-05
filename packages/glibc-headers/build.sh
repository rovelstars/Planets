#!/bin/bash
# Bootstrap glibc headers. This breaks the libc <-> compiler-rt cycle: compiler-rt
# builtins need libc headers, full glibc needs the compiler-rt CRT to link. So we
# install just the headers (plus a stub gnu/stubs.h) first, build compiler-rt
# against them, then build full glibc. Same source + configure as the glibc
# package; only the install step differs (install-headers, not install).

configure() {
    cd "$SRC"
    if [ -n "$LOCAL_SRC" ]; then
        ln -sfn "$LOCAL_SRC" glibc
    elif [ ! -d "glibc" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-master}" --depth 1 glibc
    fi

    export CC="$SYSROOT/Core/Bin/clang --target=x86_64-rovelstars-linux-runixos --sysroot=$SYSROOT"
    export CXX="$SYSROOT/Core/Bin/clang++ --target=x86_64-rovelstars-linux-runixos --sysroot=$SYSROOT"
    export AR="$SYSROOT/Core/Bin/llvm-ar"
    export RANLIB="$SYSROOT/Core/Bin/llvm-ranlib"

    mkdir -p glibc-build && cd glibc-build
    ../glibc/configure \
        --prefix=/Core \
        --libdir=/Core/LibKit \
        --includedir=/Core/APIHeader \
        --host=x86_64-rovelstars-linux-runixos \
        --build="$(gcc -dumpmachine)" \
        --with-headers="$SYSROOT/Core/APIHeader" \
        --enable-shared --enable-static \
        --disable-werror --disable-nscd --disable-timezone-tools \
        libc_cv_slibdir=/Core/LibKit \
        libc_cv_rtlddir=/Core/LibKit
}

build() {
    : # headers only
}

install() {
    cd "$SRC/glibc-build"
    make install-bootstrap-headers=yes install-headers DESTDIR="$OUTPUT"
    # compiler-rt's configure probe includes a few headers that only exist after
    # a full build; a stub stubs.h is enough to get builtins compiling.
    mkdir -p "$OUTPUT/Core/APIHeader/gnu"
    touch "$OUTPUT/Core/APIHeader/gnu/stubs.h"
}
