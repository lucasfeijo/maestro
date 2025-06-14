ARG BUILD_FROM
ARG SWIFT_VERSION=6.1

# Build stage
FROM swift:${SWIFT_VERSION} AS builder
WORKDIR /app
COPY Package.swift .
COPY Sources Sources
RUN swift build --configuration release

# Runtime stage
FROM ${BUILD_FROM}
ENTRYPOINT ["/init"]

COPY maestro/run.sh /run.sh
RUN chmod +x /run.sh
COPY --from=builder /app/.build/release/maestro /usr/local/bin/maestro
CMD ["/run.sh"]
