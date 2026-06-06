#!/bin/bash
# Build script for the brush shell (RunixOS), cross-built with the sysroot Rust
# toolchain (the rust package installs cargo + rustc + std into Core/Bin and the
# rustlib for x86_64-rovelstars-linux-runixos).

TARGET=x86_64-rovelstars-linux-runixos

configure() {
    cd "$SRC"
    if [ -n "$LOCAL_SRC" ]; then
        # Drop any stale clone first; ln -sfn would otherwise create the symlink
        # inside an existing brush/ directory rather than replacing it.
        rm -rf brush
        ln -sfn "$LOCAL_SRC" brush
    elif [ ! -d "brush" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-runixos}" --depth 1 brush
    fi
    cd brush
    if [ -d "$PATCHES" ]; then
        for p in "$PATCHES"/*.patch "$PATCHES"/*.diff; do
            [ -f "$p" ] && { git apply "$p" 2>/dev/null || patch -p1 < "$p" 2>/dev/null || true; }
        done
    fi
    return 0
}

build() {
    cd "$SRC/brush"
    export CARGO_TARGET_X86_64_ROVELSTARS_LINUX_RUNIXOS_LINKER="$SYSROOT/Core/Bin/clang"
    export CARGO_TARGET_X86_64_ROVELSTARS_LINUX_RUNIXOS_RUSTFLAGS="-C link-arg=--target=x86_64-rovelstars-linux-runixos -C link-arg=--sysroot=$SYSROOT -C link-arg=-fuse-ld=lld"
    export CC_x86_64_rovelstars_linux_runixos="$SYSROOT/Core/Bin/clang"
    export CFLAGS_x86_64_rovelstars_linux_runixos="--target=$TARGET --sysroot=$SYSROOT"
    cargo build --release --target "$TARGET" -p brush-shell -j"$JOBS"
}

install() {
    cd "$SRC/brush"
    mkdir -p "$OUTPUT/Core/Bin"
    cp "target/$TARGET/release/brush" "$OUTPUT/Core/Bin/"
    ln -sf brush "$OUTPUT/Core/Bin/sh"
}
