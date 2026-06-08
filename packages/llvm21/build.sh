#!/bin/bash
# Build LLVM 21 (rust's pinned version) as native RunixOS codegen libraries for
# rust to link against externally (rust config.toml llvm-config=...). This avoids
# rust building LLVM itself (its bundled cmake invocation injects -isystem
# /usr/include + other breakage). Same native-build-in-chroot approach as
# llvm-native: our clang emits runixos, tblgen runs in the chroot.
#
# Installed to a CONTAINED /Core/llvm21 prefix so it never clashes with the
# LLVM-23 toolchain (llvm-native owns /Core/Bin/clang etc). Only LLVM itself is
# built - no clang/lld (those come from llvm-native 23).

configure() {
    cd "$SRC"
    if [ -n "$LOCAL_SRC" ]; then
        ln -sfn "$LOCAL_SRC" llvm-project
    elif [ ! -d "llvm-project" ]; then
        echo "llvm21 needs local_path to rust's src/llvm-project" >&2; exit 1
    fi

    mkdir -p build && cd build
    CROSS="--target=x86_64-rovelstars-linux-runixos --sysroot=$SYSROOT"
    cmake ../llvm-project/llvm -G Ninja \
        -DCMAKE_C_COMPILER="$SYSROOT/Core/Bin/clang" \
        -DCMAKE_CXX_COMPILER="$SYSROOT/Core/Bin/clang++" \
        -DCMAKE_C_FLAGS="$CROSS" \
        -DCMAKE_CXX_FLAGS="$CROSS" \
        -DLLVM_HOST_TRIPLE=x86_64-rovelstars-linux-runixos \
        -DLLVM_DEFAULT_TARGET_TRIPLE=x86_64-rovelstars-linux-runixos \
        -DLLVM_TARGETS_TO_BUILD="X86" \
        -DLLVM_OPTIMIZED_TABLEGEN=OFF \
        -DLLVM_INSTALL_UTILS=ON \
        -DLLVM_ENABLE_ZLIB=OFF \
        -DLLVM_ENABLE_ZSTD=OFF \
        -DLLVM_ENABLE_LIBXML2=OFF \
        -DLLVM_ENABLE_TERMINFO=OFF \
        -DLLVM_ENABLE_LIBEDIT=OFF \
        -DLLVM_ENABLE_LIBPFM=OFF \
        -DLLVM_INCLUDE_TESTS=OFF \
        -DLLVM_INCLUDE_BENCHMARKS=OFF \
        -DLLVM_INCLUDE_EXAMPLES=OFF \
        -DCMAKE_INSTALL_PREFIX="$OUTPUT/Core/llvm21" \
        -DCMAKE_INSTALL_BINDIR=bin \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DCMAKE_INSTALL_INCLUDEDIR=include \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_PARALLEL_LINK_JOBS=4
}

build() {
    cd "$SRC/build"
    ninja -j"$JOBS"
}

install() {
    cd "$SRC/build"
    ninja install
    # Our toolchain stamps static archives with the RunixOS .ral suffix, but rust
    # (and any standard consumer) links LLVM via -lLLVMCore -> libLLVMCore.a. Add
    # .a symlinks. This is a build-time lib, so the stock .a name is correct here.
    cd "$OUTPUT/Core/llvm21/lib"
    for f in *.ral; do [ -e "$f" ] && ln -sfn "$f" "${f%.ral}.a"; done
}
