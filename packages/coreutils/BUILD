# Use the official Rust image
FROM rust:latest

# Copy Patches

COPY /patches /patches/

# Install build dependencies and git
RUN apt update && \
  apt install -y clang

# Clone the repository at the specified version (branch/tag)
RUN git clone {{repository}} --branch {{version}} --depth 1 /{{name}}

# Set working directory (optional, if you want to build or run commands)
WORKDIR /{{name}}

# Apply patches if custom_uname_o is set in meta.toml. it is a boolean value, use it as {{custom_uname_o}}
RUN if [ "{{custom_uname_o}}" = "true" ]; then \
    patch src/uu/uname/src/uname.rs < /patches/uname_o.diff; \
  fi

# Build the project
RUN make PROFILE=release

# Install the built binary to the target directory
RUN mkdir -p /output
RUN make PREFIX=/output/build install
# Export the built binaries to tar.gz
RUN tar -czf /output/{{name}}-{{version}}.tar.gz -C /output/build .

# Create a share directory for output to be moved to during docker run.
VOLUME ["/share"]