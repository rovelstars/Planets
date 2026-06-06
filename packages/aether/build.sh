#!/bin/bash
# Build Aether (aetherd daemon + aether CLI) for RunixOS, cross-built with the
# sysroot Rust toolchain. libc-only, no C deps.

TARGET=x86_64-rovelstars-linux-runixos

configure() {
    cd "$SRC"
    if [ -n "$LOCAL_SRC" ]; then
        rm -rf aether
        ln -sfn "$LOCAL_SRC" aether
    elif [ ! -d "aether" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-main}" --depth 1 aether
    fi
}

build() {
    cd "$SRC/aether"
    export CARGO_TARGET_X86_64_ROVELSTARS_LINUX_RUNIXOS_LINKER="$SYSROOT/Core/Bin/clang"
    export CARGO_TARGET_X86_64_ROVELSTARS_LINUX_RUNIXOS_RUSTFLAGS="-C link-arg=--target=x86_64-rovelstars-linux-runixos -C link-arg=--sysroot=$SYSROOT -C link-arg=-fuse-ld=lld"
    export CC_x86_64_rovelstars_linux_runixos="$SYSROOT/Core/Bin/clang"
    cargo build --release --target "$TARGET" -p aetherd -p aether -j"$JOBS"
}

install() {
    cd "$SRC/aether"
    mkdir -p "$OUTPUT/Core/Bin"
    cp "target/$TARGET/release/aetherd" "$OUTPUT/Core/Bin/"
    cp "target/$TARGET/release/aether" "$OUTPUT/Core/Bin/"
}
