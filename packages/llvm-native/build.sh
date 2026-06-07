#!/bin/bash
# Build LLVM/Clang/LLD as a NATIVE RunixOS toolchain (Stage 2 of the bootstrap).
#
# Unlike the `llvm` package - which builds a HOST-runnable cross compiler used to
# bootstrap the sysroot - this produces clang/lld/llvm-* binaries that RUN on
# RunixOS (interpreter /Core/LibKit/ld-runixos). Because RunixOS is glibc + the
# Linux ABI, these binaries also execute under the host kernel inside the build
# chroot, so they can become the build compiler too (self-hosting).
#
# Build mechanics - the "native build inside a runixos chroot" trick:
#  RunixOS is glibc + the Linux ABI, and the build runs chroot'd into the sysroot
#  where /Core/LibKit/ld-runixos exists. So a clang-emitted runixos ELF EXECUTES
#  in the chroot under the host kernel. That means we do NOT cross-compile: we do
#  a NATIVE cmake build whose compiler just happens to emit runixos code. LLVM
#  then builds llvm-min-tblgen/llvm-tblgen as runixos ELFs and runs them directly
#  to generate its .inc/.h files - no NATIVE/ host sub-build, no prebuilt tblgen.
#  (Setting CMAKE_SYSTEM_NAME=RunixOS would flip on CMAKE_CROSSCOMPILING and force
#  the broken NATIVE tblgen sub-build, so we deliberately leave it unset.)
#
#  - CC/CXX is the sysroot clang with --target=runixos so every binary (clang,
#    lld, tblgen, llvm-*) is a native RunixOS ELF.
#  - The RovelStars cache forces RovelStars=ON + the RunixOS install layout, so
#    the cmake platform module is not needed.
#  - LLVM_HOST_TRIPLE / LLVM_DEFAULT_TARGET_TRIPLE = the runixos triple: clang
#    runs on, and defaults to emitting code for, RunixOS.
#  - No runtimes/builtins built here (cache forces LLVM_ENABLE_RUNTIMES="");
#    compiler-rt + libc++ come from their own packages already in the sysroot.
#  - Optional external deps are turned OFF: without cross find-root isolation a
#    native configure would otherwise pick up the host's zlib/xml2/etc.

configure() {
    cd "$SRC"
    if [ -n "$LOCAL_SRC" ]; then
        ln -sfn "$LOCAL_SRC" llvm-project
    elif [ ! -d "llvm-project" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-runixos}" --depth 1 llvm-project
    fi

    mkdir -p build && cd build

    CROSS="--target=x86_64-rovelstars-linux-runixos --sysroot=$SYSROOT"
    cmake ../llvm-project/llvm -G Ninja \
        -C ../llvm-project/clang/cmake/caches/RovelStars.cmake \
        -DCMAKE_C_COMPILER="$SYSROOT/Core/Bin/clang" \
        -DCMAKE_CXX_COMPILER="$SYSROOT/Core/Bin/clang++" \
        -DCMAKE_C_FLAGS="$CROSS" \
        -DCMAKE_CXX_FLAGS="$CROSS" \
        -DLLVM_HOST_TRIPLE=x86_64-rovelstars-linux-runixos \
        -DLLVM_DEFAULT_TARGET_TRIPLE=x86_64-rovelstars-linux-runixos \
        -DLLVM_ENABLE_PROJECTS="clang;lld" \
        -DLLVM_TARGETS_TO_BUILD="X86" \
        -DLLVM_OPTIMIZED_TABLEGEN=OFF \
        -DLLVM_ENABLE_ZSTD=OFF \
        -DLLVM_ENABLE_ZLIB=OFF \
        -DLLVM_ENABLE_LIBXML2=OFF \
        -DLLVM_ENABLE_TERMINFO=OFF \
        -DLLVM_ENABLE_LIBEDIT=OFF \
        -DLLVM_ENABLE_LIBPFM=OFF \
        -DLLVM_INCLUDE_TESTS=OFF \
        -DLLVM_INCLUDE_BENCHMARKS=OFF \
        -DCMAKE_INSTALL_PREFIX="$OUTPUT" \
        -DCMAKE_INSTALL_BINDIR=Core/Bin \
        -DCMAKE_INSTALL_LIBDIR=Core/LibKit \
        -DCMAKE_INSTALL_INCLUDEDIR=Core/APIHeader \
        -DCMAKE_INSTALL_DATADIR=Core/StoreRoom \
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

    # Drop-in GNU-named symlinks so build systems that call ar/ranlib/nm/strip/
    # objcopy/objdump/size/ld find them. The llvm-* tools are argument-compatible
    # with the binutils equivalents; ld -> ld.lld.
    cd "$OUTPUT/Core/Bin"
    for pair in ar:llvm-ar ranlib:llvm-ranlib nm:llvm-nm strip:llvm-strip \
                objcopy:llvm-objcopy objdump:llvm-objdump size:llvm-size \
                ld:ld.lld; do
        link="${pair%%:*}"; tgt="${pair##*:}"
        [ -e "$tgt" ] && ln -sfn "$tgt" "$link"
    done

    # Strip any stray host-triple builtins the build emitted outside the RunixOS
    # layout (the runtimes/builtins come from the compiler-rt package).
    rm -rf "$OUTPUT/lib"
}
