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
}
