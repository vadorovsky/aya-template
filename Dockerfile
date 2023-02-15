FROM rust:1-bullseye AS build

COPY . /src
WORKDIR /src

RUN apk add --no-cache \
    libc6-compat \
    llvm15-dev \
    llvm15-static \
    libxml2-static \
    musl-dev \
    zlib-static
RUN rustup toolchain install nightly --component rust-src
RUN cargo install --no-default-features --features system-llvm bpf-linker
RUN cargo xtask build-ebpf --release \
    && cargo build --release

FROM gcr.io/distroless/static-debian11

COPY --from=build /src/target/release/{{project-name}} /{{project-name}}

ENTRYPOINT ["/{{project-name}}"]
