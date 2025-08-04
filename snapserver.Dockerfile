# Stage 1: Build the snapserver binary
FROM debian:stable-slim as builder

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    libasound2-dev \
    libavahi-client-dev \
    libflac-dev \
    libogg-dev \
    libvorbis-dev \
    libopus-dev \
    libsoxr-dev && \
    rm -rf /var/lib/apt/lists/*

# Clone the specific version of snapcast
WORKDIR /usr/src
RUN git clone https://github.com/badaix/snapcast.git

# Build snapserver
WORKDIR /usr/src/snapcast
RUN cmake . && make snapserver

# Stage 2: Create the final, lightweight image
FROM debian:stable-slim

# Install only runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libasound2 \
    libavahi-client3 \
    libflac12 \
    libogg0 \
    libvorbis0a \
    libopus0 \
    libsoxr0 && \
    rm -rf /var/lib/apt/lists/*

# Copy the compiled binary from the builder stage
COPY --from=builder /usr/src/snapcast/bin/snapserver /usr/bin/snapserver

# Expose ports
EXPOSE 1704 1705 1780

# Set the entrypoint
ENTRYPOINT ["snapserver"]