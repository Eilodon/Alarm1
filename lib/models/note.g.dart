// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Note _$NoteFromJson(Map<String, dynamic> json) => Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      summary: json['summary'] as String? ?? '',
      actionItems: (json['actionItems'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      dates: (json['dates'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          [],
      alarmTime: json['alarmTime'] == null
          ? null
          : DateTime.parse(json['alarmTime'] as String),
      repeatInterval:
          $enumDecodeNullable(_$RepeatIntervalEnumMap, json['repeatInterval']),
      daily: json['daily'] as bool? ?? false,
      active: json['active'] as bool? ?? false,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      locked: json['locked'] as bool? ?? false,
      snoozeMinutes: (json['snoozeMinutes'] as num?)?.toInt() ?? 0,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      notificationId: (json['notificationId'] as num?)?.toInt(),
      eventId: json['eventId'] as String?,
    );

Map<String, dynamic> _$NoteToJson(Note instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'summary': instance.summary,
      'actionItems': instance.actionItems,
      'dates': instance.dates.map((e) => e.toIso8601String()).toList(),
      'alarmTime': instance.alarmTime?.toIso8601String(),
      'repeatInterval': _$RepeatIntervalEnumMap[instance.repeatInterval],
      'daily': instance.daily,
      'active': instance.active,
      'tags': instance.tags,
      'attachments': instance.attachments,
      'locked': instance.locked,
      'snoozeMinutes': instance.snoozeMinutes,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'notificationId': instance.notificationId,
      'eventId': instance.eventId,
    };

const _$RepeatIntervalEnumMap = {
  RepeatInterval.everyMinute: 'everyMinute',
  RepeatInterval.hourly: 'hourly',
  RepeatInterval.daily: 'daily',
  RepeatInterval.weekly: 'weekly',
};
