#!/bin/bash
# Build script for brush shell (RunixOS)
# Uses our fork with all RunixOS dependencies pre-patched.

TARGET_ARGS=""
if [ -n "$RUNIXOS_TARGET" ]; then
    TARGET_ARGS="--target $RUNIXOS_TARGET"
    export RUSTC="$RUNIXOS_RUSTC"
    export CARGO_TARGET_X86_64_ROVELSTARS_RUNIXOS_RUSTFLAGS="-L $RUNIXOS_STD_DEPS -L $SYSROOT/Core/LibKit -C link-arg=-fuse-ld=lld -C link-arg=--sysroot=$SYSROOT -C link-arg=--target=x86_64-rovelstars-runixos"
fi

configure() {
    cd "$SRC"
    if [ ! -d "brush" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-runixos}" --depth 1 brush
    fi
    cd brush

    # Apply patches
    if [ -d "$PATCHES" ]; then
        for p in "$PATCHES"/*.patch "$PATCHES"/*.diff; do
            [ -f "$p" ] && git apply "$p" 2>/dev/null || patch -p1 < "$p" 2>/dev/null || true
        done
    fi
}

build() {
    cd "$SRC/brush"
    cargo build --release $TARGET_ARGS -p brush-shell -j"$JOBS"
}

install() {
    cd "$SRC/brush"
    mkdir -p "$OUTPUT/Core/Bin"
    if [ -n "$RUNIXOS_TARGET" ]; then
        cp target/$RUNIXOS_TARGET/release/brush "$OUTPUT/Core/Bin/"
    else
        cp target/release/brush "$OUTPUT/Core/Bin/"
    fi
    # Create sh symlink for POSIX compatibility
    ln -sf brush "$OUTPUT/Core/Bin/sh"
}
