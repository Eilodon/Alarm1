class Note {
  String id;
  String title;
  String content;
  DateTime? alarmTime;
  bool daily;
  bool active;
  int snoozeMinutes;
  List<String> tags;
  List<String> attachments;
  DateTime? updatedAt;

  Note({
    String? id,
    required this.title,
    required this.content,
    this.alarmTime,
    this.daily = false,
    this.active = false,
    this.snoozeMinutes = 5,
    this.tags = const [],
    this.attachments = const [],
    this.updatedAt,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  factory Note.fromJson(Map<String, dynamic> j) => Note(
        id: j['id'],
        title: j['title'],
        content: j['content'],
        alarmTime:
            j['alarmTime'] != null ? DateTime.parse(j['alarmTime']) : null,
        daily: j['daily'] ?? false,
        active: j['active'] ?? false,
        snoozeMinutes: j['snoozeMinutes'] ?? 5,
        tags: (j['tags'] as List<dynamic>? ?? []).cast<String>(),
        attachments:
            (j['attachments'] as List<dynamic>? ?? []).cast<String>(),
        updatedAt:
            j['updatedAt'] != null ? DateTime.parse(j['updatedAt']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'alarmTime': alarmTime?.toIso8601String(),
        'daily': daily,
        'active': active,
        'snoozeMinutes': snoozeMinutes,
        'tags': tags,
        'attachments': attachments,
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
