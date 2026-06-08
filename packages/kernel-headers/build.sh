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
    # Use 'make headers' (generates the unifdef'd UAPI tree in usr/include) then
    # cp, instead of 'headers_install' which finishes with an rsync the native
    # rsync segfaults on in-chroot. HOSTCC=clang: the headers step builds the tiny
    # fixdep/unifdef host helpers; default cc/gcc is absent self-hosted (all-LLVM).
    make ARCH=x86 HOSTCC="$SYSROOT/Core/Bin/clang" headers
    mkdir -p "$OUTPUT/Core/APIHeader"
    # usr/include holds linux/, asm/, asm-generic/ etc - the RunixOS layout wants
    # them directly under Core/APIHeader. Copy only headers (drop .install stamps).
    cp -a usr/include/. "$OUTPUT/Core/APIHeader/"
    find "$OUTPUT/Core/APIHeader" -name '.*.cmd' -o -name '.install' -delete 2>/dev/null || true
}
