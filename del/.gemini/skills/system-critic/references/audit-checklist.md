# System Critic: Architectural & Operational Audit Checklist

Use this checklist to evaluate any proposed or existing code in the **Curl Financial Tracker** project.

## 🏗️ Architectural Integrity
- [ ] **Offline Only:** Is the feature 100% offline? (Check: No external API calls, no Firebase, no cloud sync).
- [ ] **Persistence:** Does it use `shared_preferences` for data storage? (Check: No SQLite or external DBs).
- [ ] **Data Model:** Do transactions follow the `lib/models/transaction.dart` schema?
- [ ] **Bank Registry:** Are bank names sourced only from `lib/models/bank.dart`? (Check: No hardcoded bank strings outside the registry).

## 🎨 UI & UX (Paper/Slate Standard)
- [ ] **Color Palette:** Does it strictly use White (#FFFFFF), Grey (#F5F5F5/E0E0E0), and Slate (#334155)?
- [ ] **Typography:** Is it using high-contrast, bold styles for amounts and titles?
- [ ] **Physics:** Does every scrollable view use `BouncingScrollPhysics()`?
- [ ] **Interactions:** Do deletions use `Dismissible` with a red accent background?
- [ ] **Currency:** Is the currency symbol ALWAYS `₱`?

## 🇵🇭 Philippine Nuance
- [ ] **Localization:** Is the date/time formatting appropriate for PH users?
- [ ] **Bank Classification:** Do new banks follow the `traditional`/`digital` enum in `bank.dart`?

## 🧹 Minimalism & Logic
- [ ] **State Management:** Does it use standard `StatefulWidget` or `TransactionManager`? (Check: No BLoC/Riverpod).
- [ ] **Cleanliness:** Is the UI cluttered? (Critique: Favor white space over dense dashboards).
