# MINI-PROJECT SHORT TECHNICAL REPORT

**Course:** Cross-Platform Mobile App Development (VKU)
**Mini-Project Title:** Mini-Project 3: Ledgerly — Receipt OCR & Expense Tracker
**Student:** Dinh Tran Tien Minh — 23IT162
**Submission date:** 09/10/2026

## 1. General information & deliverables

- **GitHub repository:** https://github.com/Minhwritecode/VKU-Expense-OCR
- **Live web demo (Vercel):** https://vku-expense-ocr-michael.vercel.app
- **Demo video:** Supplied separately by the student.
- **Technical report PDF:** `output/pdf/ledgerly-technical-report-part2.pdf`
- **Android APK:** `build/app/outputs/flutter-apk/app-release.apk`
- **Google Play bundle:** `build/app/outputs/bundle/release/app-release.aab`
- **iOS Simulator build:** `build/ios/iphonesimulator/Runner.app`

Ledgerly giải quyết việc nhập chi tiêu từ hóa đơn giấy cho sinh viên VKU và quản lý câu lạc bộ. Người dùng chụp hoặc chọn ảnh hóa đơn, OCR chạy trực tiếp trên thiết bị, ứng dụng trích xuất các trường quan trọng, cho phép người dùng kiểm tra/sửa trước khi lưu, sau đó xem lịch sử và biểu đồ chi tiêu.

Ứng dụng được thiết kế offline-first: dữ liệu receipt và đường dẫn ảnh được lưu cục bộ bằng SQLite, không cần tài khoản hoặc server để sử dụng luồng chính. OCR chỉ đóng vai trò hỗ trợ nhập nhanh; quyết định cuối cùng luôn thuộc về người dùng trong màn hình review.

## 2. Feature implementation checklist

| # | Feature | Status | Evidence / implementation |
|---:|---|:---:|---|
| 1 | Camera/gallery receipt capture | ✅ Complete | `image_picker`, camera/gallery actions and stored receipt photo path. |
| 2 | On-device OCR | ✅ Complete | `google_mlkit_text_recognition` Latin recognizer; no receipt image is uploaded. |
| 3 | Regex and heuristic parser | ✅ Complete | Extracts total, Vietnamese date, merchant and category in `services/ocr_service.dart`. |
| 4 | Review and manual correction | ✅ Complete | Merchant, amount, date, category, note and raw OCR text can be reviewed/edited before save. |
| 5 | Riverpod state management | ✅ Complete | `ReceiptController` with loading, search, filter, save and delete states. |
| 6 | SQLite persistence | ✅ Complete | `ReceiptRepository` performs local CRUD and has a memory fallback for unsupported test environments. |
| 7 | Custom canvas visualization | ✅ Complete | Animated `DonutPainter` and `WeeklyBarPainter` in `widgets/charts.dart`. |
| 8 | Material 3 responsive UI | ✅ Complete | Light/dark themes, mobile NavigationBar, desktop NavigationRail and adaptive content width. |
| 9 | Part 2 routing and forms | ✅ Complete | GoRouter ShellRoute, guarded category query, receipt detail path, validation, focus traversal and future-date guard. |
| 10 | Native platform channel | ✅ Complete | Battery bridge from Android Kotlin and iOS Swift to the Settings screen. |
| 11 | Release and submission artifacts | ✅ Complete with signing note | APK, AAB, iOS Simulator build, technical PDF, demo script, LICENSE and CI workflow. Current local Android artifacts use debug certificate fallback until the student's private keystore is configured. |
| 12 | Motion, splash and loading UX | ✅ Complete | Startup splash, staggered dashboard entry, animated scan/save states, local Lottie loader on mobile and lightweight CustomPainter fallback on Web. |

## 3. Architecture & data flow

```text
Flutter application
        │
        ├── Material 3 UI
        │      ├── responsive NavigationBar / NavigationRail
        │      ├── Dashboard / Receipts / Insights / Settings
        │      └── review sheet, validation and empty/error states
        │
        ├── GoRouter ShellRoute
        │      ├── /                       Dashboard
        │      ├── /receipts               history + filters
        │      ├── /receipts/:receiptId    receipt detail deep link
        │      ├── /insights               custom charts
        │      └── /settings                theme + native battery
        │
        ├── Riverpod ReceiptController
        │      ├── load / search / category filter
        │      └── add / update / delete
        │
        ├── Services
        │      ├── ImagePicker → ML Kit OCR
        │      ├── ReceiptParser → total/date/merchant/category
        │      ├── ReceiptRepository → SQLite CRUD
        │      └── MethodChannel → Kotlin / Swift battery bridge
        │
        └── Local storage
               ├── ledgerly_receipts.db
               └── receipt_photos/
```

### OCR and persistence flow

1. The user opens **Chụp ảnh** or **Thư viện**.
2. `ImagePicker` returns the receipt image path.
3. ML Kit recognizes Latin text on-device.
4. `ReceiptParser` checks labeled totals first, then grouped number patterns such as `42.000` and `1,250,000`.
5. Date, merchant and category heuristics are shown in `ReceiptEditorSheet`.
6. The user corrects any field and saves only after validation passes.
7. Riverpod updates the visible state and SQLite stores the receipt and OCR raw text.

## 4. UX decisions and evidence

Ledgerly intentionally uses a tactile “pocket ledger” visual language instead of a generic AI dashboard: warm paper surfaces, cobalt navigation, orange capture actions, mint/lavender category accents and explicit human review.

