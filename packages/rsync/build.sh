#!/bin/bash
# rsync, native cross-compiled. Used by the kernel's headers_install. Minimal
# build: bundled popt, no xxhash/zstd/lz4/openssl/xattr to avoid extra deps.

configure() {
    cd "$SRC"
    if [ ! -d "rsync-$VERSION" ]; then
        curl -L "$REPOSITORY/rsync-$VERSION.tar.gz" -o rsync.tar.gz
        tar --no-same-owner -xf rsync.tar.gz
    fi
    cd "rsync-$VERSION"

    CC="$SYSROOT/Core/Bin/clang --target=x86_64-rovelstars-linux-runixos --sysroot=$SYSROOT" \
    ./configure \
        --build=x86_64-pc-linux-gnu \
        --host=x86_64-rovelstars-linux-gnu \
        --prefix=/Core \
        --bindir=/Core/Bin \
        --mandir=/Core/StoreRoom/Manual \
        --disable-xxhash --disable-zstd --disable-lz4 --disable-openssl \
        --disable-xattr-support --disable-acl-support
}

build() {
    cd "$SRC/rsync-$VERSION"
    make -j"$JOBS"
}

install() {
    cd "$SRC/rsync-$VERSION"
    make install DESTDIR="$OUTPUT"
}
