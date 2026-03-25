#!/bin/bash
# Build script for brush shell (RunixOS)

configure() {
    cd "$SRC"
    if [ ! -d "brush" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-brush-shell-v$VERSION}" --depth 1 brush
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
    # Allow warnings — upstream sometimes has unused imports with newer Rust
    RUSTFLAGS="--cap-lints warn" cargo build --release -p brush-shell -j"$JOBS"
}

install() {
    cd "$SRC/brush"
    RUSTFLAGS="--cap-lints warn" cargo install --path brush-shell --root "$OUTPUT/Core"
    rm -rf "$OUTPUT/Core/.crates"*
    # cargo installs to Core/bin (lowercase) — move to Core/Bin
    if [ -d "$OUTPUT/Core/bin" ] && [ ! -d "$OUTPUT/Core/Bin" ]; then
        mv "$OUTPUT/Core/bin" "$OUTPUT/Core/Bin"
    fi
    # Create sh symlink for POSIX compatibility
    ln -sf brush "$OUTPUT/Core/Bin/sh"
}
