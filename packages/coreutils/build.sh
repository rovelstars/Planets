#!/bin/bash
# Build script for coreutils (Rust-based)

configure() {
    cd "$SRC"
    if [ ! -d "coreutils" ]; then
        git clone "$REPOSITORY" --branch "$VERSION" --depth 1 coreutils
    fi
    cd coreutils

    # Apply patches
    if [ "$CUSTOM_UNAME_O" = "true" ] && [ -f "$PATCHES/uname_o.diff" ]; then
        patch -p0 < "$PATCHES/uname_o.diff" || true
    fi
}

build() {
    cd "$SRC/coreutils"
    make PROFILE=release -j"$JOBS"
}

install() {
    cd "$SRC/coreutils"
    make PREFIX="$OUTPUT" install
}
