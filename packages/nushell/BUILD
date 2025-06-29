FROM rust:latest

RUN git clone {{repository}} --branch {{version}} --depth 1 /{{name}}

WORKDIR /{{name}}

RUN mkdir -p /output/{{name}}
RUN cargo install --path . --root /output/{{name}}
RUN tar -czf /output/{{name}}-{{version}}.tar.gz -C /output/{{name}} .

VOLUME ["/share"]