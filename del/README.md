# del/ — quarantined / unused

This folder holds code and assets that are **not used** by the app, moved out of
the way to keep the repo clean and readable. Nothing here is referenced by the
build (web / Android / iOS). It is kept (rather than deleted) for reference and
easy restore.

| Item | Why it's here |
|------|---------------|
| `linux/`, `macos/`, `windows/` | Flutter desktop scaffolding. The app ships **web + Android + iOS** only (CI builds `web` and `apk`); desktop was never targeted. |
| `skills/`, `system-critic/`, `system-critic.skill` | Stray AI-tooling files committed to the repo root. The active Gemini config lives in `.gemini/`. |
| `test/widget_test.dart` | The default Flutter *counter* smoke test (`find.text('0')`, `Icons.add`). This app has no counter, so the test was a broken placeholder. |
| `img/mascot.png`, `img/preview.png` | Image files not referenced anywhere. Only `img/newmascot.png` (app/launcher icon) and `img/mockups.png` (README) are used. |
| `dead-code/transaction_manager_removed.dart` | Methods/fields removed from `lib/logic/transaction_manager.dart` that had zero callers (category-budgets feature, category analytics, `getTransactionsByBank`, `addCustomBank`). |

To restore something, move it back with `git mv del/<path> <path>` (and re-add
desktop platforms to `.metadata` / re-wire any removed code if needed).
