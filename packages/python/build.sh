#!/bin/bash
# Build CPython 3 as a NATIVE RunixOS tool.
#
# Native-build-in-chroot: the build runs chroot'd into the sysroot and a runixos
# ELF executes there, so CPython's configure compiles + RUNS its probes with our
# clang like a normal native build - no cross mode, no --with-build-python. We
# only point it at the RunixOS header/lib dirs and layout. Extension modules whose
# external libs are absent (libffi/readline/ncurses/sqlite/bz2) are skipped; the
# ones we have (zlib, openssl, lzma) build. CONFIG_SITE (sandbox) routes man/data
# into StoreRoom.

configure() {
    cd "$SRC"
    if [ ! -d "Python-$VERSION" ]; then
        curl -L "$REPOSITORY/$VERSION/Python-$VERSION.tar.xz" -o python.tar.xz
        tar --no-same-owner -xf python.tar.xz
    fi
    cd "Python-$VERSION"

    CROSS="--target=x86_64-rovelstars-linux-runixos --sysroot=$SYSROOT"
    CC="$SYSROOT/Core/Bin/clang $CROSS" \
    CXX="$SYSROOT/Core/Bin/clang++ $CROSS" \
    CPPFLAGS="-I/Core/APIHeader" \
    LDFLAGS="-L/Core/LibKit" \
    ./configure \
        --build=x86_64-pc-linux-gnu \
        --prefix=/Core \
        --bindir=/Core/Bin \
        --libdir=/Core/LibKit \
        --includedir=/Core/APIHeader \
        --with-platlibdir=LibKit \
        --enable-shared \
        --with-ensurepip=no \
        --without-static-libpython \
        py_cv_module_readline=n/a \
        py_cv_module__bz2=n/a \
        py_cv_module__blake2=n/a \
        py_cv_module__gdbm=n/a \
        py_cv_module__dbm=n/a \
        py_cv_module__sqlite3=n/a \
        py_cv_module__tkinter=n/a \
        py_cv_module__curses=n/a \
        py_cv_module__curses_panel=n/a \
        py_cv_module_nis=n/a \
        py_cv_module__ctypes=n/a \
        py_cv_module__uuid=n/a
}

build() {
    cd "$SRC/Python-$VERSION"
    make -j"$JOBS"
}

install() {
    cd "$SRC/Python-$VERSION"
    make install DESTDIR="$OUTPUT"
}
