#!/bin/bash
# Build script for CMake (RovelStars fork with the RunixOS platform).
#
# CMake is a build-time tool: it runs on the build machine, not on RunixOS, so
# it is built with the HOST toolchain, not the RunixOS cross-compiler Rocket
# injects (same reason as the llvm package). The RunixOS value of this fork is
# the Modules/Platform/RunixOS*.cmake files; -DRunixOS=1 turns on the Core/Bin +
# Core/StoreRoom install layout and ships those modules, so the produced cmake
# understands -DCMAKE_SYSTEM_NAME=RunixOS with no extra module path.

configure() {
    export CC=/usr/bin/clang
    export CXX=/usr/bin/clang++
    export PATH=/usr/bin:/bin
    unset LD_LIBRARY_PATH

    cd "$SRC"
    # $LOCAL_SRC (meta.toml local_path, or `rocket build cmake --local ../cmake`)
    # builds the local fork instead of cloning.
    if [ -n "$LOCAL_SRC" ]; then
        ln -sfn "$LOCAL_SRC" cmake
    elif [ ! -d "cmake" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-master}" --depth 1 cmake
    fi

    mkdir -p build && cd build
    # Configure the fork with the host cmake (faster than ./bootstrap).
    cmake ../cmake -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$OUTPUT" \
        -DRunixOS=1 \
        -DBUILD_TESTING=OFF \
        -DBUILD_CursesDialog=OFF
}

build() {
    cd "$SRC/build"
    ninja -j"$JOBS"
}

install() {
    cd "$SRC/build"
    ninja install
}
