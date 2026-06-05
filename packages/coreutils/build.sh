#!/bin/bash
# Build script for coreutils (Rust uutils) (RunixOS), cross-built with the
# sysroot Rust toolchain.

TARGET=x86_64-rovelstars-linux-runixos

configure() {
    cd "$SRC"
    if [ -n "$LOCAL_SRC" ]; then
        ln -sfn "$LOCAL_SRC" coreutils
    elif [ ! -d "coreutils" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-runixos}" --depth 1 coreutils
    fi
    cd coreutils
    if [ "$CUSTOM_UNAME_O" = "true" ] && [ -f "$PATCHES/uname_o.diff" ]; then
        patch -p0 < "$PATCHES/uname_o.diff" || true
    fi
}

build() {
    cd "$SRC/coreutils"
    export CARGO_TARGET_X86_64_ROVELSTARS_LINUX_RUNIXOS_LINKER="$SYSROOT/Core/Bin/clang"
    export CARGO_TARGET_X86_64_ROVELSTARS_LINUX_RUNIXOS_RUSTFLAGS="-C link-arg=--sysroot=$SYSROOT -C link-arg=-fuse-ld=lld --cfg getrandom_backend=\"linux_getrandom\""
    export CC_x86_64_rovelstars_linux_runixos="$SYSROOT/Core/Bin/clang"
    # onig_sys bundles an old oniguruma that trips newer C compilers.
    export CFLAGS_x86_64_rovelstars_linux_runixos="--target=$TARGET --sysroot=$SYSROOT -Wno-incompatible-pointer-types"
    cargo build --release --features unix --target "$TARGET" -j"$JOBS"
}

install() {
    cd "$SRC/coreutils"
    mkdir -p "$OUTPUT/Core/Bin"
    cp "target/$TARGET/release/coreutils" "$OUTPUT/Core/Bin/"
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
