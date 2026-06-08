#!/bin/bash
# Build CMake as a NATIVE RunixOS tool (cross-compiled with the sysroot clang).
#
# The host `cmake` package builds a host-runnable cmake to drive the bootstrap;
# this one produces a cmake binary that RUNS on RunixOS. It is configured exactly
# like the host package (Linux platform + RunixOfficialBuild=ON for the /Core ring
# layout) - the ONLY difference is the compiler: the sysroot cross clang targeting
# runixos, so the binary is a native RunixOS ELF.
#
# Deliberately NOT using CMAKE_SYSTEM_NAME=RunixOS: that activates the fork's
# RunixOS platform module, whose ring dirs then stack on top of the cmake-fork's
# own RunixOfficialBuild ring, doubling install paths (/Core/Core/Bin). This is a
# native-build-in-chroot: the runixos-ELF binary runs in the chroot anyway, and
# the produced cmake still ships the RunixOS platform modules from the fork tree.
# Bundled third-party libs (libuv, librhash, ...) build with our clang, so no host
# libraries leak in. OpenSSL is off to keep the bootstrap lean.

configure() {
    cd "$SRC"
    if [ -n "$LOCAL_SRC" ]; then
        ln -sfn "$LOCAL_SRC" cmake
    elif [ ! -d "cmake" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-master}" --depth 1 cmake
    fi

    mkdir -p build && cd build

    # _GNU_SOURCE: RunixOS is glibc, and cmake's bundled curl uses GNU extensions
    # (accept4, etc) that glibc only declares under _GNU_SOURCE.
    CROSS="--target=x86_64-rovelstars-linux-runixos --sysroot=$SYSROOT -D_GNU_SOURCE"
    cmake ../cmake -G Ninja \
        -DCMAKE_C_COMPILER="$SYSROOT/Core/Bin/clang" \
        -DCMAKE_CXX_COMPILER="$SYSROOT/Core/Bin/clang++" \
        -DCMAKE_C_FLAGS="$CROSS" \
        -DCMAKE_CXX_FLAGS="$CROSS" \
        -DCMAKE_INSTALL_PREFIX="$OUTPUT" \
        -DRunixOS=1 \
        -DRunixOfficialBuild=ON \
        -DBUILD_TESTING=OFF \
        -DBUILD_CursesDialog=OFF \
        -DCMAKE_USE_OPENSSL=OFF \
        -DUSE_LIBIDN2=OFF \
        -DCMAKE_BUILD_TYPE=Release
}

build() {
    cd "$SRC/build"
    ninja -j"$JOBS"
}

install() {
    cd "$SRC/build"
    ninja install
}
