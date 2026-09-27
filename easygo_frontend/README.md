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

## Google Maps

Branch locations can be shown on a map. This is **off until a key is supplied**:
without one the app shows the branch coordinates and says the map is not
configured, rather than drawing an empty map that looks broken.

1. Enable **Maps JavaScript API** (and **Maps SDK for Android** / **Maps SDK for
   iOS** if you build for those) in the Google Cloud console, and create a key.

2. Pass the key at build time:

   ```bash
   flutter run -d chrome --dart-define=GOOGLE_MAPS_API_KEY=your-key
   ```

3. **On the web there is a second step that no build flag covers.** The Maps
   JavaScript API has to be loaded by the browser before the app builds a map, so
   uncomment the `<script>` tag in `web/index.html` and put the same key in it.

A web key is visible to anyone who opens dev tools — that is how Google Maps
works, not a mistake. Restrict it by **HTTP referrer** in the Google Cloud
console rather than trying to hide it. Keys are platform-specific, so an Android
key will not work on the web.

The key is deliberately not stored in the repository.
