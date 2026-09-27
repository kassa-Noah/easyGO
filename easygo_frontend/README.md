# easygo_frontend

The customer app, the agency console and the administrator console, in one
Flutter app. Which one you get depends on the role of the account that signs in.

## Running it

The backend has to be running first (`easygo-backend`, `npm run dev`, port 5000).
The app reads it from `lib/core/network/api_config.dart`, which points at
`http://localhost:5000/api`.

```bash
flutter run -d chrome
```

## Branch maps

A branch with coordinates is drawn on a map, using `flutter_map` and raster
tiles from OpenStreetMap. **There is no key to obtain or configure**, which is
the reason for this choice: the app works the same on every platform out of the
box, and there is no unconfigured state to explain to the reader.

One thing to know before shipping. OpenStreetMap's tile server is donated
capacity that is free to use but not free of rules:

- It asks to be identified. `BranchMap` passes `userAgentPackageName` for this.
  The default is `unknown`, which is a way to be blocked without being told why.
- It requires the attribution in the map's corner. `BranchMap` draws it with
  `SimpleAttributionWidget`, which puts the credit on screen rather than behind
  a button. **Do not remove it**; the credit is a condition of using the tiles,
  not decoration.
- Its tile usage policy forbids heavy or bulk use. A deployment with real
traffic should run its own tile server and pass it to `BranchMap`:

  ```dart
  BranchMap(points: points, tileServerUrl: 'https://tiles.example.com/{z}/{x}/{y}.png')
  ```

  Self-hosted tiles, or a paid tile provider, lift the traffic limit without
  changing the widget.

[The tile usage policy](https://operations.osmfoundation.org/policies/tiles/)
is the authoritative source on the limits.
