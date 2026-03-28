#!/bin/bash
# Build script for helix editor (RunixOS cross-compilation)

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
    if [ ! -d "helix" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-runixos}" --depth 1 helix
    fi
}

build() {
    cd "$SRC/helix"
    # Skip tree-sitter grammar compilation during cross-build
    # Grammars can be fetched/built natively on RunixOS later
    HELIX_DISABLE_AUTO_GRAMMAR_BUILD=1 \
        cargo build --release $TARGET_ARGS -j"$JOBS"
}

install() {
    cd "$SRC/helix"
    local bin_dir="$OUTPUT/Core/Bin"
    local runtime_dir="$OUTPUT/Core/StoreRoom/helix/runtime"
    mkdir -p "$bin_dir" "$runtime_dir"

    if [ -n "$RUNIXOS_TARGET" ]; then
        cp "target/$RUNIXOS_TARGET/release/hx" "$bin_dir/"
    else
        cp "target/release/hx" "$bin_dir/"
    fi

    # Install runtime files (themes, queries, etc.)
    cp -r runtime/* "$runtime_dir/"
}
