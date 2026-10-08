# Ledgerly - Technical Report

## 1. Problem and product direction

Ledgerly is an offline-first receipt OCR and expense tracker for VKU students and club managers. The product direction is intentionally calm and practical: a “pocket ledger” visual language with warm paper surfaces, cobalt ink, orange accents and compact interactions. It avoids a generic AI dashboard look by putting the human review step at the center of the flow.

## 2. Processing pipeline

`image_picker` captures a camera or gallery image. `google_mlkit_text_recognition 0.17.1` reads text on-device without uploading the receipt. `ReceiptParser` applies Dart regular expressions and small heuristics to find total amount, Vietnamese date, merchant header and category. The result is shown in a review sheet where the user can correct any field before saving.

The total parser first checks labels such as `Total`, `Thành tiền` and `Tổng cộng`, then falls back to grouped number patterns such as `42.000` or `1,250,000`. Category detection is deliberately transparent and keyword-based so the user can always override it.

## 3. State and persistence

`ReceiptController` is a Riverpod `StateNotifier`. `ReceiptRepository` owns SQLite CRUD through `sqflite`; the table stores merchant, amount, date, category, note, OCR text and receipt photo path. Receipt photos are copied into the app database directory before the parsed record is returned. A small in-memory fallback exists for desktop widget tests where SQLite plugins are unavailable.

## 4. UI/UX and visualizations

The app uses Material 3, responsive navigation rail/mobile navigation bar, a light/dark theme switch, large touch targets and a review-first capture flow. The dashboard includes a summary card, quick capture actions, recent receipts and a weekly rhythm chart. Insights includes a category donut and a weekly bar chart. Both charts are custom `CustomPainter` implementations and animate from an empty state when shown. Source code is split into `core/`, `models/`, `services/`, `state/`, `screens/` and `widgets/` responsibilities.

## 5. Rubric coverage

| Area | Covered by |
| --- | --- |
| OCR, camera, regex extraction | `OcrService`, `ReceiptParser`, `ReceiptEditorSheet` |
| Custom canvas visualization | `DonutPainter`, `WeeklyBarPainter` |
| Riverpod and SQLite CRUD | `ReceiptController`, `ReceiptRepository` |
| Material 3, dark mode, responsive UI | `LedgerlyApp`, `AppShell`, `SettingsPage` |
| Manual correction | `ReceiptEditorSheet` with validation and date picker |

## 6. Verification

The project was verified with `flutter analyze --no-fatal-infos` and `flutter test`. The analyzer reports no issues and all four tests pass, covering Vietnamese currency formatting, OCR parser extraction, dashboard rendering and nested GoRouter routes. Android release-mode APK and AAB compilation passed at `build/app/outputs/flutter-apk/app-release.apk` and `build/app/outputs/bundle/release/app-release.aab`; iOS Simulator compilation passed at `build/ios/iphonesimulator/Runner.app`. The current Android artifacts use the debug certificate fallback, so a private upload keystore is still required before store submission. The student has also confirmed physical-phone testing.

## 7. Part 2 sprint

The second sprint adds a GoRouter ShellRoute, deep-linkable destinations, a guarded receipt category query (`/receipts?category=Ăn%20uống`) and a receipt detail path (`/receipts/:receiptId`) with fade/slide transitions. Navigation state is represented by the URL path instead of only an integer tab index. The manual receipt form now normalizes Vietnamese number grouping, validates positive amounts, prevents future receipt dates, advances focus between fields and confirms saves with a SnackBar. A native MethodChannel named `vn.edu.vku/device_info` demonstrates Android Kotlin and iOS Swift interop by returning the current battery level. Native requirements are Android compile/target SDK 36 and iOS 15.5+.

## 8. Deployment handoff

The project includes `docs/DEPLOYMENT.md` explaining the distinction between APK for direct Android installation, AAB for Google Play, Simulator `.app` for local iOS testing, and IPA/TestFlight for iOS distribution. A private keystore is intentionally not generated in this workspace: creating one is free, but the secret must belong to the developer and must never be committed to GitHub.
