class Note {

  final String id;
  final String title;
  final String content;
  final DateTime? remindAt;
  final bool daily;
  final bool active;
  final List<String> tags;
  final int snoozeMinutes;

  const Note({
    required this.id,

    required this.title,
    required this.content,
    this.remindAt,
    this.daily = false,
    this.active = false,
    this.tags = const [],
    this.snoozeMinutes = 0,
  });

  factory Note.fromJson(Map<String, dynamic> j) => Note(

        id: j['id'] as String,
        title: j['title'] as String,
        content: j['content'] as String,
        remindAt: j['remindAt'] != null
            ? DateTime.parse(j['remindAt'])
            : null,

        daily: j['daily'] ?? false,
        active: j['active'] ?? false,
        tags: (j['tags'] as List<dynamic>? ?? []).cast<String>(),
        snoozeMinutes: j['snoozeMinutes'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'remindAt': remindAt?.toIso8601String(),
        'daily': daily,
        'active': active,
        'tags': tags,
        'snoozeMinutes': snoozeMinutes,
      };
}

