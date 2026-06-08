#!/bin/bash
# Build Perl 5 as a NATIVE RunixOS tool.
#
# No perl-cross / cross gymnastics: this is a native-build-in-chroot. The build
# runs chroot'd into the sysroot, RunixOS is glibc + the Linux ABI, and the cross
# clang's output is a runixos ELF that executes in the chroot - so Perl's
# Configure compiles its probe programs with our clang and RUNS them in place,
# exactly like a normal native build. We only have to tell Configure where the
# RunixOS headers/libs live (not /usr/include, /usr/lib) and the install layout.

configure() {
    cd "$SRC"
    if [ ! -d "perl-$VERSION" ]; then
        curl -L "$REPOSITORY/perl-$VERSION.tar.gz" -o perl.tar.gz
        tar --no-same-owner -xf perl.tar.gz
    fi
    cd "perl-$VERSION"

    # NO_LOCALE: Perl's Configure could not auto-detect this glibc's LC_ALL
    # category positions (PERL_LC_ALL_CATEGORY_POSITIONS_INIT left undefined ->
    # locale.c fails to compile). A build-time Perl does not need locale support,
    # so disable it; Perl runs in the C locale.
    CROSS="--target=x86_64-rovelstars-linux-runixos --sysroot=$SYSROOT"
    sh ./Configure -des \
        -Dcc="$SYSROOT/Core/Bin/clang" \
        -Dccflags="$CROSS -DNO_LOCALE" \
        -Dld="$SYSROOT/Core/Bin/clang" \
        -Dldflags="$CROSS" \
        -Dlddlflags="-shared $CROSS" \
        -Dusrinc=/Core/APIHeader \
        -Dlocincpth=/Core/APIHeader \
        -Dloclibpth=/Core/LibKit \
        -Dglibpth=/Core/LibKit \
        -Dlibswanted="pthread dl m c util" \
        -Duseshrplib \
        -Dprefix=/Core \
        -Dbin=/Core/Bin \
        -Dscriptdir=/Core/Bin \
        -Dprivlib=/Core/LibKit/perl5 \
        -Darchlib=/Core/LibKit/perl5/arch \
        -Dsitelib=/Core/LibKit/perl5/site \
        -Dsitearch=/Core/LibKit/perl5/site/arch \
        -Dvendorprefix=/Core \
        -Dvendorlib=/Core/LibKit/perl5/vendor \
        -Dvendorarch=/Core/LibKit/perl5/vendor/arch \
        -Dman1dir=/Core/StoreRoom/Manual/man1 \
        -Dman3dir=/Core/StoreRoom/Manual/man3 \
        -Dman1ext=1 -Dman3ext=3
}

build() {
    cd "$SRC/perl-$VERSION"
    make -j"$JOBS"
}

install() {
    cd "$SRC/perl-$VERSION"
    make install DESTDIR="$OUTPUT"
}
