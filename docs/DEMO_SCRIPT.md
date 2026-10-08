# Ledgerly — kịch bản demo 2–3 phút

## 0:00–0:15 — Mở đầu

Giới thiệu Ledgerly là sổ chi tiêu offline-first cho sinh viên VKU: chụp hóa đơn, OCR ngay trên thiết bị, kiểm tra lại dữ liệu và xem xu hướng chi tiêu.

## 0:15–0:45 — Quét hóa đơn

1. Từ Dashboard, nhấn **Quét hóa đơn**.
2. Chụp một receipt hoặc chọn ảnh từ thư viện.
3. Chờ ML Kit nhận dạng offline.
4. Chỉ ra các trường merchant, total, date và category được tự động điền.

## 0:45–1:10 — Review và sửa tay

1. Nhấn vào ô merchant để minh họa focus traversal.
2. Thử nhập amount không hợp lệ để hiển thị validation.
3. Nhập số tiền dạng `42.000` hoặc `1,250,000`, chọn ngày, thêm note.
4. Nhấn **Lưu giao dịch** và chỉ ra SnackBar xác nhận.

## 1:10–1:35 — Lịch sử và tìm kiếm

Mở **Giao dịch**, tìm theo merchant/note, lọc theo category và mở lại một receipt để chỉnh sửa hoặc xóa. Nhấn nút thêm để tạo một giao dịch thủ công.

## 1:35–2:00 — Insights

Mở **Insights**, chỉ ra donut chart theo category và weekly bar chart. Nhấn **Tuần này / Tháng này** để đổi khoảng thời gian và giải thích rằng biểu đồ được vẽ bằng `CustomPainter`.

## 2:00–2:20 — Responsive và dark mode

Resize cửa sổ desktop hoặc xoay simulator để minh họa NavigationRail trên màn hình rộng và NavigationBar trên mobile. Vào Settings, bật dark mode và đổi theme accent.

## 2:20–2:35 — Native bridge và kết thúc

Ở Settings, chỉ ra số pin được đọc qua `MethodChannel` từ Kotlin/Android hoặc Swift/iOS. Kết thúc bằng câu: dữ liệu được lưu SQLite cục bộ, OCR không cần gửi ảnh lên server.

> Khi quay demo, dùng một receipt mẫu không chứa thông tin cá nhân thật. Bản APK hiện là release-mode nhưng còn dùng debug signing của starter project; cần ký lại bằng private keystore trước khi nộp store.
