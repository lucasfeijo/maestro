ARG MAESTRO_IMAGE
ARG BUILD_ARCH
ARG BUILD_VERSION
FROM ${MAESTRO_IMAGE}

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
