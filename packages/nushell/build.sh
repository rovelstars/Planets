#!/bin/bash
# Build script for nushell (RunixOS)

configure() {
    cd "$SRC"
    if [ ! -d "nushell" ]; then
        git clone "$REPOSITORY" --branch "$VERSION" --depth 1 nushell
    fi
    cd nushell

    # Apply uname patch if enabled
    if [ "$CUSTOM_UNAME_O" = "true" ] && [ -f "$PATCHES/uname_o.diff" ]; then
        patch -p0 < "$PATCHES/uname_o.diff" || true
    fi
}

build() {
    cd "$SRC/nushell"
    cargo build --release -j"$JOBS"
}

install() {
    cd "$SRC/nushell"
    cargo install --path . --root "$OUTPUT/Core"
    # Clean cargo metadata
    rm -rf "$OUTPUT/Core/.crates"*
}
