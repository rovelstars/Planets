#!/bin/bash
# Rust toolchain built to RUN on RunixOS (self-hosting). Unlike the `rust`
# package - a host-runnable rustc that cross-builds std for runixos - this sets
# the bootstrap HOST to the runixos triple, so rustc + cargo themselves come out
# as native RunixOS ELFs (and rust's bundled LLVM is built for the runixos host).
#
# Bootstrap flow: stage0 is the downloaded beta rustc for the build machine
# (x86_64-unknown-linux-gnu); x.py then builds stage1/stage2 hosted on runixos
# using our clang/lld/llvm-ar as the runixos target tools. As elsewhere, the
# native-build-in-chroot property lets any runixos host tool x.py builds (e.g.
# llvm-tblgen) execute in the chroot.

configure() {
    export PATH=/Core/Bin:/usr/bin:/bin
    unset LD_LIBRARY_PATH

    cd "$SRC"
    if [ -n "$LOCAL_SRC" ]; then
        ln -sfn "$LOCAL_SRC" rust
    elif [ ! -d "rust" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-master}" --depth 1 rust
    fi

    cd rust

    # rust's bundled-LLVM build injects `-isystem /usr/include` (host C headers)
    # into our clang invocation, which precedes the sysroot libc++/C headers and
    # breaks libc++'s #include_next ordering (<cmath>/<cstdlib>/<cerrno> errors).
    # Wrap cc/cxx to prepend the sysroot include dirs so they win over /usr/include
    # (and force --sysroot=/). C++ gets libc++'s c++/v1 first; C does NOT (libc++
    # ships <stdio.h>-style wrappers that would hijack a C compile).
    cat > "$SRC/ccwrap" <<'WRAP'
#!/bin/sh
exec /Core/Bin/clang --sysroot=/ -isystem /Core/APIHeader "$@"
WRAP
    cat > "$SRC/cxxwrap" <<'WRAP'
#!/bin/sh
exec /Core/Bin/clang++ --sysroot=/ -isystem /Core/APIHeader/c++/v1 -isystem /Core/APIHeader "$@"
WRAP
    chmod +x "$SRC/ccwrap" "$SRC/cxxwrap"

    cat > config.toml <<CFG
change-id = "ignore"
[build]
build = "x86_64-unknown-linux-gnu"
host = ["x86_64-rovelstars-linux-runixos"]
target = ["x86_64-rovelstars-linux-runixos"]
extended = true
tools = ["cargo"]
docs = false
[llvm]
download-ci-llvm = false
[install]
prefix = "$OUTPUT/Core"
bindir = "Bin"
libdir = "LibKit"
sysconfdir = "Config"
datadir = "StoreRoom"
mandir = "StoreRoom/Manual"
docdir = "StoreRoom/Docs"
[rust]
channel = "nightly"
[target.x86_64-unknown-linux-gnu]
cc = "/usr/bin/cc"
cxx = "/usr/bin/c++"
[target.x86_64-rovelstars-linux-runixos]
# Link the external native LLVM 21 (llvm21 package) instead of building rust's
# bundled LLVM - sidesteps the bundled-build issues entirely. llvm-config is a
# runixos ELF that runs in the chroot.
llvm-config = "/Core/llvm21/bin/llvm-config"
cc = "$SRC/ccwrap"
cxx = "$SRC/cxxwrap"
linker = "$SYSROOT/Core/Bin/clang"
ar = "$SYSROOT/Core/Bin/llvm-ar"
ranlib = "$SYSROOT/Core/Bin/llvm-ranlib"
CFG
}

build() {
    export PATH=/Core/Bin:/usr/bin:/bin
    unset LD_LIBRARY_PATH
    # cargo (built for the runixos host) links openssl via openssl-sys. Point it
    # at the sysroot openssl and link STATICALLY (libssl.a/libcrypto.a exist),
    # sidestepping the .rdl-vs-.so soname mismatch. Target-scoped env so the host
    # build tools (x86_64-unknown-linux-gnu) still use the host openssl.
    export X86_64_ROVELSTARS_LINUX_RUNIXOS_OPENSSL_LIB_DIR=/Core/LibKit
    export X86_64_ROVELSTARS_LINUX_RUNIXOS_OPENSSL_INCLUDE_DIR=/Core/APIHeader
    export X86_64_ROVELSTARS_LINUX_RUNIXOS_OPENSSL_STATIC=1
    cd "$SRC/rust"
    python3 x.py build --stage 2
}

install() {
    export PATH=/Core/Bin:/usr/bin:/bin
    unset LD_LIBRARY_PATH
    export X86_64_ROVELSTARS_LINUX_RUNIXOS_OPENSSL_LIB_DIR=/Core/LibKit
    export X86_64_ROVELSTARS_LINUX_RUNIXOS_OPENSSL_INCLUDE_DIR=/Core/APIHeader
    export X86_64_ROVELSTARS_LINUX_RUNIXOS_OPENSSL_STATIC=1
    cd "$SRC/rust"
    python3 x.py install
}
