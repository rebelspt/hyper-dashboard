# Building & Running

## Prerequisites

- [Dart SDK](https://dart.dev/get-dart) **3.0 or newer**

Check your version:

```bash
dart --version
```

## Install Dependencies

```bash
dart pub get
```

## Run

```bash
dart run bin/hyper_dashboard.dart
```

The server starts on `http://localhost:8080` by default.

### CLI Options

| Flag | Default | Description |
|------|---------|-------------|
| `--config` | `config/hyper-dashboard.yaml` | Path to YAML config file |
| `--port` | `8080` | HTTP port to listen on |
| `--host` | `localhost` | Host/interface to bind to |
| `--assets` | `assets` | Path to the assets directory |

```bash
dart run bin/hyper_dashboard.dart \
  --config /etc/hyper-dashboard/config.yaml \
  --port 3000 \
  --host 0.0.0.0 \
  --assets /opt/hyper-dashboard/assets
```

Use `--host 0.0.0.0` to listen on all interfaces (needed if running behind a reverse proxy or in a container).

## Compile to Native Binary

Compiling produces a self-contained native executable — no Dart SDK required at runtime:

```bash
dart compile exe bin/hyper_dashboard.dart -o build/hyper-dashboard
```

Run it:

```bash
./build/hyper-dashboard --config config/hyper-dashboard.yaml
```

## Docker

A minimal `Dockerfile` using the compiled binary:

```dockerfile
FROM dart:3 AS build
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get
COPY . .
RUN dart compile exe bin/hyper_dashboard.dart -o build/hyper-dashboard

FROM debian:bookworm-slim
WORKDIR /app
COPY --from=build /app/build/hyper-dashboard ./hyper-dashboard
COPY --from=build /app/assets ./assets
EXPOSE 8080
ENTRYPOINT ["./hyper-dashboard", "--host", "0.0.0.0"]
```

```bash
docker build -t hyper-dashboard .
docker run -p 8080:8080 \
  -v "$PWD/config:/app/config:ro" \
  hyper-dashboard
```

### Docker Compose

```yaml
services:
  hyper-dashboard:
    build: .
    ports:
      - "8080:8080"
    volumes:
      - ./config:/app/config:ro
    restart: unless-stopped
```

If the Docker widget is enabled and you want to reach the Docker socket from inside the container, mount it:

```yaml
    volumes:
      - ./config:/app/config:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
```

## Tests

```bash
dart test
```

## Lint

```bash
dart analyze
```

## Project Structure

```
hyper-dashboard/
├── bin/
│   └── hyper_dashboard.dart    # Entry point — parses CLI flags, starts server
├── lib/src/
│   ├── cache/
│   │   └── widget_cache.dart   # Stale-while-revalidate cache per widget
│   ├── config/
│   │   ├── models.dart         # Config data classes
│   │   └── parser.dart         # YAML → config models
│   ├── html/
│   │   ├── h.dart              # HTML DSL (div, span, a, …)
│   │   └── node.dart           # Node types: Text, Raw, Element, Fragment
│   ├── server/
│   │   ├── server.dart         # Shelf router setup
│   │   ├── page_renderer.dart  # Full-page and HTMX partial rendering
│   │   └── player.dart         # Floating media player state
│   ├── services/
│   │   └── services.dart       # HTTP client wrapper
│   ├── theme/
│   │   └── theme.dart          # CSS generation from ThemeConfig
│   └── widgets/
│       ├── widget.dart         # DashboardWidget abstract base
│       ├── widget_frame.dart   # Widget frame with header and refresh
│       ├── registry.dart       # Widget type → class factory
│       ├── render_context.dart # Per-request context (cache, query params, …)
│       └── <name>/             # One directory per widget type
├── assets/
│   └── playlist.js             # Alpine.js media player store
├── config/
│   └── hyper-dashboard.yaml    # Your configuration (git-ignored)
└── test/
    └── html/                   # HTML DSL unit tests
```

## Adding a New Widget

1. Create `lib/src/widgets/<name>/<name>_widget.dart`:

```dart
import '../../html/h.dart';
import '../../services/services.dart';
import '../render_context.dart';
import '../widget.dart';

class MyWidget extends DashboardWidget {
  MyWidget(super.config, super.id);

  @override
  String get type => 'my-widget';

  @override
  String get defaultTitle => 'My Widget';

  @override
  Future<Node> renderBody(Services services, RenderContext ctx) async {
    final someOption = config.options['some-option'] as String? ?? 'default';

    // Use cache for any external data
    final data = await ctx.cache.fetch<String>(
      'key',
      config.cache,
      () => _fetchData(services, someOption),
    );

    return div({'cls': 'my-widget'}, [t(data)]);
  }

  Future<String> _fetchData(Services services, String option) async {
    final resp = await services.httpClient.get(Uri.parse('https://api.example.com/$option'));
    return resp.body;
  }
}
```

2. Register it in `lib/src/widgets/registry.dart`:

```dart
'my-widget': (config, id) => MyWidget(config, id),
```

3. Use it in `config/hyper-dashboard.yaml`:

```yaml
- type: my-widget
  some-option: hello
```
