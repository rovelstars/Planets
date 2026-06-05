#!/bin/bash
# compiler-rt builtins + CRT (crtbegin/crtend) for the RunixOS target. This is
# clang's runtime; glibc and everything else link against it (--rtlib=compiler-rt
# is the RunixOS default). Installs into clang's resource dir
# (Core/LibKit/clang/<major>/lib/<triple>/) so clang finds it with no flags.
#
# Built with the cross clang we already produced. cmake + ninja here are host
# tools (the prebuilt $SYSROOT cmake), only the target objects use the cross
# clang, so no host-toolchain pinning is needed (unlike the llvm package).

configure() {
    cd "$SRC"
    if [ -n "$LOCAL_SRC" ]; then
        ln -sfn "$LOCAL_SRC" llvm-project
    elif [ ! -d "llvm-project" ]; then
        git clone "$REPOSITORY" --branch "${BRANCH:-runixos}" --depth 1 llvm-project
    fi

    ver="$("$SYSROOT/Core/Bin/clang" -dumpversion | cut -d. -f1)"
    mkdir -p build && cd build
    "$SYSROOT/Core/Bin/cmake" ../llvm-project/compiler-rt -G Ninja \
        -DCMAKE_SYSTEM_NAME=RunixOS \
        -DCMAKE_C_COMPILER="$SYSROOT/Core/Bin/clang" \
        -DCMAKE_ASM_COMPILER="$SYSROOT/Core/Bin/clang" \
        -DCMAKE_C_COMPILER_TARGET=x86_64-rovelstars-linux-runixos \
        -DCMAKE_ASM_COMPILER_TARGET=x86_64-rovelstars-linux-runixos \
        -DCMAKE_SYSROOT="$SYSROOT" \
        -DCMAKE_C_FLAGS="--target=x86_64-rovelstars-linux-runixos -fuse-ld=lld" \
        -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
        -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON \
        -DCOMPILER_RT_BUILD_BUILTINS=ON \
        -DCOMPILER_RT_BUILD_CRT=ON \
        -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
        -DCOMPILER_RT_BUILD_XRAY=OFF \
        -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
        -DCOMPILER_RT_BUILD_PROFILE=OFF \
        -DCOMPILER_RT_BUILD_MEMPROF=OFF \
        -DCOMPILER_RT_BUILD_ORC=OFF \
        -DCOMPILER_RT_BUILD_GWP_ASAN=OFF \
        -DLLVM_CONFIG_PATH="$SYSROOT/Core/Bin/llvm-config" \
        -DCMAKE_INSTALL_PREFIX="$OUTPUT/Core/LibKit/clang/$ver"
}

build() {
    cd "$SRC/build"
    ninja -j"$JOBS"
}

install() {
    cd "$SRC/build"
    ninja install
}
