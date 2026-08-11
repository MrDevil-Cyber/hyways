# HYWAY Backend

NestJS + PostgreSQL + Prisma API for the HYWAY Flutter application.

## Local setup

1. Copy `.env.example` to `.env` and replace all secrets.
2. Start PostgreSQL: `docker compose up -d postgres`.
3. Generate Prisma client: `npm run prisma:generate`.
4. Create migration: `npm run prisma:migrate -- --name init`.
5. Seed admin and products: `npm run prisma:seed`.
6. Start API: `npm run start:dev`.

API base: `http://localhost:3000/api/v1`

Swagger: `http://localhost:3000/api/docs`

For a physical Android phone during local development, run this from the project
root after connecting USB:

```powershell
powershell -ExecutionPolicy Bypass -File .\tool\start_hyway_android.ps1 -RunApp
```

`adb reverse` USB reconnect ke baad Android se remove ho jata hai. Development
machine par backend aur phone tunnel ko automatically restore karne ke liye
one-time autostart setup run karein:

```powershell
powershell -ExecutionPolicy Bypass -File .\tool\install_hyway_dev_autostart.ps1
```

The background bridge checks every two seconds and recreates
`tcp:3000 -> tcp:3000` whenever an authorized Android phone reconnects. Shipped
builds must use a hosted HTTPS `API_BASE_URL`; the USB bridge is development-only.

The helper starts the API when needed and restores the transient ADB reverse
tunnel used by the app's localhost development URL.

## Initial endpoints

- `GET /api/v1/health`
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/refresh`
- `GET /api/v1/auth/me`
- `POST /api/v1/auth/logout`
- `GET /api/v1/products`
- `GET /api/v1/products/:slug`
- Product create/update/delete routes (admin)
- `POST /api/v1/inquiries`
- Inquiry list/status routes (admin)

## Persistent authentication

Login and registration create an independent database-backed session per device.
Access tokens are short-lived; refresh tokens rotate atomically and use a unique
session/token ID. The Flutter app stores the token pair in the platform secure
keystore, silently refreshes a `401` once, and restores the session after restart.
Logout revokes that device session immediately. The default refresh lifetime is
30 days and slides forward when an active session refreshes.

## Authenticated services endpoints

Every route below requires an access token in the `Authorization: Bearer <token>`
header. Records are always scoped to the authenticated user.

- `GET /api/v1/services/machines`
- `POST /api/v1/services/machines`
- `GET /api/v1/services/requests`
- `POST /api/v1/services/requests`
- `GET /api/v1/services/scans`
- `POST /api/v1/services/scans`
- `GET /api/v1/services/space-assessments`
- `POST /api/v1/services/space-assessments`

Space measurements accept `MM` or `FT`. The API normalizes them to millimetres,
calculates and persists a deterministic preliminary machine envelope, and returns
the recommendation with a generic machine type and a mandatory engineering-review
disclaimer. An exact model is never claimed unless certified catalogue dimensions
are available. The mobile app must display this as preliminary guidance rather
than a final installation approval.
