# hyways

HYWAY Procons Flutter app with a NestJS backend and Docker-based local database.

## Run the app

For Android emulator:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
```

For a physical Android phone on the same Wi-Fi as your laptop:

```bash
flutter run --dart-define=API_BASE_URL=http://YOUR_LAPTOP_LAN_IP:3000/api/v1
```

If you are running the backend on the same machine as the Flutter app and testing on desktop, the app can fall back to:

```bash
flutter run
```

## Backend

The backend uses Docker for Postgres.

```bash
cd backend
docker compose up -d
```

Then start the NestJS backend separately from the backend folder using your normal dev command.

## Notes

- The app reads `API_BASE_URL` from `--dart-define` when provided.
- Android emulator uses `10.0.2.2` to reach the host machine.
- A physical phone needs a reachable LAN IP or a public backend URL.
