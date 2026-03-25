#!/bin/bash
# Build script for LLVM/Clang/LLD (RunixOS)

configure() {
    cd "$SRC"
    if [ ! -d "llvm-project" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-llvmorg-$VERSION}" --depth 1 llvm-project
    fi

    mkdir -p build && cd build

    cmake ../llvm-project/llvm -G Ninja \
        -C ../llvm-project/clang/cmake/caches/RovelStars.cmake \
        -DCMAKE_INSTALL_PREFIX="$OUTPUT" \
        -DCMAKE_INSTALL_BINDIR=Core/Bin \
        -DCMAKE_INSTALL_LIBDIR=Core/LibKit \
        -DCMAKE_INSTALL_INCLUDEDIR=Core/APIHeader \
        -DCMAKE_INSTALL_DATADIR=Core/StoreRoom \
        -DRovelStars=ON \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_ENABLE_PROJECTS="clang;lld" \
        -DLLVM_TARGETS_TO_BUILD="X86;AArch64" \
        -DLLVM_INCLUDE_TESTS=OFF \
        -DLLVM_INCLUDE_BENCHMARKS=OFF \
        -DLLVM_PARALLEL_LINK_JOBS=4
}

build() {
    cd "$SRC/build"
    ninja -j"$JOBS"
}

install() {
    cd "$SRC/build"
    ninja install
}
