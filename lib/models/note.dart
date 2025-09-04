class Note {
  String id;
  String title;
  String content;
  DateTime? remindAt;
  bool daily;
  bool active;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.remindAt,
    this.daily = false,
    this.active = false,
  });

  factory Note.fromJson(Map<String, dynamic> j) => Note(
        id: j['id'],
        title: j['title'],
        content: j['content'],
        remindAt: j['remindAt'] != null ? DateTime.parse(j['remindAt']) : null,
        daily: j['daily'] ?? false,
        active: j['active'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'remindAt': remindAt?.toIso8601String(),
        'daily': daily,
        'active': active,
      };
}
