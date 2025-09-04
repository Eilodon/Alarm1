class Note {
  String id;
  String title;
  String content;
  DateTime? remindAt;
  bool daily;
  bool active;
 codex/add-tag-chips-to-note-list
  List<String> tags;


  Note({
    String? id,
    required this.title,
    required this.content,
    this.remindAt,
    this.daily = false,
    this.active = false,
 codex/add-tag-chips-to-note-list
    this.tags = const [],

  });


  factory Note.fromJson(Map<String, dynamic> j) => Note(
        id: j['id'],
        title: j['title'],
        content: j['content'],
codex/implement-note-repository-and-provider
        alarmTime: j['alarmTime'] != null ? DateTime.parse(j['alarmTime']) : null,
 codex/expand-note-model-with-new-fields
        daily: j['daily'] ?? false,
        active: j['active'] ?? false,
 codex/add-tag-chips-to-note-list
        tags: (j['tags'] as List<dynamic>? ?? []).cast<String>(),

      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
 codex/update-homescreenstate-to-manage-notes
        'remindAt': remindAt?.toIso8601String(),
        'daily': daily,
        'active': active,
 codex/add-tag-chips-to-note-list
        'tags': tags,

      };
}
