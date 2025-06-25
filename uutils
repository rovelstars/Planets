# Use the official Rust image based on Alpine
FROM rust:alpine

# Set environment variables for metadata (optional, for documentation)
LABEL name="uutils"
LABEL version="0.1.0"
LABEL description="Cross-platform Rust rewrite of the GNU coreutils"
LABEL license="MIT"
LABEL repository="https://github.com/uutils/coreutils"

# Install build dependencies and git
RUN apk update && \
  apk add --no-cache build-base git

# Clone the repository at the specified version (branch/tag)
RUN git clone https://github.com/uutils/coreutils --branch 0.1.0 --depth 1 /uutils

# Set working directory (optional, if you want to build or run commands)
WORKDIR /uutils

# Build the project
RUN cargo build --release

# Export the built binaries to tar.gz
RUN mkdir -p /output && \
  cp target/release/uutils /output/ && \
  tar -czf /output/uutils.tar.gz -C /output uutils

# Allow the output directory to be exported to host
VOLUME ["/output"]

LABEL ship="/output/uutils.tar.gz"