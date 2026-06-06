#!/bin/bash
# Build Rev (PID 1 init + service manager + WireBus) for RunixOS, cross-built
# with the sysroot Rust toolchain.

TARGET=x86_64-rovelstars-linux-runixos

configure() {
    cd "$SRC"
    if [ -n "$LOCAL_SRC" ]; then
        rm -rf rev
        ln -sfn "$LOCAL_SRC" rev
    elif [ ! -d "rev" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-main}" --depth 1 rev
    fi
}

build() {
    cd "$SRC/rev"
    export CARGO_TARGET_X86_64_ROVELSTARS_LINUX_RUNIXOS_LINKER="$SYSROOT/Core/Bin/clang"
    export CARGO_TARGET_X86_64_ROVELSTARS_LINUX_RUNIXOS_RUSTFLAGS="-C link-arg=--target=x86_64-rovelstars-linux-runixos -C link-arg=--sysroot=$SYSROOT -C link-arg=-fuse-ld=lld"
    export CC_x86_64_rovelstars_linux_runixos="$SYSROOT/Core/Bin/clang"
    cargo build --release --target "$TARGET" --bin rev -j"$JOBS"
}

install() {
    cd "$SRC/rev"
    mkdir -p "$OUTPUT/Core/Bin" "$OUTPUT/Core/Services"
    cp "target/$TARGET/release/rev" "$OUTPUT/Core/Bin/rev"
}
