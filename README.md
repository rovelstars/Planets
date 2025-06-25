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

## Contributing

If you want to contribute a new planet, please follow the structure above. The `meta.toml` file should contain metadata about the planet, and the `BUILD` (essentially a Dockerfile with some slight modifications) should define how to build the planet.
Include any patches in the `patches` directory, if necessary.
Provide a `TIP.md` file with tips or additional information about the planet, if needed. This can be helpful for users who want to understand how to use or modify the planet. Simple projects may not need a `TIP.md` file, but it can be useful for more complex setups (like explaining why some specific patches are needed, and/or why to build with some specific build options).

Prefer linking to the upstream git repository in the `meta.toml` file, as long as its resonable to maintain with some patches. If the upstream repository is not maintained anymore, you can fork it and maintain your own version, but please make sure to document this in the `meta.toml` file (e.g., `original_repo_url` field).

Also note that `BUILD` files are modified Dockerfiles, so you can use the same syntax as in Dockerfiles, but with some modifications: examples like `{{repository}}` and `{{version}}` will be replaced with the values from the `meta.toml` file. This allows you to use variables in your Dockerfile-like files, making it easier to maintain and update your planets.

Make sure the BUILD script compiles and packs (archives) the planet into any known format (e.g., `.tar.gz`, `.zip`, etc.) that can be easily installed by users. The build script should also ensure that the planet is built in a clean environment, without any unnecessary dependencies or files. Make sure to notify where the archive is placed in `ship` section of the `meta.toml` file, as well as make the output folder as VOLUME in the `BUILD` file, so that the build system can access it after the build is complete.

**Note:** By contributing to this repository, you agree to license your contributions under the same license as the project (Apache License 2.0). Please ensure that your contributions comply with this license.

---

### Reasons why we decided to build this system:

Most of the current Linux distributions are built with the assumption that the user will have a full system with all the necessary tools and libraries installed. This is not always the case, especially for users who want to run specific applications or services without installing a full OS. We want to provide a way to build and run applications in a containerized environment, where each application can be built with its own dependencies and libraries, without affecting the rest of the system. Also they include their own build systems, which are often not compatible with each other, making it difficult to build and run applications across different distributions. Example, `PKGBUILD` for Arch Linux, `DEB` for Debian/Ubuntu, `RPM` for Red Hat/Fedora, etc. This leads to fragmentation and makes it difficult to maintain and update applications across different distributions. Containers are generally the de-facto standard for building and running applications in a consistent and reproducible way, but they are often not used for building and running applications on the user's machine. We want to change that by providing a way to build and run applications in containers, while still allowing users to install and run them on their machines without the need for a full OS.

You might ask why then require `meta.toml`'s variables to be used in the `BUILD` file? We expect you or your own tool to read the `BUILD` file and replace the variables with the values from the `meta.toml` file, so that you can use the same syntax as in Dockerfiles, but with some modifications. This allows you to use variables in your Dockerfile-like files, making it easier to maintain and update your planets.
