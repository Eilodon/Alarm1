# Kiến trúc

Ứng dụng được chia thành bốn lớp chính.

## Models
Các lớp mô tả dữ liệu như `Note` hay `Reminder`. Chúng ánh xạ trực tiếp tới tài liệu trong Firestore và được chuyển đổi từ/đến định dạng JSON.

## Providers
Quản lý trạng thái và cung cấp dữ liệu phản ứng cho các widget. Mỗi provider theo dõi một tập `Model` và thông báo thay đổi cho giao diện người dùng khi dữ liệu cập nhật.

## Services
Chứa logic nghiệp vụ và tương tác với hệ thống bên ngoài.
- **FirebaseService**: lưu và đọc ghi chú từ Cloud Firestore.
- **NotificationService**: lập lịch và huỷ nhắc nhở bằng thông báo cục bộ.

## Widgets
Các thành phần giao diện người dùng: danh sách ghi chú, màn hình chỉnh sửa, và biểu mẫu đặt nhắc nhở. Widgets nhận dữ liệu từ providers và gửi sự kiện người dùng trở lại.

## Luồng: ghi chú → lưu Firebase → nhắc nhở
1. Người dùng tạo hoặc chỉnh sửa ghi chú trong một widget.
2. Widget gọi provider để cập nhật `Model` tương ứng.
3. Provider sử dụng `FirebaseService` để lưu ghi chú lên Firestore.
4. Sau khi lưu thành công, provider gọi `NotificationService` để lên lịch nhắc nhở.
5. Người dùng nhận thông báo khi đến thời điểm đã đặt.

