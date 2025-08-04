# Inspired by firefrei/docker-snapcast for best practices

# Use ARGs to define versions for easier updates
ARG SNAPCAST_VERSION=v0.32.0
ARG DEBIAN_RELEASE=stable-slim

# Stage 1: Build the snapserver binary
FROM debian:${DEBIAN_RELEASE} as builder

# Set ARG for this stage as well
ARG SNAPCAST_VERSION
ARG DEBIAN_FRONTEND=noninteractive

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
RUN git clone --branch ${SNAPCAST_VERSION} --depth 1 https://github.com/badaix/snapcast.git

# Build snapserver with release optimizations
WORKDIR /usr/src/snapcast
RUN cmake -DCMAKE_BUILD_TYPE=Release . && make snapserver

# Stage 2: Create the final, lightweight image
FROM debian:${DEBIAN_RELEASE}

ARG DEBIAN_FRONTEND=noninteractive

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

# Create a non-root user and group for security
RUN groupadd --system snapcast && \
    useradd --system --no-create-home --gid snapcast snapcast

# Create and set permissions for the directory where audio pipes will be mounted
RUN mkdir -p /tmp/snapcast && \
    chown -R snapcast:snapcast /tmp/snapcast

# Switch to the non-root user
USER snapcast

# Expose ports
EXPOSE 1704 1705 1780

# Add a healthcheck to monitor the server status
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD snapserver --version || exit 1

# Set the entrypoint to run snapserver.
# The configuration will be provided via the volume mount in docker-compose.
ENTRYPOINT ["snapserver"]