#!/bin/bash
# Build script for brush shell (RunixOS)

configure() {
    cd "$SRC"
    if [ ! -d "brush" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-brush-shell-v$VERSION}" --depth 1 brush
    fi
}

build() {
    cd "$SRC/brush"
    cargo build --release --locked -p brush-shell -j"$JOBS"
}

install() {
    cd "$SRC/brush"
    cargo install --locked --path brush-shell --root "$OUTPUT/Core"
    rm -rf "$OUTPUT/Core/.crates"*
}
