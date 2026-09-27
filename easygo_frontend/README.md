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

## Push notifications

Android and iOS can be sent a push, so a notification reaches the phone without
the app being open. On the web this is off — a web push needs a service worker
and a VAPID key, which is a different piece of work, and doing it halfway would
look as though it should work and quietly never arrive.

**The app half needs nothing configured.** `android/app/google-services.json`
ships with the repository and the Google services plugin reads it at build time.
Firebase is started in `main()`; if that fails, the app runs exactly as before
and simply cannot be pushed to.

**The server half is optional and off by default.** The API sends a push from
inside the same call that writes the notification, so nothing can be added later
that reaches the list and forgets the phone. It needs a service account key,
which is a different file from `google-services.json` and the opposite kind of
thing — see `easygo-backend/.env.example` for where it goes and why it is
git-ignored. Without it, everything works and nothing is pushed.

Two behaviours worth knowing when reading the code:

- **Nothing about push can break anything else.** `PushService` on the phone and
  `sendPushToUser` on the server both return rather than throw. A push is a
  second way of being told something the app already knows, so a phone with no
  Google Play services, a declined permission, or a server with no credential
  must behave like any other.
- **A push arriving while the app is open is shown as an in-app banner, not a
  system notification.** Android draws nothing for a foregrounded app, and a
  system notification for something the reader is already looking at is noise.
  Doing it as a real notification needs a local-notifications plugin with its own
  native configuration, which is not worth a second dependency for one banner.

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
