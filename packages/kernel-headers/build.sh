#!/bin/bash
# Linux kernel UAPI headers. glibc needs these (--with-headers), so this is the
# first real dependency in the toolchain after cmake. Headers only, no kernel
# compile: 'make headers_install' just runs unifdef + copies, using host tools.

configure() {
    cd "$SRC"
    if [ ! -d linux ]; then
        maj="${VERSION%%.*}"
        tarball="linux-${VERSION}.tar.xz"
        if [ ! -f "$tarball" ]; then
            curl -fL -o "$tarball" "$REPOSITORY/v${maj}.x/${tarball}"
        fi
        tar xf "$tarball"
        ln -sfn "linux-${VERSION}" linux
    fi
}

build() {
    : # headers only, nothing to compile
}

install() {
    cd "$SRC/linux"
    # headers_install drops the tree under <path>/include; the RunixOS layout
    # wants linux/, asm/, asm-generic/ etc directly under Core/APIHeader.
    make ARCH=x86 INSTALL_HDR_PATH="$OUTPUT/Core/APIHeader" headers_install
    if [ -d "$OUTPUT/Core/APIHeader/include" ]; then
        cp -a "$OUTPUT/Core/APIHeader/include/." "$OUTPUT/Core/APIHeader/"
        rm -rf "$OUTPUT/Core/APIHeader/include"
    fi
}
