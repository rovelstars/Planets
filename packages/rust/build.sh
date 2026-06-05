#!/bin/bash
# Rust toolchain for RunixOS. Builds the host rustc + cargo and cross-builds std
# for x86_64-rovelstars-linux-runixos, installing both into the sysroot so the
# Rust packages (coreutils, brush, ...) can `cargo build --target ...` against it.
#
# Like the llvm package, x.py builds its own host tools, so pin the host
# toolchain (PATH=/usr/bin) and unset LD_LIBRARY_PATH; the RunixOS target's cc /
# linker are our clang, referenced by absolute path in config.toml.

configure() {
    export PATH=/usr/bin:/bin
    unset LD_LIBRARY_PATH

    cd "$SRC"
    if [ -n "$LOCAL_SRC" ]; then
        ln -sfn "$LOCAL_SRC" rust
    elif [ ! -d "rust" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-master}" --depth 1 rust
    fi

    cd rust
    # Install into the sysroot FHS: rustc/cargo (host binaries) -> Core/Bin,
    # libraries + the target std (rustlib) -> Core/LibKit.
    cat > config.toml <<CFG
[build]
host = ["x86_64-unknown-linux-gnu"]
target = ["x86_64-unknown-linux-gnu", "x86_64-rovelstars-linux-runixos"]
extended = true
tools = ["cargo"]
[install]
prefix = "$OUTPUT/Core"
bindir = "Bin"
libdir = "LibKit"
sysconfdir = "Config"
[rust]
channel = "nightly"
[target.x86_64-unknown-linux-gnu]
cc = "/usr/bin/cc"
cxx = "/usr/bin/c++"
[target.x86_64-rovelstars-linux-runixos]
cc = "$SYSROOT/Core/Bin/clang"
cxx = "$SYSROOT/Core/Bin/clang++"
linker = "$SYSROOT/Core/Bin/clang"
ar = "$SYSROOT/Core/Bin/llvm-ar"
ranlib = "$SYSROOT/Core/Bin/llvm-ranlib"
CFG
}

build() {
    export PATH=/usr/bin:/bin
    unset LD_LIBRARY_PATH
    cd "$SRC/rust"
    python3 x.py build --stage 2
}

install() {
    export PATH=/usr/bin:/bin
    unset LD_LIBRARY_PATH
    cd "$SRC/rust"
    python3 x.py install
}
