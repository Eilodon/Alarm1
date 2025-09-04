class Note {
  String id;
  String title;
  String content;
  DateTime? alarmTime;
  bool daily;
  bool active;
  /// Minutes to postpone a notification when snoozed.
  int snoozeMinutes;

  Note({
    String? id,
    required this.title,
    required this.content,
    this.alarmTime,
    this.daily = false,
    this.active = false,
    this.snoozeMinutes = 0,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  factory Note.fromJson(Map<String, dynamic> j) => Note(
        id: j['id'],
        title: j['title'],
        content: j['content'],
        alarmTime: j['alarmTime'] != null ? DateTime.parse(j['alarmTime']) : null,
        daily: j['daily'] == 1 || j['daily'] == true,
        active: j['active'] == 1 || j['active'] == true,
        snoozeMinutes: j['snoozeMinutes'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'alarmTime': alarmTime?.toIso8601String(),
        'daily': daily ? 1 : 0,
        'active': active ? 1 : 0,
        'snoozeMinutes': snoozeMinutes,
      };
}
