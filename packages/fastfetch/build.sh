#!/bin/bash
# Build script for fastfetch (RunixOS cross-compilation).
# Ships a RunixOS-branded ASCII logo (patches/runixos-logo.txt) and a default
# config that selects it. Optional GUI/graphics integrations are dlopen-based in
# fastfetch, so a minimal build still detects CPU/memory/OS/kernel/uptime/etc.

TARGET=x86_64-rovelstars-linux-runixos

configure() {
    cd "$SRC"
    if [ -n "$LOCAL_SRC" ]; then
        rm -rf fastfetch
        ln -sfn "$LOCAL_SRC" fastfetch
    elif [ ! -d "fastfetch" ]; then
        git clone "$REPOSITORY" --branch "$VERSION" --depth 1 fastfetch
    fi

    # Fresh cmake dir: CMAKE_SYSTEM_NAME is cached on first configure and sticks,
    # so a stale cache would keep an old value.
    rm -rf fastfetch-build
    mkdir -p fastfetch-build && cd fastfetch-build

    # fastfetch's CMakeLists rejects unknown CMAKE_SYSTEM_NAME, so present as Linux
    # (RunixOS is a Linux kernel; this enables fastfetch's /proc + /sys detection).
    # Setting CMAKE_SYSTEM_NAME still puts cmake in cross mode; clang's --target
    # makes the actual binary a RunixOS one.
    cmake ../fastfetch -G Ninja \
        -DCMAKE_SYSTEM_NAME=Linux \
        -DCMAKE_SYSTEM_PROCESSOR=x86_64 \
        -DCMAKE_C_COMPILER="$SYSROOT/Core/Bin/clang" \
        -DCMAKE_C_FLAGS="--target=$TARGET --sysroot=$SYSROOT" \
        -DCMAKE_EXE_LINKER_FLAGS="--target=$TARGET --sysroot=$SYSROOT" \
        -DCMAKE_INSTALL_PREFIX=/Core \
        -DCMAKE_INSTALL_BINDIR=Bin \
        -DCMAKE_PREFIX_PATH="$SYSROOT/Core" \
        -DCMAKE_FIND_ROOT_PATH="$SYSROOT/Core" \
        -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
        -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_TESTS=OFF \
        -DENABLE_VULKAN=OFF -DENABLE_WAYLAND=OFF -DENABLE_X11=OFF -DENABLE_XCB=OFF \
        -DENABLE_XRANDR=OFF -DENABLE_XCB_RANDR=OFF -DENABLE_GIO=OFF -DENABLE_DCONF=OFF \
        -DENABLE_DBUS=OFF -DENABLE_XFCONF=OFF -DENABLE_SQLITE3=OFF -DENABLE_RPM=OFF \
        -DENABLE_IMAGEMAGICK7=OFF -DENABLE_IMAGEMAGICK6=OFF -DENABLE_CHAFA=OFF \
        -DENABLE_ZLIB=OFF -DENABLE_EGL=OFF -DENABLE_GLX=OFF -DENABLE_OSMESA=OFF \
        -DENABLE_OPENCL=OFF -DENABLE_LIBPCI=OFF -DENABLE_DRM=OFF -DENABLE_DDCUTIL=OFF \
        -DENABLE_PULSE=OFF -DENABLE_OPENGL=OFF -DENABLE_FREETYPE=OFF
}

build() {
    cd "$SRC/fastfetch-build"
    ninja -j"$JOBS"
}

install() {
    cd "$SRC/fastfetch-build"
    DESTDIR="$OUTPUT" ninja install

    # Install the RunixOS-branded logo and a default config that selects it.
    mkdir -p "$OUTPUT/Core/StoreRoom/fastfetch" "$OUTPUT/Core/Config/fastfetch"
    cp "$PATCHES/runixos-logo.txt" "$OUTPUT/Core/StoreRoom/fastfetch/runixos-logo.txt"
    cat > "$OUTPUT/Core/Config/fastfetch/config.jsonc" <<'CFG'
{
    "logo": {
        "type": "file-raw",
        "source": "/Core/StoreRoom/fastfetch/runixos-logo.txt",
        "padding": { "top": 1, "right": 3 }
    }
}
CFG
}
