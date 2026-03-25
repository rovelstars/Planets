#!/bin/bash
# Build script for Linux kernel (RunixOS)

configure() {
    cd "$SRC"
    if [ ! -d "linux-$VERSION" ]; then
        wget -q "https://cdn.kernel.org/pub/linux/kernel/v${VERSION%%.*}.x/linux-${VERSION}.tar.xz" -O linux.tar.xz
        tar xf linux.tar.xz
        rm linux.tar.xz
    fi
    cd "linux-$VERSION"

    # Set RunixOS local version
    echo "-runixos" > localversion

    # Apply patches
    if [ -d "$PATCHES" ]; then
        for p in "$PATCHES"/*.patch "$PATCHES"/*.diff; do
            [ -f "$p" ] && patch -p1 < "$p"
        done
    fi

    make defconfig
    # Merge custom config if present
    if [ -f "$PATCHES/kconfig" ]; then
        scripts/kconfig/merge_config.sh -m .config "$PATCHES/kconfig"
    fi
    make olddefconfig
}

build() {
    cd "$SRC/linux-$VERSION"
    make bzImage modules -j"$JOBS"
}

install() {
    cd "$SRC/linux-$VERSION"
    make install INSTALL_PATH="$OUTPUT/Core/Startup"
    make modules_install INSTALL_MOD_PATH="$OUTPUT/Core/LibKit"

    # Install kernel headers to Core/APIHeader
    local hdrtmp="$OUTPUT/.hdrtmp"
    make headers_install INSTALL_HDR_PATH="$hdrtmp"
    for d in linux asm asm-generic; do
        rm -rf "$OUTPUT/Core/APIHeader/$d"
        mv "$hdrtmp/include/$d" "$OUTPUT/Core/APIHeader/$d" 2>/dev/null || true
    done
    rm -rf "$hdrtmp"
}
