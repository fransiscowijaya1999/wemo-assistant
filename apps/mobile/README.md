# wemo_clerk

The **clerk** Android app for the wemo parts-identification assistant — a read-only,
offline-first catalog browser. It keeps a local SQLite (drift) replica of the backend
catalog, syncs deltas when online, and offers keyword/visual lookup plus an online-only
AI assistant. It never writes to the master (authorization invariant — see the repo
`CLAUDE.md`).

## Prerequisites

This PC already has the toolchain: Flutter, the Android SDK, and a Pixel 9 emulator (AVD).

```bash
flutter --version        # confirm Flutter is on PATH
flutter doctor           # Android toolchain + emulator should be green
```

If deps are missing after a fresh checkout:

```bash
cd apps/mobile
flutter pub get
```

## Running on the emulator

The app needs the backend reachable, then the emulator, then the app.

### 1. Start the backend (from `apps/backend`, on this PC)

```bash
cd apps/backend
bun run dev              # wrangler dev — serves the Worker on http://localhost:8787
```

Leave it running. The clerk endpoints (`GET /sync`, image GET, `POST /chat`, `GET /health`)
are what the app talks to.

### 2. Launch the Android emulator

```bash
flutter emulators                        # list available AVDs
flutter emulators --launch <avd_id>      # e.g. the Pixel 9 AVD
flutter devices                          # confirm it shows up (emulator-5554)
```

### 3. Run the app (from `apps/mobile`)

```bash
cd apps/mobile
flutter run              # builds, installs, and hot-reloads on the emulator
```

Hot reload: press `r` in the `flutter run` console; hot restart: `R`; quit: `q`.

## First-run setup (Sync screen)

The base URL and clerk key are **entered on-device** (stored in shared_preferences) —
nothing is compiled into the APK. Open the **Sync** tab:

- **Backend URL** — defaults to `http://10.0.2.2:8787`. `10.0.2.2` is the emulator's alias
  for the host PC's `localhost`, so it reaches `wrangler dev` out of the box. Point it at
  the deployed Worker for real use. (A physical device on the same LAN needs the PC's LAN IP
  instead, and the backend served on `0.0.0.0`.)
- **API key** — the backend `CLERK_TOKEN`. Locally this is `dev-clerk-key` (set in
  `apps/backend/.dev.vars`). Without it the backend returns **401** on `/sync` and `/chat`
  and the app shows a "Not authorized" banner. The admin token is also accepted.

Then tap **Sync now** (or **Force full sync**) to pull the catalog. Row counts per table and
last-sync freshness are shown on the same screen. Once synced, Browse / Search work fully
offline; the Assistant needs the backend online (and a chat provider key on the backend).

## Verifying a change

Follow the emulator recipe above, then drive the affected flow and watch it on-screen. A
typical smoke pass: **Sync now** → **Browse** a machine → open a diagram, tap a dot → **Search**
a part number (dash-less is fine) → **Assistant** ask a question (needs backend online). Kill
`wrangler dev` to confirm the offline strip appears and local browse still works.

## Integration tests

```bash
cd apps/mobile
flutter test                                   # unit/widget tests
flutter test integration_test                  # on-emulator integration tests (needs a device)
```

## Common issues

- **`flutter devices` shows nothing** — the emulator hasn't finished booting, or no AVD was
  launched. Re-run `flutter emulators --launch <avd_id>` and wait for the home screen.
- **Blank/failed sync, 401** — API key missing or wrong on the Sync screen (backend
  `CLERK_TOKEN`), or the backend isn't running.
- **Connection refused / offline strip that won't clear** — the Backend URL is wrong. From the
  emulator the PC is `10.0.2.2`, **not** `localhost` or `127.0.0.1` (those point at the emulator
  itself). Confirm `wrangler dev` is up on port `8787`.
- **Cleartext HTTP blocked** — only whitelisted local dev hosts allow plain `http://`; a remote
  backend must be `https://`.
