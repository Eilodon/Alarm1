import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime? alarmTime;
  final RepeatInterval? repeatInterval;
  final bool daily;
  final bool active;
  final List<String> tags;
  final List<String> attachments;
  final bool locked;
  final int snoozeMinutes;
  final DateTime? updatedAt;
  final int? notificationId;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    this.alarmTime,
    this.repeatInterval,
    this.daily = false,
    this.active = false,
    this.tags = const [],
    this.attachments = const [],
    this.locked = false,
    this.snoozeMinutes = 0,
    this.updatedAt,
    this.notificationId,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? alarmTime,
    RepeatInterval? repeatInterval,
    bool? daily,
    bool? active,
    List<String>? tags,
    List<String>? attachments,
    bool? locked,
    int? snoozeMinutes,
    DateTime? updatedAt,
    Object? notificationId = _notificationIdSentinel,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      alarmTime: alarmTime ?? this.alarmTime,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      daily: daily ?? this.daily,
      active: active ?? this.active,
      tags: tags ?? this.tags,
      attachments: attachments ?? this.attachments,
      locked: locked ?? this.locked,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      updatedAt: updatedAt ?? this.updatedAt,
      notificationId: notificationId == _notificationIdSentinel
          ? this.notificationId
          : notificationId as int?,
    );
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      alarmTime: json['alarmTime'] != null
          ? DateTime.parse(json['alarmTime'])
          : json['remindAt'] != null
          ? DateTime.parse(json['remindAt'])
          : null,
      repeatInterval: _repeatIntervalFromString(
        json['repeatInterval'] as String?,
      ),
      daily: json['daily'] ?? false,
      active: json['active'] ?? false,
      tags: (json['tags'] as List<dynamic>? ?? []).cast<String>(),
      attachments: (json['attachments'] as List<dynamic>? ?? []).cast<String>(),
      locked: json['locked'] ?? false,
      snoozeMinutes: json['snoozeMinutes'] ?? 0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      notificationId: json['notificationId'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'alarmTime': alarmTime?.toIso8601String(),
    'repeatInterval': repeatInterval?.toString().split('.').last,
    'daily': daily,
    'active': active,
    'tags': tags,
    'attachments': attachments,
    'locked': locked,
    'snoozeMinutes': snoozeMinutes,
    'updatedAt': updatedAt?.toIso8601String(),
    'notificationId': notificationId,
  };
}

const _notificationIdSentinel = Object();

RepeatInterval? _repeatIntervalFromString(String? value) {
  if (value == null) return null;
  for (final r in RepeatInterval.values) {
    if (r.toString().split('.').last == value) return r;
  }
  return null;
}
