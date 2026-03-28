# Planets

This repository contains a collection of "planets" (packages) for RunixOS. We have the right to decide which planets to include in our OS, and we will not include planets that are not useful or do not meet our standards. Other planets can be installed manually by users, but they will not be included in the official OS build. More info about such "third party planets" will be available in the future.

Checkout [Rocket](https://github.com/rovelstars/Rocket) for the build tool that is used to build the planets.

## Package structure

```tree
package_name/
  meta.toml
  build.sh
  patches/ (optional)
    some_fix.patch
```

### meta.toml

```toml
name = "package_name"
version = "1.0.0"
description = "A brief description of the package"
licenses = ["MIT"]
repository = "https://github.com/example/repository"
branch = "" # optional, use when tags don't match version or you need a specific branch
```

Any extra fields in `meta.toml` are passed as uppercase environment variables to the build script. For example, `custom_uname_o = "true"` becomes `$CUSTOM_UNAME_O` in `build.sh`. If you add custom flags, write a short explanation in a `TIP.md` file.

### build.sh

The build script defines three shell functions that Rocket calls in order:

```sh
configure() {
    # Clone source, run configure/cmake, etc.
    # Available vars: $SRC, $OUTPUT, $SYSROOT, $REPOSITORY, $VERSION, $BRANCH, $JOBS
}

build() {
    # Compile the package
}

install() {
    # Install to $OUTPUT with RunixOS directory layout
    # Use: /Core/Bin, /Core/LibKit, /Core/APIHeader, /Core/StoreRoom, /Core/Config
}
```

For cross-compilation to RunixOS, C packages should use `$SYSROOT/Core/Bin/clang` with `--target=x86_64-rovelstars-runixos --sysroot=$SYSROOT`. Rust packages should check `$RUNIXOS_TARGET` and set up cargo flags accordingly (see existing Rust packages for the pattern).

## Current packages

| Package | Type | Description |
|---------|------|-------------|
| glibc | C | GNU C Library (RunixOS fork) |
| llvm | C++ | LLVM/Clang/LLD compiler toolchain |
| zlib | C | Compression library |
| openssl | C | TLS/SSL and cryptography |
| nghttp2 | C | HTTP/2 library |
| expat | C | XML parser |
| curl | C | URL transfer tool and library |
| git | C | Distributed version control |
| coreutils | Rust | Basic utilities (ls, cp, mv, cat, etc.) |
| findutils | Rust | find and xargs |
| brush | Rust | Bash-compatible shell |
| nushell | Rust | Modern structured data shell |
| helix | Rust | Post-modern text editor |
| base-image | meta | Assembles the base system image |

## Copyleft licenses

While we prefer non-copyleft licenses wherever possible, we understand and respect developers' choices to use copyleft licenses for their projects. We hence require such projects to copy all such licenses to the `LICENSES` directory in the root of the repository, and to include a reference to the license (title) in the `meta.toml` file of the planet. This ensures that users can easily find and understand the licensing terms of the planets they are using.

For example, for glibc:

```toml
licenses = ["GPL-2.0", "LGPL-2.1", "GCC RUNTIME LIBRARY EXCEPTION"]
```

License names should match the title present in the upstream license files. Copy the relevant license files (`COPYING`, `COPYING.LIB`, etc.) to the `LICENSES` directory.

Rocket will automatically include them into the final system at `/Core/Essence/Licenses/<package_name>/` for system packages and `/Construct/Kits/Licenses/<package_name>/` for third party apps.

## Naming

Package names in `meta.toml` should be lowercase with no special characters except `_`. This keeps archive file names clean (`{{name}}-{{version}}.<format>`).

## Contributing

If you want to contribute a new planet, follow the structure above. Prefer linking to the upstream git repository in `meta.toml` as long as its reasonable to maintain with some patches. If you need to fork upstream, document the original repository URL in `meta.toml`.

Include any patches in the `patches/` directory. Provide a `TIP.md` file with tips or additional information if the build setup is non-obvious.

**Note:** By contributing to this repository, you agree to license your contributions under the same license as the project (Apache License 2.0).
