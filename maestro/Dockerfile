ARG BUILD_FROM
FROM ${BUILD_FROM}

# Build stage
FROM swift:5.9-focal AS swift-build
WORKDIR /build
COPY .. .
RUN swift build -c release

# Runtime stage
FROM ${BUILD_FROM}
WORKDIR /app
COPY --from=swift-build /build/.build/release/maestro /usr/local/bin/maestro
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Labels
LABEL \
    io.hass.name="Maestro" \
    io.hass.description="Maestro add-on for Home Assistant" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION}

# Start the add-on
ENTRYPOINT ["/usr/local/bin/run.sh"]
