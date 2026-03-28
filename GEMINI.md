# Gemini Context: Curl Financial Tracker

This file provides architectural context and rules for AI agents working on the Curl codebase.

## 🏗️ Core Architecture
- **State Management:** Uses standard `StatefulWidget` and a dedicated `TransactionManager` logic class. Do NOT introduce complex state management (BLoC, Riverpod) unless specifically requested.
- **Persistence:** Local-first. All data is stored in `shared_preferences`. Data is serialized/deserialized via `jsonEncode`/`jsonDecode` in `TransactionManager`.
- **Philippine Context:** The app is hardcoded for the PH market. All banks are stored in `lib/models/bank.dart`. Ensure any new banks follow the `traditional`/`digital` enum.

## 🎨 UI & UX Standards
- **Theme:** "Paper/Slate" (Light mode only, White/Grey/Slate colors).
- **Typography:** Uses a bold, high-contrast style for amounts and titles.
- **Interactions:** Use `BouncingScrollPhysics` for all scrollable views. Use `Dismissible` with red accents for deletions.

## 🛠️ Key Files
- `lib/logic/transaction_manager.dart`: Business logic & storage.
- `lib/models/bank.dart`: PH bank registry.
- `lib/main.dart`: Single-file UI container (Onboarding, Home, Analysis).

## 🚀 Guidelines for Changes
1. **No External APIs:** The app must remain 100% offline. Do not add cloud syncing or external trackers.
2. **Minimalism:** Keep the UI clean. Avoid cluttered dashboards. Use white space generously.
3. **PH Nuance:** Currency is always `₱`. Use Philippine bank names as they appear in the `bank.dart` registry.
