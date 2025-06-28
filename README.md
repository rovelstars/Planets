# Planets

This repository contains a collection of "planets" (packages that are built inside containers using Docker) for our OS. We have the right to decide which planets to include in our OS, and we will not include planets that are not useful or do not meet our standards. Other planets can be installed manually by users, but they will not be included in the official OS build. More info about such "third party planets" will be available in the future.
Example of creating a new planet.

Checkout [Rocket](https://github.com/rovelstars/Rocket) for the build tool that is used to build the planets.

```tree
package_name/
├─ BUILD
├─ meta.toml
├─ TIP.md (optional)
├─ patches (optional)/
│  ├─ patch_name.patch

```

You need to copy patches folder to the container via `BUILD` file, and access it yourself during the build process. You need to manually apply the patches in the `BUILD` file, as Rocket does not do that automatically. You can use the `RUN` command in the `BUILD` file to apply the patches using `git apply` or `patch` command.

## Copyleft Licenses

While we prefer non copyleft licenses wherever possible, we understand and respect developers' choices to use copyleft licenses for their projects. We hence require such projects to copy all such licenses to the `LICENSES` directory in the root of the repository, and to include a reference to the license (title) in the `meta.toml` file of the planet. This ensures that users can easily find and understand the licensing terms of the planets they are using.
For example, let's choose `gcc` project at [gcc-mirror/gcc](https://github.com/gcc-mirror/gcc):
You need to put these in `meta.toml` file:

```toml
license=["GPL-2.0","LGPL-2.1","GCC RUNTIME LIBRARY EXCEPTION"]
```

We found and chose the name "GCC RUNTIME LIBRARY EXCEPTION" based on the title present in the `COPYING.RUNTIME` file in the `gcc` repository. This is important because it allows us to understand the licensing terms of the project and ensure that we comply with them.
Alongside this, copy all the required licenses (`COPYING`, `COPYING.RUNTIME`, `COPYING.LIB`, etc.) to the `LICENSES` directory in the root of the repository.

Rocket (the program which builds the planets) will automatically check for the presence of the `LICENSES` directory, and include them into the final project (the OS) at `/Core/Essence/Licenses/<package_name>/` for system dependencies & `/Construct/Kits/Licenses/<package_name>/` for third party apps/planets. This ensures that all licenses are preserved and can be easily accessed by users.

**TIP:** You just need to copy the license files from the upstream repository to the `LICENSES` directory in the root of Docker container. You are also expected to create a volume `/shared` in the `BUILD` file, so that the build system can access the `LICENSES` directory after the build is complete. Its the job of Rocket to copy licenses from the container to the main system, so you don't need to worry about that.

## Naming Schemes

Planet (package name in `meta.toml` file) should be in lowercase, and should not contain any special characters except for `_` (underscore). This is to ensure that the package name can be easily trimmed out of final archive file names (`{{name}}-{{version}}.<format>`), and to avoid any issues with file systems that do not support special characters in file names. The `meta.toml` file should contain the following fields:

```toml
name = "package_name" # lowercase, no special characters except for `_`
version = "1.0.0" # version of the package
description = "A brief description of the package" # short description of the package
licenses = ["MIT"] # list of licenses used by the package, including custom ones (choose the first line of the license file - they're usually titles of the licenses)
repository = "https://github/example/repository" # URL of the repository where the package is hosted
branch = "" # (optional) branch of the repository to manually choose, incase the tags are not same as version, or if you want to use a specific branch. Note: you need to manually apply this to BUILD file too.

<any_custom_flags> = "true" # (optional) any custom flags that you want to use in the BUILD file, e.g., `custom_uname_o = "true"` for uutils package. Please note that this is not a standard field, and you can use any name you want, as long as it is used in the BUILD file. Keep it in snake_case, and use it in the BUILD file as `{{any_custom_flags}}`. Please also write a TIP.md file explaining what this flag does, and how to use it. This is important because it allows users to understand the purpose of the flag and how to use it effectively.
```

## Contributing

If you want to contribute a new planet, please follow the structure above. The `meta.toml` file should contain metadata about the planet, and the `BUILD` (essentially a Dockerfile with some slight modifications) should define how to build the planet.
Include any patches in the `patches` directory, if necessary.
Provide a `TIP.md` file with tips or additional information about the planet, if needed. This can be helpful for users who want to understand how to use or modify the planet. Simple projects may not need a `TIP.md` file, but it can be useful for more complex setups (like explaining why some specific patches are needed, and/or why to build with some specific build options).

Prefer linking to the upstream git repository in the `meta.toml` file, as long as its resonable to maintain with some patches. If the upstream repository is not maintained anymore, you can fork it and maintain your own version, but please make sure to document this in the `meta.toml` file (e.g., `original_repo_url` field).

Also note that `BUILD` files are modified Dockerfiles, so you can use the same syntax as in Dockerfiles, but with some modifications: examples like `{{repository}}` and `{{version}}` will be replaced with the values from the `meta.toml` file. This allows you to use variables in your Dockerfile-like files, making it easier to maintain and update your planets.

Make sure the BUILD script compiles and packs (archives) the planet into any known format (e.g., `.tar.gz`, `.zip`, etc.) that can be easily installed by users. The build script should also ensure that the planet is built in a clean environment, without any unnecessary dependencies or files. The final file **MUST** be present as `/output/{{name}}-{{version}}.<format>` in the container, where `<format>` is the format of the archive (e.g., `.tar.gz`, `.zip`, etc.). This is important because it allows users to easily find and install the planet after it has been built. Current known formats are `.tar.gz`, `.zip`, and `.tar.xz`, but you can use any format that is supported by the build system.

Also create a volume `/shared` in the `BUILD` file, so that the build system can access the final archive file as well as the `LICENSES` directory after the build is complete. This is important because it allows the build system to copy the licenses from the container to the main system, ensuring that all licenses are preserved and can be easily accessed by users.

**Note:** By contributing to this repository, you agree to license your contributions under the same license as the project (Apache License 2.0). Please ensure that your contributions comply with this license.

---

## Reasons why we decided to build this system

Most of the current Linux distributions are built with the assumption that the user will have a full system with all the necessary tools and libraries installed. This is not always the case, especially for users who want to run specific applications or services without installing a full OS. We want to provide a way to build and run applications in a containerized environment, where each application can be built with its own dependencies and libraries, without affecting the rest of the system. Also they include their own build systems, which are often not compatible with each other, making it difficult to build and run applications across different distributions. Example, `PKGBUILD` for Arch Linux, `DEB` for Debian/Ubuntu, `RPM` for Red Hat/Fedora, etc. This leads to fragmentation and makes it difficult to maintain and update applications across different distributions. Containers are generally the de-facto standard for building and running applications in a consistent and reproducible way, but they are often not used for building and running applications on the user's machine. We want to change that by providing a way to build and run applications in containers, while still allowing users to install and run them on their machines without the need for a full OS.

You might ask why then require `meta.toml`'s variables to be used in the `BUILD` file? We expect you or your own tool to read the `BUILD` file and replace the variables with the values from the `meta.toml` file, so that you can use the same syntax as in Dockerfiles, but with some modifications. This allows you to use variables in your Dockerfile-like files, making it easier to maintain and update your planets.
