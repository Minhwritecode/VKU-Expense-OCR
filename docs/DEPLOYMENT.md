# Ledgerly — build và deploy thực tế

Ledgerly là Flutter mobile app. “Deploy” không phải là chạy `expo start`; mỗi nền tảng nhận một loại artifact khác nhau.

## Android

### Chạy thử

```bash
flutter devices
flutter run -d <android-device-id>
```

### Chia sẻ nội bộ / nộp bài

APK cài trực tiếp:

```bash
flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Artifact nên dùng khi đưa lên Google Play là AAB:

```bash
flutter build appbundle --release
```

File đầu ra nằm ở `build/app/outputs/bundle/release/app-release.aab`.

APK hiện tại build được, nhưng trước khi public cần thay debug signing bằng private upload key. Keystore tự tạo không mất phí; tuyệt đối không commit `*.jks`, `key.properties` hoặc password vào GitHub.

Project đã có sẵn `android/key.properties.example` và Gradle sẽ tự dùng release key khi file local `android/key.properties` tồn tại. Tạo key trên máy cá nhân bằng:

```bash
keytool -genkeypair -v \
  -keystore "$HOME/ledgerly-upload.jks" \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias ledgerly-upload
cp android/key.properties.example android/key.properties
```

Sau đó thay các giá trị `CHANGE_ME` và đường dẫn keystore trong `android/key.properties`. Nếu file chưa tồn tại, local build vẫn fallback về debug signing để phục vụ demo; đó không phải cấu hình được chấp nhận cho public store.

## iOS

### Simulator

```bash
open -a Simulator
flutter run -d <ios-simulator-id>
```

### iPhone thật / TestFlight

Mở `ios/Runner.xcworkspace` bằng Xcode, chọn Team và Bundle Identifier, sau đó:

```bash
flutter build ipa --release
```

Xcode Organizer dùng archive đó để upload lên App Store Connect và phân phối qua TestFlight hoặc App Store. Bản Simulator `.app` không upload lên App Store được.

## Chi phí thực tế

- Flutter SDK, Android Studio, Xcode, APK nội bộ và keystore tự tạo: không mất phí cấp artifact.
- Google Play Console: tài khoản developer có phí đăng ký một lần 25 USD theo tài liệu chính thức của Google.
- Apple Developer Program: 99 USD mỗi năm để phân phối qua TestFlight/App Store. Tài khoản Apple miễn phí vẫn cho phép phát triển và test cá nhân với giới hạn riêng.
- Nếu chỉ demo/nộp source cho giảng viên, chưa cần đăng store và chưa cần mua các tài khoản này.

## Checklist release an toàn

1. Tạo upload keystore riêng trên máy cá nhân.
2. Lưu password trong secret manager hoặc file local không commit.
3. Cấu hình `key.properties` và Gradle signing ở máy build.
4. Chạy `flutter clean`, `flutter pub get`, test, rồi build AAB/IPA.
5. Kiểm tra OCR camera, permission, SQLite và ảnh receipt trên thiết bị thật.
6. Upload AAB lên Play Console hoặc IPA qua Xcode Organizer.
