# Ledgerly - Receipt OCR & Expense Tracker

Mini-project Flutter Week 07–08 for VKU. Ledgerly is a small, offline-first expense book for students: take a receipt photo, recognize its text on-device, review the extracted values, and keep a searchable local history.

## What is included

- On-device OCR with `google_mlkit_text_recognition ^0.17.1` and camera/gallery capture with `image_picker`.
- A Dart regex/heuristic parser for merchant, Vietnamese date and total amount, plus category guesses.
- A review-and-correct sheet before saving; users can edit merchant, amount, date, category and note.
- Riverpod 2 state management and persistent SQLite CRUD with `sqflite`.
- Receipt photo path persistence under the app database directory.
- Animated donut and weekly bar charts drawn with `CustomPainter`.
- Material 3 responsive layout, desktop navigation rail, mobile navigation bar, dark mode and accessibility-friendly touch targets.
- Declarative GoRouter navigation with animated route transitions for `/`, `/receipts`, `/insights` and `/settings`.
- ShellRoute navigation with guarded category query filters and receipt detail path parameters such as `/receipts/42`.
- Validated manual-entry flow that accepts Vietnamese number grouping (`42.000`, `1,250,000`) and rejects invalid/non-positive amounts.
- Platform-channel demo: `vn.edu.vku/device_info` reports battery level from Android Kotlin and iOS Swift into the Settings screen.
- Seeded local demo data so the dashboard is useful on first launch; all seeded entries can be edited or deleted.

## Run

```bash
flutter pub get
flutter run
```

The OCR flow is intended for Android/iOS physical devices because ML Kit is a native on-device plugin. Camera and photo permissions are already declared for Android and iOS. Current native requirements are Android compile/target SDK 36 and iOS 15.5+.

## Verification

```bash
flutter analyze --no-fatal-infos
flutter test
flutter build apk --release
flutter build ios --simulator --no-codesign
```

## Project mapping to the rubric

The Flutter source is organized by responsibility: `core/` for theme and routing, `models/` for domain data, `services/` for OCR/database/native bridges, `state/` for Riverpod controllers, `screens/` for pages, and `widgets/` for reusable UI and charts.

| Rubric | Implementation |
| --- | --- |
| OCR & heuristics | `OcrService`, `ReceiptParser`, camera/gallery flow |
| Custom canvas | `DonutPainter`, `WeeklyBarPainter` |
| State & DB | `ReceiptController`, `ReceiptRepository`, Riverpod + SQLite |
| UI/UX | Material 3 theme, responsive navigation, dark mode, review sheet |
| Part 2 routing & validation | `ledgerlyRouter`, animated route pages, `parseVndInput`, form validators |
| Platform channels | `DeviceInfoService`, `MainActivity.kt`, `AppDelegate.swift` |

## Deployment

See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) for Android APK/AAB, iOS Simulator/IPA, keystore safety and the distinction between local testing and store distribution.

## Part 2 run targets

```bash
# Android emulator or USB device
flutter devices
flutter run -d <android-device-id>

# iPhone Simulator
open -a Simulator
flutter devices
flutter run -d <simulator-id>
```

`npx expo start` is not used because this is a Flutter project, not React Native/Expo.

## Submission helpers

- Technical report PDF: `output/pdf/ledgerly-technical-report-part2.pdf`
- Rubric audit: `docs/RUBRIC_AUDIT.md`
- Demo shot list: `docs/DEMO_SCRIPT.md`
- The generated APK is release-mode but currently inherits the starter project's debug signing configuration; create a private keystore before store submission.
- `LICENSE`, `android/key.properties.example` and `.github/workflows/flutter.yml` are included for repository handoff and repeatable quality checks.
