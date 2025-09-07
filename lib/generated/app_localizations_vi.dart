// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Ghi chú & Nhắc nhở';

  @override
  String get addNoteReminder => 'Thêm ghi chú / nhắc lịch';

  @override
  String get titleLabel => 'Tiêu đề';

  @override
  String get contentLabel => 'Nội dung';

  @override
  String get fieldRequired => 'Không được để trống';

  @override
  String get selectReminderTime => 'Chọn thời gian nhắc';

  @override
  String get cancel => 'Hủy';

  @override
  String get save => 'Lưu';

  @override
  String get noNotes => 'Không có ghi chú';

  @override
  String get settings => 'Cài đặt';

  @override
  String get chooseThemeColor => 'Chọn màu chủ đề';

  @override
  String get lowContrastWarning => 'Màu đã chọn có độ tương phản thấp với chữ';

  @override
  String get changeThemeColor => 'Đổi màu giao diện';

  @override
  String get chooseMascot => 'Chọn mascot';

  @override
  String get changeMascot => 'Thay mascot';

  @override
  String get fontSize => 'Cỡ chữ';

  @override
  String get backupFormat => 'Định dạng sao lưu';

  @override
  String get formatJson => 'JSON';

  @override
  String get formatPdf => 'PDF';

  @override
  String get formatMarkdown => 'Markdown';

  @override
  String get chatAI => 'Chat AI';

  @override
  String get enterMessage => 'Nhập tin nhắn...';

  @override
  String get send => 'Gửi';

  @override
  String get geminiApiKeyNotConfigured => 'Chưa cấu hình khóa API Gemini.';

  @override
  String get noResponse => 'Không có phản hồi.';

  @override
  String geminiError(Object error) {
    return 'Lỗi Gemini: $error';
  }

  @override
  String errorWithMessage(Object error) {
    return 'Lỗi: $error';
  }

  @override
  String get networkError => 'Lỗi mạng. Vui lòng thử lại.';

  @override
  String get noInternetConnection => 'Mất kết nối mạng.';

  @override
  String get internetConnectionRestored => 'Đã kết nối lại.';

  @override
  String get microphonePermissionMessage =>
      'Yêu cầu quyền micro. Vui lòng bật trong Cài đặt.';

  @override
  String get speechNotRecognizedMessage =>
      'Không nhận được giọng nói. Vui lòng thử lại.';

  @override
  String get readNote => 'Đọc Note';

  @override
  String scheduleForDate(Object date) {
    return 'Lịch ngày $date';
  }

  @override
  String get noNotesForDay => 'Không có ghi chú/nhắc lịch cho ngày này';

  @override
  String get addNoteTooltip => 'Thêm ghi chú';

  @override
  String get settingsTooltip => 'Mở cài đặt';

  @override
  String get delete => 'Xóa';

  @override
  String get timeLabel => 'Thời gian';

  @override
  String get pin => 'Ghim';

  @override
  String get share => 'Chia sẻ';

  @override
  String get markDone => 'Đánh dấu xong';

  @override
  String get setReminder => 'Đặt nhắc nhở';

  @override
  String get noteDeleted => 'Đã xóa ghi chú';

  @override
  String get undo => 'Hoàn tác';

  @override
  String get notesExported => 'Đã xuất ghi chú';

  @override
  String get notesImported => 'Đã nhập ghi chú';

  @override
  String get repeatLabel => 'Lặp lại:';

  @override
  String get repeatNone => 'Không';

  @override
  String get repeatEveryMinute => 'Mỗi phút';

  @override
  String get repeatHourly => 'Hàng giờ';

  @override
  String get repeatDaily => 'Hàng ngày';

  @override
  String get repeatWeekly => 'Hàng tuần';

  @override
  String snoozeLabel(Object minutes) {
    return 'Báo lại: $minutes phút';
  }

  @override
  String get imageLabel => 'Ảnh';

  @override
  String get audioLabel => 'Âm thanh';

  @override
  String get exportNotes => 'Xuất ghi chú';

  @override
  String get importNotes => 'Nhập ghi chú';

  @override
  String get tagsLabel => 'Tag';

  @override
  String get allTags => 'Tất cả tag';

  @override
  String get addTag => 'Thêm tag';

  @override
  String get requireAuth => 'Yêu cầu xác thực';

  @override
  String get lockNote => 'Khóa ghi chú';

  @override
  String get pinNote => 'Ghim ghi chú';

  @override
  String get colorLabel => 'Màu';

  @override
  String get authReason => 'Vui lòng xác thực để tiếp tục';

  @override
  String get themeMode => 'Chế độ giao diện';

  @override
  String get light => 'Sáng';

  @override
  String get dark => 'Tối';

  @override
  String get system => 'Hệ thống';

  @override
  String get voiceToNote => 'Giọng nói thành ghi chú';

  @override
  String get stop => 'Dừng';

  @override
  String get speak => 'Nói';

  @override
  String get convertToNote => 'Chuyển thành ghi chú';

  @override
  String convertSpeechPrompt(Object recognized) {
    return 'Chuyển đoạn nói sau thành ghi chú: $recognized';
  }

  @override
  String get offlineMode => 'Chế độ ngoại tuyến';

  @override
  String get scheduled => 'Lên lịch';

  @override
  String get recurring => 'Định kỳ';

  @override
  String get daily => 'Hàng ngày';

  @override
  String get snooze => 'Báo lại';

  @override
  String get done => 'Xong';

  @override
  String get scheduledDesc => 'Thông báo đã lên lịch';

  @override
  String get recurringDesc => 'Thông báo định kỳ';

  @override
  String get dailyDesc => 'Thông báo hàng ngày';

  @override
  String get snoozeDesc => 'Thông báo báo lại';

  @override
  String get aiSuggestionsTitle => 'Gợi ý AI';

  @override
  String get summaryLabel => 'Tóm tắt';

  @override
  String get actionItemsLabel => 'Cần làm';

  @override
  String get datesLabel => 'Ngày';

  @override
  String get authFailedMessage =>
      'Đăng nhập ẩn danh thất bại. Chức năng bị hạn chế.';

  @override
  String get notificationFailedMessage => 'Thiết lập thông báo thất bại.';

  @override
  String get saveNoteFailed => 'Lưu ghi chú thất bại';

  @override
  String get hintReady => 'Sẵn sàng';

  @override
  String get hintArmed => 'Đã gài';

  @override
  String get hintActive => 'Đang hoạt động';

  @override
  String get teachAi => 'Dạy AI';

  @override
  String get teachAiHint => 'Chia sẻ phản hồi hoặc chỉnh sửa';

  @override
  String get submit => 'Gửi';

  @override
  String get feedback => 'Phản hồi';

  @override
  String get savePreset => 'Lưu mẫu';

  @override
  String get insert => 'Chèn';

  @override
  String get replace => 'Thay thế';

  @override
  String get copy => 'Sao chép';

  @override
  String get preview => 'Xem trước';

  @override
  String get backupNow => 'Sao lưu ngay';

  @override
  String get syncStatusIdle => 'Đã đồng bộ';

  @override
  String get syncStatusSyncing => 'Đang đồng bộ...';

  @override
  String get syncStatusError => 'Lỗi đồng bộ';

  @override
  String get showNotes => 'Hiển thị Ghi chú';

  @override
  String get showVoiceToNote => 'Hiển thị Giọng nói thành ghi chú';

  @override
  String get openSettings => 'Mở cài đặt';

  @override
  String get primary => 'Màu chính';

  @override
  String get secondary => 'Màu phụ';

  @override
  String get themeUpdated => 'Đã cập nhật chủ đề';

  @override
  String get notes => 'Ghi chú';

  @override
  String get reminders => 'Nhắc nhở';

  @override
  String get palette => 'Bảng màu';

  @override
  String get searchCommandHint => 'Nhập lệnh...';

  @override
  String get onboardingTakeNotes => 'Ghi chú';

  @override
  String get onboardingTakeNotesDesc => 'Ghi lại suy nghĩ và ý tưởng của bạn.';

  @override
  String get onboardingSetReminders => 'Đặt nhắc nhở';

  @override
  String get onboardingSetRemindersDesc =>
      'Lên lịch báo cho các công việc quan trọng.';

  @override
  String get onboardingCustomize => 'Tùy chỉnh';

  @override
  String get onboardingCustomizeDesc =>
      'Điều chỉnh chủ đề và cỡ chữ theo ý bạn.';

  @override
  String get onboardingSkip => 'Bỏ qua';

  @override
  String get onboardingGetStarted => 'Bắt đầu';
}
