# Build stage
FROM swift:5.9 as build
WORKDIR /build
COPY .. .
RUN swift build -c release

# Runtime stage
FROM debian:stable-slim
WORKDIR /app
COPY --from=build /build/.build/release/maestro /usr/local/bin/maestro
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh
ENTRYPOINT ["/usr/local/bin/run.sh"]
