#!/bin/bash
# Build script for findutils (Rust) (RunixOS), cross-built with the sysroot Rust
# toolchain.

TARGET=x86_64-rovelstars-linux-runixos
# Keep cargo target in this per-sysroot build dir (not the symlinked, host-global
# source fork), so a different sysroot rustc never reuses stale .rlibs.
export CARGO_TARGET_DIR="$SRC/target"

configure() {
    cd "$SRC"
    if [ -n "$LOCAL_SRC" ]; then
        rm -rf findutils
        ln -sfn "$LOCAL_SRC" findutils
    elif [ ! -d "findutils" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-main}" --depth 1 findutils
    fi
}

build() {
    cd "$SRC/findutils"
    export CARGO_TARGET_X86_64_ROVELSTARS_LINUX_RUNIXOS_LINKER="$SYSROOT/Core/Bin/clang"
    export CARGO_TARGET_X86_64_ROVELSTARS_LINUX_RUNIXOS_RUSTFLAGS="-C link-arg=--target=x86_64-rovelstars-linux-runixos -C link-arg=--sysroot=$SYSROOT -C link-arg=-fuse-ld=lld"
    export CC_x86_64_rovelstars_linux_runixos="$SYSROOT/Core/Bin/clang"
    export CFLAGS_x86_64_rovelstars_linux_runixos="--target=$TARGET --sysroot=$SYSROOT"
    cargo build --release --target "$TARGET" -j"$JOBS"
}

install() {
    cd "$SRC/findutils"
    mkdir -p "$OUTPUT/Core/Bin"
    cp "$CARGO_TARGET_DIR/$TARGET/release/find" "$OUTPUT/Core/Bin/" 2>/dev/null
    cp "$CARGO_TARGET_DIR/$TARGET/release/xargs" "$OUTPUT/Core/Bin/" 2>/dev/null
}
