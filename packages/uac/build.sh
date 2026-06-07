#!/bin/bash
# Build UAC (userctl + elevate) for RunixOS, cross-built with the sysroot Rust
# toolchain. Pure-Rust crypto, so no C deps / cc-rs fork needed.

TARGET=x86_64-rovelstars-linux-runixos
# Keep cargo target in this per-sysroot build dir (not the symlinked, host-global
# source fork), so a different sysroot rustc never reuses stale .rlibs.
export CARGO_TARGET_DIR="$SRC/target"

configure() {
    cd "$SRC"
    if [ -n "$LOCAL_SRC" ]; then
        rm -rf uac
        ln -sfn "$LOCAL_SRC" uac
    elif [ ! -d "uac" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-main}" --depth 1 uac
    fi
}

build() {
    cd "$SRC/uac"
    export CARGO_TARGET_X86_64_ROVELSTARS_LINUX_RUNIXOS_LINKER="$SYSROOT/Core/Bin/clang"
    export CARGO_TARGET_X86_64_ROVELSTARS_LINUX_RUNIXOS_RUSTFLAGS="-C link-arg=--target=x86_64-rovelstars-linux-runixos -C link-arg=--sysroot=$SYSROOT -C link-arg=-fuse-ld=lld"
    export CC_x86_64_rovelstars_linux_runixos="$SYSROOT/Core/Bin/clang"
    cargo build --release --target "$TARGET" -p userctl -p elevate -p oobe -p nss-runix -j"$JOBS"
}

install() {
    cd "$SRC/uac"
    mkdir -p "$OUTPUT/Core/Bin" "$OUTPUT/Core/LibKit"
    cp "$CARGO_TARGET_DIR/$TARGET/release/userctl" "$OUTPUT/Core/Bin/"
    cp "$CARGO_TARGET_DIR/$TARGET/release/elevate" "$OUTPUT/Core/Bin/"
    cp "$CARGO_TARGET_DIR/$TARGET/release/oobe" "$OUTPUT/Core/Bin/"
    # elevate must be setuid-root to drop from the caller to the target user.
    # Ownership is set to root at image assembly; the setuid bit is set here.
    chmod 4755 "$OUTPUT/Core/Bin/elevate"
    # NSS module: our glibc fork dlopens libnss_runix.rdl.2 (RunixOS .rdl suffix).
    cp "$CARGO_TARGET_DIR/$TARGET/release/libnss_runix.rdl" "$OUTPUT/Core/LibKit/libnss_runix.rdl.2"
}
