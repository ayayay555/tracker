# CLAUDE.md — Curl Financial Tracker

Context and rules for AI agents working on this codebase.

## Permissions
Full permissions are granted for this project folder (`.claude/settings.local.json`
sets `defaultMode: bypassPermissions`). Work freely — read, edit, run, and commit
without stopping for routine approval. Still confirm before irreversible or
outward-facing actions (force-push, history rewrites, deleting user data).

## What this is
A **Flutter** personal finance / budget tracker. Ships two ways:
- **Web PWA** deployed to GitHub Pages (`.github/workflows/deploy.yml`, base href `/tracker/`).
- **Android APK** (`.github/workflows/build-apk.yml`).

Note: `pubspec.yaml` `name:` is `curl` for historical reasons — the product is "Curl Financial Tracker".

## Architecture
- **State:** Plain `StatefulWidget` + a dedicated `TransactionManager` logic class.
  Do NOT introduce BLoC/Riverpod/Provider unless explicitly requested.
- **Persistence:** Local-first, 100% offline. All data in `shared_preferences`,
  serialized via `jsonEncode`/`jsonDecode` inside `TransactionManager`.
- **No external APIs / no cloud sync / no trackers.** The app must stay fully offline.
- **PH market:** Hardcoded for the Philippines. Currency is always `₱`. Banks live
  in `lib/models/bank.dart` with a `traditional`/`digital` enum — follow it for new banks.

## Key files
- `lib/main.dart` — single-file UI container (Onboarding, Home, Analysis).
- `lib/logic/transaction_manager.dart` — business logic & storage.
- `lib/models/` — `bank.dart` (PH bank registry), `transaction.dart`, `goal.dart`,
  `note.dart`, `todo_item.dart`.

## UI / UX standards
- **Theme:** "Paper/Slate" — light mode only (white / grey / slate).
- **Typography:** bold, high-contrast for amounts and titles; uses `google_fonts`
  (Plus Jakarta Sans).
- **Interactions:** `BouncingScrollPhysics` for scrollables; `Dismissible` with red
  accents for deletions.
- **Layout:** edge-to-edge UI; do not hide the Android nav bar.
- **Minimalism:** keep it clean, generous white space, avoid cluttered dashboards.

## Common commands
- Run web locally: `flutter run -d chrome`
- Analyze: `flutter analyze`
- Build web (as CI does): `flutter build web --base-href "/tracker/"`
- Build APK: `flutter build apk`
- Tests: `flutter test`

## Deploy notes
- Push to `master` triggers the GitHub Pages deploy.
- CI **cache-busts** `main.dart.js` / `flutter_bootstrap.js` with the commit SHA so
  installed PWAs actually pick up new builds (Flutter reuses the same output URLs).
- A service-worker refresh is forced on launch so the PWA auto-updates.

## Working agreements
- Match the existing single-file UI style and naming in `main.dart`.
- Keep currency, bank names, and PH nuance consistent with `bank.dart`.
- Prefer minimal, focused changes; commit atomically when asked to commit.
