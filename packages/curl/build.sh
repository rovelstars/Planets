#!/bin/bash
# Build script for curl (RunixOS cross-compilation)
# Depends on: zlib, openssl, nghttp2

configure() {
    cd "$SRC"
    if [ ! -d "curl" ]; then
        git clone "$REPOSITORY" --branch "curl-${VERSION//./_}" --depth 1 curl
    fi

    mkdir -p curl-build && cd curl-build

    cmake ../curl -G Ninja \
        -DCMAKE_SYSTEM_NAME=RunixOS \
        -DCMAKE_C_COMPILER="$SYSROOT/Core/Bin/clang" \
        -DCMAKE_C_FLAGS="--target=x86_64-rovelstars-runixos --sysroot=$SYSROOT -Wno-incompatible-pointer-types" \
        -DCMAKE_INSTALL_PREFIX=/Core \
        -DCMAKE_INSTALL_BINDIR=Bin \
        -DCMAKE_INSTALL_LIBDIR=LibKit \
        -DCMAKE_INSTALL_INCLUDEDIR=APIHeader \
        -DCMAKE_PREFIX_PATH="$SYSROOT/Core" \
        -DCMAKE_FIND_ROOT_PATH="$SYSROOT/Core" \
        -DZLIB_INCLUDE_DIR="$SYSROOT/Core/APIHeader" \
        -DZLIB_LIBRARY="$SYSROOT/Core/LibKit/libz.so" \
        -DCURL_USE_OPENSSL=ON \
        -DOPENSSL_ROOT_DIR="$SYSROOT/Core" \
        -DOPENSSL_INCLUDE_DIR="$SYSROOT/Core/APIHeader" \
        -DOPENSSL_CRYPTO_LIBRARY="$SYSROOT/Core/LibKit/libcrypto.so" \
        -DOPENSSL_SSL_LIBRARY="$SYSROOT/Core/LibKit/libssl.so" \
        -DUSE_NGHTTP2=ON \
        -DNGHTTP2_INCLUDE_DIR="$SYSROOT/Core/APIHeader" \
        -DNGHTTP2_LIBRARY="$SYSROOT/Core/LibKit/libnghttp2.rdl" \
        -DCURL_ZLIB=ON \
        -DCURL_USE_LIBSSH2=OFF \
        -DCURL_USE_LIBPSL=OFF \
        -DCURL_USE_LIBSSH=OFF \
        -DUSE_LIBIDN2=OFF \
        -DCURL_BROTLI=OFF \
        -DCURL_ZSTD=OFF \
        -DCURL_DISABLE_LDAP=ON \
        -DCURL_DISABLE_LDAPS=ON \
        -DBUILD_TESTING=OFF \
        -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
        -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
        -DCMAKE_BUILD_TYPE=Release
}

build() {
    cd "$SRC/curl-build"
    ninja -j"$JOBS"
}

install() {
    cd "$SRC/curl-build"
    DESTDIR="$OUTPUT" ninja install
}
