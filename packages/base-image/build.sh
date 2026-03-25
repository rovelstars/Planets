#!/bin/bash
# Build script for RunixOS minimal dev environment base image.
#
# This assembles a rootfs from a pre-built sysroot ($SYSROOT).
# It copies the essential files needed for Rocket's sandbox root mode
# and for building other packages.
#
# Expected: $SYSROOT points to a fully built RunixOS sysroot (e.g., /home/user/ROS)

configure() {
    if [ -z "$SYSROOT" ] || [ ! -d "$SYSROOT/Core" ]; then
        echo "Error: SYSROOT must point to a built RunixOS sysroot"
        echo "  e.g., SYSROOT=/home/ren/ROS rocket build base-image"
        exit 1
    fi
    echo "Building base image from sysroot: $SYSROOT"
}

build() {
    # Nothing to compile — this is an assembly step
    true
}

install() {
    local ROOT="$OUTPUT"

    # Create RunixOS directory structure
    mkdir -p "$ROOT/Core/Bin"
    mkdir -p "$ROOT/Core/LibKit"
    mkdir -p "$ROOT/Core/APIHeader"
    mkdir -p "$ROOT/Core/StoreRoom"
    mkdir -p "$ROOT/Core/Config"
    mkdir -p "$ROOT/Core/Startup"
    mkdir -p "$ROOT/Construct/Bin"
    mkdir -p "$ROOT/Construct/LibKit"
    mkdir -p "$ROOT/Construct/APIHeader"
    mkdir -p "$ROOT/Construct/Config"
    mkdir -p "$ROOT/Vault/Chronicle"
    mkdir -p "$ROOT/Vault/Cache"
    mkdir -p "$ROOT/Vault/State"
    mkdir -p "$ROOT/Transit/Ephemeral"
    mkdir -p "$ROOT/Transit/Volatile"
    mkdir -p "$ROOT/Space"
    mkdir -p "$ROOT/dev"
    mkdir -p "$ROOT/proc"
    mkdir -p "$ROOT/sys"

    echo ">>> Copying toolchain (clang, lld, cmake)"
    # Binaries
    for bin in clang clang++ clang-23 ld.lld lld llvm-ar llvm-ranlib \
               llvm-objcopy llvm-objdump llvm-strip llvm-readelf llvm-nm \
               llvm-config cmake ctest cpack ninja; do
        [ -f "$SYSROOT/Core/Bin/$bin" ] && cp -a "$SYSROOT/Core/Bin/$bin" "$ROOT/Core/Bin/"
    done
    # Symlinks
    for link in clang-cl clang-cpp cc c++; do
        [ -L "$SYSROOT/Core/Bin/$link" ] && cp -a "$SYSROOT/Core/Bin/$link" "$ROOT/Core/Bin/"
    done

    echo ">>> Copying libraries"
    # glibc shared libs
    cp -a "$SYSROOT/Core/LibKit"/libc.rdl* "$ROOT/Core/LibKit/" 2>/dev/null
    cp -a "$SYSROOT/Core/LibKit"/libm.rdl* "$ROOT/Core/LibKit/" 2>/dev/null
    cp -a "$SYSROOT/Core/LibKit"/libdl.rdl* "$ROOT/Core/LibKit/" 2>/dev/null
    cp -a "$SYSROOT/Core/LibKit"/libpthread.rdl* "$ROOT/Core/LibKit/" 2>/dev/null
    cp -a "$SYSROOT/Core/LibKit"/librt.rdl* "$ROOT/Core/LibKit/" 2>/dev/null
    cp -a "$SYSROOT/Core/LibKit"/libresolv.rdl* "$ROOT/Core/LibKit/" 2>/dev/null
    cp -a "$SYSROOT/Core/LibKit"/libutil.rdl* "$ROOT/Core/LibKit/" 2>/dev/null
    # Dynamic linker
    cp -a "$SYSROOT/Core/LibKit"/ld-runixos-* "$ROOT/Core/LibKit/"
    # glibc static libs + crt objects
    cp -a "$SYSROOT/Core/LibKit"/libc.ral "$ROOT/Core/LibKit/" 2>/dev/null
    cp -a "$SYSROOT/Core/LibKit"/libc_nonshared.ral "$ROOT/Core/LibKit/" 2>/dev/null
    cp -a "$SYSROOT/Core/LibKit"/libm.ral "$ROOT/Core/LibKit/" 2>/dev/null
    cp -a "$SYSROOT/Core/LibKit"/crt*.o "$ROOT/Core/LibKit/" 2>/dev/null
    cp -a "$SYSROOT/Core/LibKit"/Scrt*.o "$ROOT/Core/LibKit/" 2>/dev/null
    # libc++ / libunwind
    cp -a "$SYSROOT/Core/LibKit"/libc++* "$ROOT/Core/LibKit/" 2>/dev/null
    cp -a "$SYSROOT/Core/LibKit"/libunwind* "$ROOT/Core/LibKit/" 2>/dev/null
    # compiler-rt
    cp -a "$SYSROOT/Core/LibKit/clang" "$ROOT/Core/LibKit/" 2>/dev/null
    # cmake modules
    cp -a "$SYSROOT/Core/LibKit/cmake" "$ROOT/Core/LibKit/" 2>/dev/null

    echo ">>> Copying headers"
    cp -a "$SYSROOT/Core/APIHeader"/* "$ROOT/Core/APIHeader/" 2>/dev/null

    echo ">>> Copying config"
    cp -a "$SYSROOT/Core/Config"/* "$ROOT/Core/Config/" 2>/dev/null

    echo ">>> Copying cmake data"
    cp -a "$SYSROOT/Core/StoreRoom"/cmake-* "$ROOT/Core/StoreRoom/" 2>/dev/null

    echo ">>> Creating libc.rdl linker script"
    # Ensure libc.rdl linker script references .ral
    if [ -f "$SYSROOT/Core/LibKit/libc.rdl" ] && file "$SYSROOT/Core/LibKit/libc.rdl" | grep -q text; then
        cp "$SYSROOT/Core/LibKit/libc.rdl" "$ROOT/Core/LibKit/libc.rdl"
    fi

    echo ">>> Copying userland utilities from Rocket output"
    # ROCKET_OUTPUT is the host directory where Rocket stores per-package outputs
    for pkg in brush findutils coreutils nushell; do
        pkg_bin="$ROCKET_OUTPUT/$pkg/Core/Bin"
        if [ -d "$pkg_bin" ]; then
            cp -a "$pkg_bin"/* "$ROOT/Core/Bin/" 2>/dev/null
            echo "    $pkg installed"
        fi
    done

    echo ">>> Base image assembled at $ROOT"
    echo "    Directories: $(find "$ROOT" -type d | wc -l)"
    echo "    Files: $(find "$ROOT" -type f | wc -l)"
    echo "    Size: $(du -sh "$ROOT" | cut -f1)"
}
