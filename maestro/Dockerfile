# Build stage
FROM ghcr.io/home-assistant/amd64-addon-base:14 AS build
WORKDIR /build
COPY .swift-version /tmp/.swift-version
RUN SWIFT_VERSION=$(cat /tmp/.swift-version) && \
    curl -sL https://swift.org/builds/swift-${SWIFT_VERSION}-release/ubuntu2004/swift-${SWIFT_VERSION}-RELEASE/swift-${SWIFT_VERSION}-RELEASE-ubuntu20.04.tar.gz \
      | tar xz -C /usr/ && \
    ln -s /usr/swift-${SWIFT_VERSION}-RELEASE-ubuntu20.04/usr/bin/swift /usr/bin/swift
COPY .. .
RUN swift build -c release

# Runtime stage
FROM ghcr.io/home-assistant/amd64-addon-base:14
WORKDIR /app
COPY --from=build /build/.build/release/maestro /usr/local/bin/maestro
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh
ENTRYPOINT ["/usr/local/bin/run.sh"]
