class Note {
  String id;
  String title;
  String content;
  DateTime? alarmTime;
  bool daily;
  bool active;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.alarmTime,
    this.daily = false,
    this.active = false,
  });

  factory Note.fromJson(Map<String, dynamic> j) => Note(
        id: j['id'],
        title: j['title'],
        content: j['content'],
        alarmTime: j['alarmTime'] != null ? DateTime.parse(j['alarmTime']) : null,
        daily: j['daily'] ?? false,
        active: j['active'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'alarmTime': alarmTime?.toIso8601String(),
        'daily': daily,
        'active': active,
      };
}
