# Build stage
FROM swift:6.1-focal AS build
WORKDIR /build
COPY .. .
RUN swift build -c release

# Runtime stage
FROM ghcr.io/home-assistant/amd64-addon-base:latest
WORKDIR /app
COPY --from=build /build/.build/release/maestro /usr/local/bin/maestro
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh
ENTRYPOINT ["/usr/local/bin/run.sh"]
