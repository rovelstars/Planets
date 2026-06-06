#!/bin/bash
# Build script for the helix editor (RunixOS), cross-built with the sysroot Rust
# toolchain.

TARGET=x86_64-rovelstars-linux-runixos

configure() {
    cd "$SRC"
    if [ -n "$LOCAL_SRC" ]; then
        rm -rf helix
        ln -sfn "$LOCAL_SRC" helix
    elif [ ! -d "helix" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-runixos}" --depth 1 helix
    fi
}

build() {
    cd "$SRC/helix"
    export CARGO_TARGET_X86_64_ROVELSTARS_LINUX_RUNIXOS_LINKER="$SYSROOT/Core/Bin/clang"
    export CARGO_TARGET_X86_64_ROVELSTARS_LINUX_RUNIXOS_RUSTFLAGS="-C link-arg=--target=x86_64-rovelstars-linux-runixos -C link-arg=--sysroot=$SYSROOT -C link-arg=-fuse-ld=lld --cfg getrandom_backend=\"linux_getrandom\""
    export CC_x86_64_rovelstars_linux_runixos="$SYSROOT/Core/Bin/clang"
    export CFLAGS_x86_64_rovelstars_linux_runixos="--target=$TARGET --sysroot=$SYSROOT -Wno-incompatible-pointer-types"
    # Tree-sitter grammars are built natively on RunixOS later, not cross-built.
    HELIX_DISABLE_AUTO_GRAMMAR_BUILD=1 cargo build --release --target "$TARGET" -j"$JOBS"
}

install() {
    cd "$SRC/helix"
    local bin_dir="$OUTPUT/Core/Bin"
    local runtime_dir="$OUTPUT/Core/StoreRoom/helix/runtime"
    mkdir -p "$bin_dir" "$runtime_dir"
    cp "target/$TARGET/release/hx" "$bin_dir/"
    cp -r runtime/* "$runtime_dir/"
}
