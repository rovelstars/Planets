# Use the official Rust image based on Alpine
FROM rust:alpine

# Set environment variables for metadata (optional, for documentation)

# Install build dependencies and git
RUN apk update && \
  apk add --no-cache build-base git

# Clone the repository at the specified version (branch/tag)
RUN git clone {{repository}} --branch {{version}} --depth 1 /{{name}}

# Set working directory (optional, if you want to build or run commands)
WORKDIR /{{name}}

# Build the project
RUN cargo build --release

# Export the built binaries to tar.gz
RUN mkdir -p /output && \
  cp target/release/{{name}} /output/ && \
  tar -czf /output/{{name}}.tar.gz -C /output {{name}}

# Allow the output directory to be exported to host
VOLUME ["/output"]