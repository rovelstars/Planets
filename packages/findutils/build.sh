#!/bin/bash
# Build script for findutils (Rust) (RunixOS)

configure() {
    cd "$SRC"
    if [ ! -d "findutils" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-$VERSION}" --depth 1 findutils
    fi
}

build() {
    cd "$SRC/findutils"
    cargo build --release --locked -j"$JOBS"
}

install() {
    cd "$SRC/findutils"
    cargo install --locked --path . --root "$OUTPUT/Core"
    rm -rf "$OUTPUT/Core/.crates"*
    # cargo installs to Core/bin (lowercase) — move to Core/Bin
    if [ -d "$OUTPUT/Core/bin" ] && [ ! -d "$OUTPUT/Core/Bin" ]; then
        mv "$OUTPUT/Core/bin" "$OUTPUT/Core/Bin"
    fi
}
