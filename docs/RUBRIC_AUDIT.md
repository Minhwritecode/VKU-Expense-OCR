# VKU Expense OCR — rubric audit

Updated: 08/10/2026

| Rubric / deliverable | Evidence | Result |
| --- | --- | --- |
| On-device OCR and heuristics · 3.5 pts | `services/ocr_service.dart`, ML Kit Latin recognizer, camera/gallery, total/date/merchant/category parser, mandatory review sheet | Complete |
| Custom canvas visualization · 2.5 pts | `widgets/charts.dart`, animated `DonutPainter` and `WeeklyBarPainter` | Complete |
| State management and DB · 2.0 pts | `state/receipt_controller.dart`, `services/receipt_repository.dart`, Riverpod StateNotifier, SQLite CRUD and memory fallback | Complete |
| UI/UX polish · 1.0 pt | Material 3, light/dark theme, responsive rail/bar navigation, validation, focus traversal, correction flow | Complete |
| Routing depth | `core/router.dart`: ShellRoute, four destinations, query filter guard, `/receipts/:receiptId` path, transitions | Complete |
| Platform channel | Kotlin `MainActivity`, Swift `AppDelegate`, battery provider and Settings fallback | Complete in source; physical device behavior confirmed by student |
| Release artifact | `build/app/outputs/flutter-apk/app-release.apk`, AAB at `build/app/outputs/bundle/release/app-release.aab`, iOS Simulator `.app` | Build complete; debug certificate fallback until private key is supplied |
| Technical PDF · 2–4 pages | `output/pdf/ledgerly-technical-report-part2.pdf`; rendered and visually checked | Complete |
| Demo video | Supplied by student | Complete externally |
| GitHub repository | Supplied by student: `github.com/Minhwritecode/VKU-Expense-OCR` | Complete externally; local repo includes README, LICENSE, CI workflow |
| Private upload keystore | `android/key.properties.example` + conditional Gradle signing | Intentionally deferred; free to create later, required before public store upload |

## Final quality gate

- `flutter analyze --no-fatal-infos`: **No issues found**.
- `flutter test`: **4 tests passed**.
- `flutter build apk --release --no-pub`: **passed**.
- `flutter build appbundle --release --no-pub`: **passed**.
- `flutter build ios --simulator --no-codesign --no-pub`: **passed**.
- iPhone 15 Pro Max Simulator smoke launch: **passed**; Dashboard rendered and screenshot captured.

The only intentionally deferred item is private release signing. It is not needed for classroom source submission, local APK installation or simulator testing, but it is needed for a store submission. The key must be generated and held by the developer; it should not be generated or stored in the public repository.
