# Use the official Rust image
FROM rust:latest

# Set environment variables for metadata (optional, for documentation)

# Install build dependencies and git
RUN apt update && \
  apt install -y clang

# Clone the repository at the specified version (branch/tag)
RUN git clone {{repository}} --branch {{version}} --depth 1 /{{name}}

# Set working directory (optional, if you want to build or run commands)
WORKDIR /{{name}}

# Build the project
RUN make PROFILE=release

# Install the built binary to the target directory
RUN mkdir -p /output
RUN make PREFIX=/output/build install
# Export the built binaries to tar.gz
RUN tar -czf /output/{{name}}-{{version}}.tar.gz -C /output/build .

# Create a share directory for output to be moved to during docker run.
VOLUME ["/share"]