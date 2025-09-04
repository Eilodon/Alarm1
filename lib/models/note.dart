class Note {
  String id;
  String title;
  String content;
  DateTime? remindAt;
  bool daily;
  bool active;
  /// Minutes to postpone a notification when snoozed.
  int snoozeMinutes;

  Note({
    String? id,
    required this.title,
    required this.content,
    this.remindAt,
    this.daily = false,
    this.active = false,
    this.snoozeMinutes = 0,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  factory Note.fromJson(Map<String, dynamic> j) => Note(
        id: j['id'],
        title: j['title'],
        content: j['content'],
codex/implement-note-repository-and-provider
        alarmTime: j['alarmTime'] != null ? DateTime.parse(j['alarmTime']) : null,
        daily: j['daily'] is int ? j['daily'] == 1 : j['daily'] ?? false,
        active: j['active'] is int ? j['active'] == 1 : j['active'] ?? false,

      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
 codex/update-homescreenstate-to-manage-notes
        'remindAt': remindAt?.toIso8601String(),
        'daily': daily,
        'active': active,
      };
}
