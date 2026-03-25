#!/bin/bash
# Build script for coreutils (Rust-based) (RunixOS)
# Uses our fork with all RunixOS dependencies pre-patched.

TARGET_ARGS=""
if [ -n "$RUNIXOS_TARGET" ]; then
    TARGET_ARGS="--target $RUNIXOS_TARGET"
    export RUSTC="$RUNIXOS_RUSTC"
    export CARGO_TARGET_X86_64_ROVELSTARS_RUNIXOS_RUSTFLAGS="-L $RUNIXOS_STD_DEPS -L $SYSROOT/Core/LibKit -C link-arg=-fuse-ld=lld -C link-arg=--sysroot=$SYSROOT -C link-arg=--target=x86_64-rovelstars-runixos --cfg getrandom_backend=\"linux_getrandom\""
    export CC="$SYSROOT/Core/Bin/clang"
    export CXX="$SYSROOT/Core/Bin/clang++"
    export CFLAGS="--target=x86_64-rovelstars-runixos --sysroot=$SYSROOT -Wno-incompatible-pointer-types"
    export CFLAGS_x86_64_rovelstars_runixos="--target=x86_64-rovelstars-runixos --sysroot=$SYSROOT -Wno-incompatible-pointer-types"
fi

configure() {
    cd "$SRC"
    if [ ! -d "coreutils" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-runixos}" --depth 1 coreutils
    fi
    cd coreutils

    # Apply patches
    if [ "$CUSTOM_UNAME_O" = "true" ] && [ -f "$PATCHES/uname_o.diff" ]; then
        patch -p0 < "$PATCHES/uname_o.diff" || true
    fi
}

build() {
    cd "$SRC/coreutils"
    if [ -z "$RUNIXOS_TARGET" ]; then
        # Native build
        # CFLAGS workaround: onig_sys bundles old oniguruma incompatible with GCC 15
        CC=/usr/bin/cc CXX=/usr/bin/c++ \
            CFLAGS="-Wno-incompatible-pointer-types" \
            CFLAGS_x86_64_unknown_linux_gnu="-Wno-incompatible-pointer-types" \
            cargo build --release --features unix -j"$JOBS"
    else
        # Cross-compilation for RunixOS
        cargo build --release --features unix $TARGET_ARGS -j"$JOBS"
    fi
}

install() {
    cd "$SRC/coreutils"
    mkdir -p "$OUTPUT/Core/Bin"
    if [ -n "$RUNIXOS_TARGET" ]; then
        cp target/$RUNIXOS_TARGET/release/coreutils "$OUTPUT/Core/Bin/"
    else
        cp target/release/coreutils "$OUTPUT/Core/Bin/"
    fi
    # Create symlinks for individual utilities
    cd "$OUTPUT/Core/Bin"
    for u in arch base32 base64 basename cat chgrp chmod chown chroot cksum \
             comm cp csplit cut date dd df dircolors dirname du echo env expand \
             expr factor false fmt fold groups head hostid hostname id install \
             join kill link ln logname ls md5sum mkdir mkfifo mknod mktemp mv \
             nice nl nohup nproc numfmt od paste pathchk pinky pr printenv printf \
             ptx pwd readlink realpath rm rmdir seq shred shuf sleep sort split \
             stat stdbuf sum sync tac tail tee test timeout touch tr true truncate \
             tsort tty uname unexpand uniq unlink uptime users wc who whoami yes; do
        ln -sf coreutils "$u" 2>/dev/null
    done
}
