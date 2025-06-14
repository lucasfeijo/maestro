# Base image for local builds. Home Assistant's builder overrides this
# when building for each architecture using `build.yaml`.
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.15
ARG BUILD_ARCH
ARG BUILD_VERSION
FROM ${BUILD_FROM}

# Re-declare build arguments for use after the FROM directive.
ARG BUILD_ARCH
ARG BUILD_VERSION
ARG TEMPIO_VERSION
RUN \
    curl -sSLf -o /usr/bin/tempio \
    "https://github.com/home-assistant/tempio/releases/download/${TEMPIO_VERSION}/tempio_${BUILD_ARCH}"

WORKDIR /app
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
