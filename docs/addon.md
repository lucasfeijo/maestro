# Running maestro as a Home Assistant Add-on

This document outlines a high-level plan for packaging and running the `maestro` Swift program as a Home Assistant add-on. The goal is to build the project into a Docker-based add-on that can be installed from a custom repository and configured with command line arguments.

## 1. Add-on directory structure

Create an `addon` directory in this repository with the following files:

```
addon/
├── Dockerfile
├── run.sh
└── config.json
```

- **Dockerfile** – builds the Swift project and defines the container runtime.
- **run.sh** – entrypoint script that starts `maestro` using options supplied by the user.
- **config.json** – Home Assistant add-on manifest with option schema.

Home Assistant expects this structure when cloning the repository as an add-on source.

## 2. Dockerfile

The Dockerfile should:

1. Use the Home Assistant add-on base image (`ghcr.io/home-assistant/amd64-addon-base:latest`) as both the build and runtime stage.
2. Copy `.swift-version` and install the matching Swift release:
   ```Dockerfile
   COPY .swift-version /tmp/.swift-version
   RUN SWIFT_VERSION=$(cat /tmp/.swift-version) && \
       curl -sL https://swift.org/builds/swift-${SWIFT_VERSION}-release/ubuntu2004/swift-${SWIFT_VERSION}-RELEASE/swift-${SWIFT_VERSION}-RELEASE-ubuntu20.04.tar.gz \
         | tar xz -C /usr/ && \
       ln -s /usr/swift-${SWIFT_VERSION}-RELEASE-ubuntu20.04/usr/bin/swift /usr/bin/swift
   ```
3. Copy the repository into the container and run `swift build -c release` to produce the `maestro` binary.
4. Copy the compiled `maestro` binary and the `run.sh` script into the runtime image.
5. Set `run.sh` as the container entrypoint.

This multi-stage build keeps the final image small while compiling the Swift code during the build step.

## 3. Entrypoint script

`run.sh` reads the add-on options provided by Home Assistant and forwards them to `maestro`. Example contents:

```bash
#!/bin/bash
set -e

ARGS=()
[ -n "$BASEURL" ] && ARGS+=(--baseurl "$BASEURL")
[ -n "$TOKEN" ] && ARGS+=(--token "$TOKEN")
[ "$SIMULATE" = "true" ] && ARGS+=(--simulate)
[ "$NO_NOTIFY" = "true" ] && ARGS+=(--no-notify)
[ -n "$PROGRAM" ] && ARGS+=(--program "$PROGRAM")

exec /usr/local/bin/maestro "${ARGS[@]}"
```

The environment variables (`BASEURL`, `TOKEN`, etc.) are injected by Home Assistant based on user configuration options.

## 4. config.json

The add-on manifest defines the image, startup behavior and option schema. Example:

```json
{
  "name": "Maestro",
  "version": "0.1.0",
  "slug": "maestro",
  "description": "Home Assistant lights orchestrator",
  "startup": "application",
  "boot": "auto",
  "build_from": {
    "amd64": "ghcr.io/home-assistant/amd64-addon-base:latest"
  },
  "options": {
    "baseurl": "http://homeassistant.local:8123/",
    "token": "",
    "simulate": false,
    "no_notify": false,
    "program": "default"
  },
  "schema": {
    "baseurl": "str?",
    "token": "str?",
    "simulate": "bool",
    "no_notify": "bool",
    "program": "str?"
  },
  "image": "local/maestro"
}
```

Users can adjust the options in the Home Assistant UI. They are exported as environment variables with the same names in uppercase.

## 5. Repository configuration

To distribute the add-on, include a `repository.json` at the repository root:

```json
{
  "name": "Maestro Add-ons",
  "url": "https://github.com/lucasfeijo/maestro",
  "maintainer": "lucasfeijo"
}
```

Home Assistant uses this file when adding the repository URL to the Add-on Store.

## 6. Installing the add-on

1. Push the repository (including the new `addon` directory and `repository.json`) to GitHub or another git host.
2. In Home Assistant, navigate to **Settings → Add-ons → Add-on Store → Repositories** and add the repository URL.
3. The "Maestro" add-on will appear in the store. Install it and configure the options (base URL, token, etc.).
4. Start the add-on. Home Assistant will pull/build the Docker image and run `maestro` inside the container.

## 7. Local development

For local testing without Home Assistant you can build the Docker image directly:

```bash
docker build -t maestro-addon ./addon
docker run --rm -e BASEURL=http://hass.local:8123/ -e TOKEN=YOUR_TOKEN maestro-addon
```

This mimics the environment that Home Assistant provides when running the add-on.

## 8. Future considerations

- Automate releases by pushing versioned Docker images to a registry.
- Extend `config.json` with more options as new command line arguments are added to `maestro`.
- Write documentation in the main README referencing this add-on guide.

