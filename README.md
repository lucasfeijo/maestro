# maestro
Home assistant lights orchestrator

## Running the server

Build and run the executable with Swift Package Manager. You can provide the
Home Assistant base URL and an optional long‑lived access token:

```bash
swift run maestro --baseurl http://homeassistant.local:8123/ --token YOUR_TOKEN
```

- `--baseurl` – base URL for the Home Assistant instance. The default is
  `http://homeassistant.local:8123/`.
- `--token` – long lived Home Assistant token used for API calls. If omitted the
  requests are sent without authentication.
