# Add-on build container

The add-on uses the official Home Assistant base image
`ghcr.io/home-assistant/amd64-addon-base:latest` for both building and running.
This keeps the environment identical to what Home Assistant expects.

The `docker/Dockerfile` installs the Swift compiler specified in `.swift-version`
and then builds the project:

```Dockerfile
FROM ghcr.io/home-assistant/amd64-addon-base:latest AS build
COPY .swift-version /tmp/.swift-version
RUN SWIFT_VERSION=$(cat /tmp/.swift-version) && \
    curl -sL https://swift.org/builds/swift-${SWIFT_VERSION}-release/ubuntu2004/swift-${SWIFT_VERSION}-RELEASE/swift-${SWIFT_VERSION}-RELEASE-ubuntu20.04.tar.gz \
      | tar xz -C /usr/ && \
    ln -s /usr/swift-${SWIFT_VERSION}-RELEASE-ubuntu20.04/usr/bin/swift /usr/bin/swift
# ... build maestro ...
FROM ghcr.io/home-assistant/amd64-addon-base:latest
```

When Home Assistant builds the add-on it pulls these images automatically. Local
builds behave the same way:

```bash
docker build -t maestro-addon ./docker
docker run --rm maestro-addon
```
