#!/bin/bash
# libunwind + libc++abi + libc++ for RunixOS, with the .rdl/.ral SONAMEs. Needs
# full glibc (CRT + libc) and compiler-rt already in the sysroot, so it builds
# last in the toolchain. $SYSROOT cmake already carries the RunixOS platform, so
# no CMAKE_MODULE_PATH override is needed.

configure() {
    cd "$SRC"
    if [ -n "$LOCAL_SRC" ]; then
        ln -sfn "$LOCAL_SRC" llvm-project
    elif [ ! -d "llvm-project" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-runixos}" --depth 1 llvm-project
    fi

    local T=x86_64-rovelstars-linux-runixos
    # cmake runs from $SRC (the symlink is $SRC/llvm-project), so the source path
    # is relative to here, not ../ (unlike the llvm/compiler-rt packages which
    # cd into build first).
    "$SYSROOT/Core/Bin/cmake" llvm-project/runtimes -G Ninja -B build \
        -DCMAKE_SYSTEM_NAME=RunixOS \
        -DCMAKE_C_COMPILER="$SYSROOT/Core/Bin/clang" \
        -DCMAKE_CXX_COMPILER="$SYSROOT/Core/Bin/clang++" \
        -DCMAKE_C_COMPILER_TARGET="$T" \
        -DCMAKE_CXX_COMPILER_TARGET="$T" \
        -DCMAKE_SYSROOT="$SYSROOT" \
        -DCMAKE_INSTALL_PREFIX="$OUTPUT" \
        -DCMAKE_INSTALL_LIBDIR=Core/LibKit \
        -DCMAKE_INSTALL_INCLUDEDIR=Core/APIHeader \
        -DLIBUNWIND_INSTALL_LIBRARY_DIR=Core/LibKit \
        -DLIBCXXABI_INSTALL_LIBRARY_DIR=Core/LibKit \
        -DLIBUNWIND_INSTALL_INCLUDE_DIR=Core/APIHeader \
        -DLIBCXXABI_INSTALL_INCLUDE_DIR=Core/APIHeader \
        -DCMAKE_C_FLAGS="--target=$T -fuse-ld=lld -nostartfiles --rtlib=compiler-rt" \
        -DCMAKE_CXX_FLAGS="--target=$T -fuse-ld=lld -nostartfiles --rtlib=compiler-rt --unwindlib=none" \
        -DCMAKE_EXE_LINKER_FLAGS="-L$SYSROOT/Core/LibKit $SYSROOT/Core/LibKit/crt1.o $SYSROOT/Core/LibKit/crti.o $SYSROOT/Core/LibKit/crtn.o -lc" \
        -DCMAKE_SHARED_LINKER_FLAGS="-L$SYSROOT/Core/LibKit -lc" \
        -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
        -DLLVM_ENABLE_RUNTIMES="libunwind;libcxxabi;libcxx" \
        -DLLVM_DEFAULT_TARGET_TRIPLE="$T" \
        -DLIBUNWIND_USE_COMPILER_RT=ON \
        -DLIBCXXABI_USE_COMPILER_RT=ON \
        -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
        -DLIBCXX_USE_COMPILER_RT=ON \
        -DLIBCXX_CXX_ABI=libcxxabi \
        -DLIBCXX_HAS_ATOMIC_LIB=OFF \
        -DRovelStars=ON
}

build() {
    cd "$SRC"
    ninja -C build -j"$JOBS"
}

install() {
    cd "$SRC"
    ninja -C build install
    # libunwind + libc++abi have their own install targets; the default install
    # target only covers libc++.
    ninja -C build install-unwind install-cxxabi install-cxxabi-headers install-unwind-headers
}
