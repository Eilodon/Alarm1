class Note {
  String id;
  String title;
  String content;
  DateTime? alarmTime;
  bool daily;
  bool active;
  List<String> tags;
  List<String> attachments;
  DateTime createdAt;
  DateTime updatedAt;
  bool isCompleted;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.alarmTime,
    this.daily = false,
    this.active = false,
    List<String>? tags,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isCompleted = false,
  })  : tags = tags ?? [],
        attachments = attachments ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Note.fromJson(Map<String, dynamic> j) => Note(
        id: j['id'],
        title: j['title'],
        content: j['content'],
        alarmTime: j['alarmTime'] != null ? DateTime.parse(j['alarmTime']) : null,
        daily: j['daily'] ?? false,
        active: j['active'] ?? false,
        tags: (j['tags'] as List?)?.cast<String>() ?? [],
        attachments: (j['attachments'] as List?)?.cast<String>() ?? [],
        createdAt: j['createdAt'] != null ? DateTime.parse(j['createdAt']) : DateTime.now(),
        updatedAt: j['updatedAt'] != null ? DateTime.parse(j['updatedAt']) : DateTime.now(),
        isCompleted: j['isCompleted'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'alarmTime': alarmTime?.toIso8601String(),
        'daily': daily,
        'active': active,
        'tags': tags,
        'attachments': attachments,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isCompleted': isCompleted,
      };
}
