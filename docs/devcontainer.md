# Add-on build container

The add-on now reuses the maestro image published to GitHub Container Registry.

```Dockerfile
FROM ghcr.io/<owner>/maestro:latest
```

When Home Assistant builds the add-on it pulls this image automatically. Local
builds behave the same way:

```bash
docker build -t maestro-addon ./docker
docker run --rm maestro-addon
```
