#!/bin/bash
# Build script for OpenSSL (RunixOS cross-compilation)

configure() {
    cd "$SRC"
    if [ ! -d "openssl" ]; then
        git clone "$REPOSITORY" --branch "openssl-$VERSION" --depth 1 openssl
    fi

    cd openssl

    CC="$SYSROOT/Core/Bin/clang --target=x86_64-rovelstars-runixos --sysroot=$SYSROOT" \
    CFLAGS="-Wno-incompatible-pointer-types" \
    ./Configure linux-x86_64 \
        --prefix=/Core \
        --libdir=LibKit \
        --includedir=APIHeader \
        --openssldir=/Core/Config/ssl \
        shared
}

build() {
    cd "$SRC/openssl"
    make -j"$JOBS"
}

install() {
    cd "$SRC/openssl"
    make install_sw install_ssldirs DESTDIR="$OUTPUT"
}
