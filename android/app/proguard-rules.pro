# google_mlkit_text_recognition exposes optional language recognizers as compile-only
# dependencies. Ledgerly uses the Latin recognizer; keep R8 from failing on unused
# optional language modules while preserving the native Latin implementation.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
