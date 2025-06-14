ARG BUILD_FROM
ARG BUILD_ARCH
ARG BUILD_VERSION
FROM ${BUILD_FROM}

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
