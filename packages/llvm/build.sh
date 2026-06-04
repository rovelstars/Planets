#!/bin/bash
# Build script for LLVM/Clang/LLD (RunixOS)

configure() {
    # Build LLVM with the host toolchain, not the RunixOS cross-compiler that
    # Rocket injects. LLVM builds its own host tools (tblgen) during the build,
    # and those have to run on the build machine. The clang we produce still
    # defaults to the RunixOS target via the cmake cache. Without this, the host
    # tools get the RunixOS interpreter and fail to start.
    export CC=/usr/bin/clang
    export CXX=/usr/bin/clang++
    export AR=/usr/bin/ar
    export RANLIB=/usr/bin/ranlib
    export PATH=/usr/bin:/bin
    unset LD_LIBRARY_PATH

    cd "$SRC"
    # $LOCAL_SRC (set by `rocket build llvm --local ../llvm-project`) builds the
    # local working tree instead of cloning upstream.
    if [ -n "$LOCAL_SRC" ]; then
        ln -sfn "$LOCAL_SRC" llvm-project
    elif [ ! -d "llvm-project" ]; then
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
