import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:json_annotation/json_annotation.dart';

part 'note.g.dart';

/// Represents a note with optional reminders and associated metadata.
@JsonSerializable()
class Note {
  /// Unique identifier for the note.
  final String id;

  /// Title of the note.
  final String title;

  /// Full text content of the note.
  final String content;

  /// Short summary or preview of the note.
  @JsonKey(defaultValue: '')
  final String summary;

  /// List of action items extracted from the note.
  @JsonKey(defaultValue: [])
  final List<String> actionItems;

  /// Important dates associated with the note.
  @JsonKey(defaultValue: [])
  final List<DateTime> dates;

  /// Optional time when a notification alarm should trigger.
  final DateTime? alarmTime;

  /// How often the alarm should repeat.
  final RepeatInterval? repeatInterval;

  /// Whether this note should repeat daily.
  @JsonKey(defaultValue: false)
  final bool daily;

  /// Whether this note's reminder is currently active.
  @JsonKey(defaultValue: false)
  final bool active;

  /// Tags used to categorize the note.
  @JsonKey(defaultValue: [])
  final List<String> tags;

  /// Paths or identifiers for file attachments.
  @JsonKey(defaultValue: [])
  final List<String> attachments;

  /// Display color associated with the note.
  @JsonKey(defaultValue: 0xFFFFFFFF)
  final int color;

  /// Whether the note is pinned to the top of lists.
  @JsonKey(defaultValue: false)
  final bool pinned;

  /// Indicates if the note is locked and requires authentication.
  @JsonKey(defaultValue: false)
  final bool locked;

  /// Number of minutes to snooze the reminder.
  @JsonKey(defaultValue: 0)
  final int snoozeMinutes;

  /// Whether this note has been marked as completed.
  @JsonKey(defaultValue: false)
  final bool done;

  /// Timestamp of the last update.
  final DateTime? updatedAt;

  /// Identifier of the scheduled notification.
  final int? notificationId;

  /// Calendar event identifier associated with the note.
  final String? eventId;

  /// Creates a new [Note].
  const Note({
    required this.id,
    required this.title,
    required this.content,
    this.summary = '',
    this.actionItems = const [],
    this.dates = const [],
    this.alarmTime,
    this.repeatInterval,
    this.daily = false,
    this.active = false,
    this.tags = const [],
    this.attachments = const [],
    this.color = 0xFFFFFFFF,
    this.pinned = false,
    this.locked = false,
    this.snoozeMinutes = 0,
    this.done = false,
    this.updatedAt,
    this.notificationId,
    this.eventId,
  });

  /// Returns a copy of this note with the given fields replaced.
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
    int? color,
    bool? pinned,
    String? summary,
    List<String>? actionItems,
    List<DateTime>? dates,
    bool? locked,
    int? snoozeMinutes,
    bool? done,
    DateTime? updatedAt,
    Object? notificationId = _notificationIdSentinel,

    Object? eventId = _eventIdSentinel,

  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      actionItems: actionItems ?? this.actionItems,
      dates: dates ?? this.dates,
      alarmTime: alarmTime ?? this.alarmTime,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      daily: daily ?? this.daily,
      active: active ?? this.active,
      tags: tags ?? this.tags,
      attachments: attachments ?? this.attachments,
      color: color ?? this.color,
      pinned: pinned ?? this.pinned,
      locked: locked ?? this.locked,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      done: done ?? this.done,
      updatedAt: updatedAt ?? this.updatedAt,
      notificationId: notificationId == _notificationIdSentinel
          ? this.notificationId
          : notificationId as int?,
      eventId:
          eventId == _eventIdSentinel ? this.eventId : eventId as String?,
    );
  }

  /// Creates a [Note] from a JSON map.
  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);

  /// Converts this note to a JSON map.
  Map<String, dynamic> toJson() => _$NoteToJson(this);
}
/// Sentinel value used to differentiate a missing notificationId in [Note.copyWith].
const _notificationIdSentinel = Object();

/// Sentinel value used to differentiate a missing eventId in [Note.copyWith].
const _eventIdSentinel = Object();

