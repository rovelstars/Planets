#!/bin/bash
# Build script for findutils (Rust) (RunixOS)
# Uses our fork with all RunixOS dependencies pre-patched.

TARGET_ARGS=""
if [ -n "$RUNIXOS_TARGET" ]; then
    TARGET_ARGS="--target $RUNIXOS_TARGET"
    export RUSTC="$RUNIXOS_RUSTC"
    export CARGO_TARGET_X86_64_ROVELSTARS_RUNIXOS_RUSTFLAGS="-L $RUNIXOS_STD_DEPS -L $SYSROOT/Core/LibKit -C link-arg=-fuse-ld=lld -C link-arg=--sysroot=$SYSROOT -C link-arg=--target=x86_64-rovelstars-runixos"
fi

configure() {
    cd "$SRC"
    if [ ! -d "findutils" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-main}" --depth 1 findutils
    fi
}

build() {
    cd "$SRC/findutils"
    cargo build --release $TARGET_ARGS -j"$JOBS"
}

install() {
    cd "$SRC/findutils"
    mkdir -p "$OUTPUT/Core/Bin"
    if [ -n "$RUNIXOS_TARGET" ]; then
        cp target/$RUNIXOS_TARGET/release/find "$OUTPUT/Core/Bin/" 2>/dev/null
        cp target/$RUNIXOS_TARGET/release/xargs "$OUTPUT/Core/Bin/" 2>/dev/null
    else
        cp target/release/find "$OUTPUT/Core/Bin/" 2>/dev/null
        cp target/release/xargs "$OUTPUT/Core/Bin/" 2>/dev/null
    fi
}
