# maestro
Home assistant lights orchestrator

## Running the server

Build and run the executable with Swift Package Manager. You can provide the
Home Assistant base URL and an optional long‑lived access token:

```bash
swift run maestro --baseurl http://homeassistant.local:8123/ --token YOUR_TOKEN
```

The package builds on Linux and macOS. On macOS the POSIX server code uses the
`Darwin` module, so the same command works there as well.

- `--baseurl` – base URL for the Home Assistant instance. The default is
  `http://homeassistant.local:8123/`.
- `--token` – long lived Home Assistant token used for API calls. If omitted the
  requests are sent without authentication.

## Compiling on macOS

See [docs/compile-macos.md](docs/compile-macos.md) for instructions on building
this package using Swift Package Manager on macOS.
