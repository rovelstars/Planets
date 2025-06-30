FROM rust:latest

RUN git clone {{repository}} --branch {{branch}} --depth 1 /{{name}}

WORKDIR /{{name}}

RUN mkdir -p /output/{{name}}
RUN cargo install --locked --path . --root /output/{{name}}

# Remove unnecessary files to reduce size
RUN rm -rf /output/{{name}}/.crates*

RUN tar -czf /output/{{name}}-{{version}}.tar.gz -C /output/{{name}} .

VOLUME ["/share"]