#!/bin/bash
# Build script for nushell (RunixOS), cross-built with the sysroot Rust toolchain.

TARGET=x86_64-rovelstars-linux-runixos

configure() {
    cd "$SRC"
    if [ -n "$LOCAL_SRC" ]; then
        rm -rf nushell
        ln -sfn "$LOCAL_SRC" nushell
    elif [ ! -d "nushell" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-runixos}" --depth 1 nushell
    fi
    cd nushell
}

build() {
    cd "$SRC/nushell"
    export CARGO_TARGET_X86_64_ROVELSTARS_LINUX_RUNIXOS_LINKER="$SYSROOT/Core/Bin/clang"
    export CARGO_TARGET_X86_64_ROVELSTARS_LINUX_RUNIXOS_RUSTFLAGS="-C link-arg=--sysroot=$SYSROOT -C link-arg=-fuse-ld=lld"
    export CC_x86_64_rovelstars_linux_runixos="$SYSROOT/Core/Bin/clang"
    export CFLAGS_x86_64_rovelstars_linux_runixos="--target=$TARGET --sysroot=$SYSROOT"
    cargo build --release --target "$TARGET" -j"$JOBS"
}

install() {
    cd "$SRC/nushell"
    mkdir -p "$OUTPUT/Core/Bin"
    cp "target/$TARGET/release/nu" "$OUTPUT/Core/Bin/"
}
