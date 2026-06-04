#!/bin/bash
# Build script for glibc (RunixOS)

configure() {
    cd "$SRC"
    # $LOCAL_SRC (set by `rocket build glibc --local ../glibc`) builds the local
    # working tree instead of cloning upstream.
    if [ -n "$LOCAL_SRC" ]; then
        ln -sfn "$LOCAL_SRC" glibc
    elif [ ! -d "glibc" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-glibc-$VERSION}" --depth 1 glibc
    fi

    # Cross-compile to RunixOS with our clang. glibc reads CC/AR/RANLIB from the
    # environment, and Rocket's plain $CC has no --target, so set it here.
    export CC="$SYSROOT/Core/Bin/clang --target=x86_64-rovelstars-linux-runixos --sysroot=$SYSROOT"
    export AR="$SYSROOT/Core/Bin/llvm-ar"
    export RANLIB="$SYSROOT/Core/Bin/llvm-ranlib"
    # Point CXX at the cross compiler (targeting RunixOS), not the host one
    # Rocket injects. There is no C++ stdlib for the target yet (libc++ is a
    # post-glibc runtime), so glibc's C++ link test fails and it disables the
    # C++ test helpers. If CXX is left unset, configure finds the host g++,
    # decides C++ works, then fails building the target helper with -lstdc++.
    export CXX="$SYSROOT/Core/Bin/clang++ --target=x86_64-rovelstars-linux-runixos --sysroot=$SYSROOT"

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
        --host=x86_64-rovelstars-linux-runixos \
        --build=$(gcc -dumpmachine) \
        --with-headers="$SYSROOT/Core/APIHeader" \
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
