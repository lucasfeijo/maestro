# Add-on build container

The add-on compiles using the official Swift image and then runs on the Home Assistant base image.

```Dockerfile
FROM swift:6.1-focal AS build
# ... build maestro ...
FROM ghcr.io/home-assistant/amd64-addon-base:latest
```

When Home Assistant builds the add-on it pulls these images automatically. Local
builds behave the same way:

```bash
docker build -t maestro-addon ./docker
docker run --rm maestro-addon
```
