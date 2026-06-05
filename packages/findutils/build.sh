#!/bin/bash
# Build script for findutils (Rust) (RunixOS), cross-built with the sysroot Rust
# toolchain.

TARGET=x86_64-rovelstars-linux-runixos

configure() {
    cd "$SRC"
    if [ -n "$LOCAL_SRC" ]; then
        ln -sfn "$LOCAL_SRC" findutils
    elif [ ! -d "findutils" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-main}" --depth 1 findutils
    fi
}

build() {
    cd "$SRC/findutils"
    export CARGO_TARGET_X86_64_ROVELSTARS_LINUX_RUNIXOS_LINKER="$SYSROOT/Core/Bin/clang"
    export CARGO_TARGET_X86_64_ROVELSTARS_LINUX_RUNIXOS_RUSTFLAGS="-C link-arg=--sysroot=$SYSROOT -C link-arg=-fuse-ld=lld"
    export CC_x86_64_rovelstars_linux_runixos="$SYSROOT/Core/Bin/clang"
    export CFLAGS_x86_64_rovelstars_linux_runixos="--target=$TARGET --sysroot=$SYSROOT"
    cargo build --release --target "$TARGET" -j"$JOBS"
}

install() {
    cd "$SRC/findutils"
    mkdir -p "$OUTPUT/Core/Bin"
    cp "target/$TARGET/release/find" "$OUTPUT/Core/Bin/" 2>/dev/null
    cp "target/$TARGET/release/xargs" "$OUTPUT/Core/Bin/" 2>/dev/null
}