```text
┌──────────────────────────────────────────────────────────────┐
│ Tổng quan                                      [Nhập tay]     │
│                                                              │
│ Chào buổi tối 🌙       Sổ chi tiêu của bạn                   │
│ ┌──────────────────────────────────────────────────────────┐ │
│ │ TỔNG THÁNG NÀY                         361.000 đ          │ │
│ │ 7 khoản                         Tổng 720.000 đ            │ │
│ └──────────────────────────────────────────────────────────┘ │
│ Ghi lại trong 10 giây                                        │
│ [ Chụp ảnh ]       [ Thư viện ]       [ Nhập tay ]           │
│                                                              │
│  Nhịp chi tiêu                     [7 ngày qua]              │
│                                                              │
│ Tổng quan        Sổ chi tiêu        Phân tích        Cài đặt  │
└──────────────────────────────────────────────────────────────┘
```

- Capture actions are visible immediately instead of hiding OCR behind a menu.
- The review sheet keeps OCR transparent: users see and can correct merchant, amount, date, category and note.
- Search and category chips stay in one scroll context on mobile.
- Wide layouts use a NavigationRail and a larger content constraint; compact layouts use NavigationBar.
- Light/dark screenshots are stored in `docs/screenshots/dashboard-light.png` and `docs/screenshots/dashboard-dark.png` and are included in the technical PDF.
- Empty, loading, validation and unsupported-platform states have explicit UI feedback.
- Motion is purposeful rather than decorative: the startup splash uses a short fade/scale entrance, dashboard sections enter with a restrained stagger, and async actions replace their icon/label with a clear loading state. `MediaQuery.disableAnimations` is respected for users who request reduced motion.

## 5. Technical challenges & resolutions

### Challenge 1 — OCR output is not reliable enough to save blindly

Receipt layouts vary and OCR may confuse separators. The parser prioritizes labeled totals, removes Vietnamese grouping separators, rejects invalid values in the form and always sends the result through a manual review step.

### Challenge 2 — Vietnamese amount formats

The form accepts values such as `42.000` and `1,250,000`. `parseVndInput` normalizes separators, while the validator requires a positive amount. The saved value is formatted with Vietnamese grouping and `đ`.

### Challenge 3 — Responsive navigation without losing URL state

The first sprint used a tab index. Part 2 moves navigation into GoRouter `ShellRoute`, so route state is addressable. Category filters use a guarded query parameter and a receipt can be opened through `/receipts/:receiptId`.

### Challenge 4 — Native behavior across platforms

`DeviceInfoService` calls `vn.edu.vku/device_info`. Android implements `BatteryManager` in Kotlin; iOS implements `UIDevice.current.batteryLevel` in Swift. Unsupported platforms return a graceful fallback instead of crashing.

### Challenge 5 — Custom visualization without a heavy chart dependency

The category donut and weekly bars are painted with `CustomPainter`, with a short animation from zero to the current values. This keeps the visual style controlled and demonstrates Flutter's rendering layer directly.

### Challenge 6 — Secure release signing

The project includes `android/key.properties.example`, Gradle conditional release signing and `.gitignore` protection for `key.properties` and keystores. A private key is intentionally not stored in the public repository. The current local artifact uses the debug signing fallback for classroom installation only.

## 6. Verification and reproducibility

The following checks were completed:

```bash
dart format lib test
flutter analyze --no-fatal-infos
flutter test
flutter build apk --release --no-pub
flutter build appbundle --release --no-pub
flutter build ios --simulator --no-codesign --no-pub
flutter build web --release --no-pub
```

Results:

- `flutter analyze --no-fatal-infos`: **No issues found**.
- `flutter test`: **4 tests passed**.
- Android release APK: **built successfully**.
- Android AAB: **built successfully**.
- iOS Simulator `.app`: **built successfully**.
- iPhone 15 Pro Max Simulator: **runtime launch verified**.
- Flutter Web release: **built successfully and deployed to Vercel**.
- Physical phone smoke test: **confirmed by the student**.
- Demo video and GitHub repository: **supplied by the student**.

The GitHub Actions workflow at `.github/workflows/flutter.yml` repeats dependency installation, analyzer, tests and a debug APK build on pushes and pull requests.

## 7. Deployment notes

### Android

```bash
# Direct installation / classroom demo
flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk

# Google Play artifact
flutter build appbundle --release
```

### iOS

```bash
# Simulator
flutter run -d <ios-simulator-id>

# Distribution archive after selecting Team in Xcode
flutter build ipa --release
```

The Simulator `.app` is for local testing only. TestFlight/App Store requires an IPA signed by an Apple Developer account. Creating an Android keystore is free; Google Play and Apple Developer account fees are separate store-distribution costs.

### Web / Vercel

The Flutter Web release is deployed as a static build with Vercel:

```bash
flutter build web --release
npx vercel deploy build/web --prod
```

Live URL: **https://vku-expense-ocr-michael.vercel.app**

The Vercel project is named `vku-expense-ocr-michael` and serves the generated `build/web` directory. The current Vercel workspace may have Deployment Protection enabled; disable Vercel Authentication in the project settings when anonymous public access is required.

## 8. Known limitations

- OCR currently uses the Latin ML Kit model, so unusual layouts, blurred images and non-Latin text may need manual correction.
- The local Android release artifact is verified with APK v2 signing but uses the Android Debug certificate until the developer's private upload key is configured.
- The app is offline-first and local-only; cloud synchronization and multi-user account management are outside Mini-Project 3 scope.
- The iOS build currently uses CocoaPods for ML Kit because those plugins do not yet provide Swift Package Manager support.
- The Web build can display the responsive UI and local visualizations, but on-device ML Kit OCR remains an Android/iOS capability; the primary OCR workflow should therefore be demonstrated on a physical phone or simulator.
