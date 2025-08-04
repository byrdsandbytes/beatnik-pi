# Dockerfile for librespot
# This file builds librespot from source using the dev branch.

# Use the official Rust image as a builder
FROM rust:latest as builder

# Install build dependencies for librespot
RUN apt-get update && apt-get install -y build-essential libasound2-dev

# Clone the dev branch of the librespot repository
RUN git clone --depth 1 --branch dev https://github.com/librespot-org/librespot.git

# Build librespot
# We specify the pipe backend as that's what we use to send audio to Snapserver.
WORKDIR /librespot
RUN cargo build --release --no-default-features --features "pipe-backend"

# Create a smaller final image
FROM debian:stable-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y libasound2 && rm -rf /var/lib/apt/lists/*

# Copy the compiled librespot binary from the builder stage
COPY --from=builder /librespot/target/release/librespot /usr/local/bin/librespot

# The command to run librespot will be provided by docker-compose
ENTRYPOINT ["/usr/local/bin/librespot"]
