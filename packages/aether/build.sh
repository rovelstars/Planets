#!/bin/bash
# Build Aether (aetherd daemon + aether CLI) for RunixOS, cross-built with the
# sysroot Rust toolchain. libc-only, no C deps.

TARGET=x86_64-rovelstars-linux-runixos
# Keep cargo target in this per-sysroot build dir (not the symlinked, host-global
# source fork), so a different sysroot rustc never reuses stale .rlibs.
export CARGO_TARGET_DIR="$SRC/target"

configure() {
    cd "$SRC"
    if [ -n "$LOCAL_SRC" ]; then
        rm -rf aether
        ln -sfn "$LOCAL_SRC" aether
    elif [ ! -d "aether" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-main}" --depth 1 aether
    fi
}

build() {
    cd "$SRC/aether"
    export CARGO_TARGET_X86_64_ROVELSTARS_LINUX_RUNIXOS_LINKER="$SYSROOT/Core/Bin/clang"
    export CARGO_TARGET_X86_64_ROVELSTARS_LINUX_RUNIXOS_RUSTFLAGS="-C link-arg=--target=x86_64-rovelstars-linux-runixos -C link-arg=--sysroot=$SYSROOT -C link-arg=-fuse-ld=lld"
    export CC_x86_64_rovelstars_linux_runixos="$SYSROOT/Core/Bin/clang"
    cargo build --release --target "$TARGET" -p aetherd -p aetherctl -j"$JOBS"
}

install() {
    cd "$SRC/aether"
    mkdir -p "$OUTPUT/Core/Bin" "$OUTPUT/Core/Services"
    cp "$CARGO_TARGET_DIR/$TARGET/release/aetherd" "$OUTPUT/Core/Bin/"
    cp "$CARGO_TARGET_DIR/$TARGET/release/aetherctl" "$OUTPUT/Core/Bin/"
    # Rev service: start aetherd at boot and keep it running.
    cat > "$OUTPUT/Core/Services/rovelstars.aether.rsc" <<'RSC'
name = "com.rovelstars.aether/daemon"
description = "Aether network manager (wired/Wi-Fi/Bluetooth, DHCP, DNS)"
exec-start = "/Core/Bin/aetherd"
restart-policy = "always"
RSC
}
