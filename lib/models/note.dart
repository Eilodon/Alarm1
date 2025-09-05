class Note {
  String id;
  String title;
  String content;
  DateTime? remindAt;
  bool daily;
  bool active;
  List<String> tags;


  Note({
    String? id,
    required this.title,
    required this.content,
    this.remindAt,
    this.daily = false,
    this.active = false,
    this.tags = const [],

  });


  factory Note.fromJson(Map<String, dynamic> j) => Note(
        id: j['id'],
        title: j['title'],
        content: j['content'],
        alarmTime: j['alarmTime'] != null ? DateTime.parse(j['alarmTime']) : null,
        daily: j['daily'] ?? false,
        active: j['active'] ?? false,
        tags: (j['tags'] as List<dynamic>? ?? []).cast<String>(),

      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'remindAt': remindAt?.toIso8601String(),
        'daily': daily,
        'active': active,
        'tags': tags,

      };
}
