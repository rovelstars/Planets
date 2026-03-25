#!/bin/bash
# Build script for nushell (RunixOS)
# Uses our fork with all RunixOS dependencies pre-patched.

TARGET_ARGS=""
if [ -n "$RUNIXOS_TARGET" ]; then
    TARGET_ARGS="--target $RUNIXOS_TARGET"
    export RUSTC="$RUNIXOS_RUSTC"
    export CARGO_TARGET_X86_64_ROVELSTARS_RUNIXOS_RUSTFLAGS="-L $RUNIXOS_STD_DEPS -L $SYSROOT/Core/LibKit -C link-arg=-fuse-ld=lld -C link-arg=--sysroot=$SYSROOT -C link-arg=--target=x86_64-rovelstars-runixos"
fi

configure() {
    cd "$SRC"
    if [ ! -d "nushell" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-runixos}" --depth 1 nushell
    fi
    cd nushell

    # Apply uname patch if enabled
    if [ "$CUSTOM_UNAME_O" = "true" ] && [ -f "$PATCHES/uname_o.diff" ]; then
        patch -p0 < "$PATCHES/uname_o.diff" || true
    fi
}

build() {
    cd "$SRC/nushell"
    cargo build --release $TARGET_ARGS -j"$JOBS"
}

install() {
    cd "$SRC/nushell"
    mkdir -p "$OUTPUT/Core/Bin"
    if [ -n "$RUNIXOS_TARGET" ]; then
        cp target/$RUNIXOS_TARGET/release/nu "$OUTPUT/Core/Bin/"
    else
        cargo install --path . --root "$OUTPUT/Core"
        # Clean cargo metadata
        rm -rf "$OUTPUT/Core/.crates"*
        # cargo installs to Core/bin (lowercase) -- move to Core/Bin
        if [ -d "$OUTPUT/Core/bin" ] && [ ! -d "$OUTPUT/Core/Bin" ]; then
            mv "$OUTPUT/Core/bin" "$OUTPUT/Core/Bin"
        fi
    fi
}
