// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaRecord _$MediaRecordFromJson(Map<String, dynamic> json) => MediaRecord(
      id: json['id'] as String,
      title: json['title'] as String,
      mediaUri: json['mediaUri'] as String,
      mediaHeaders: (json['mediaHeaders'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      duration: json['duration'] == null
          ? null
          : Duration(microseconds: json['duration'] as int),
      artHeaders: (json['artHeaders'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      artUri: json['artUri'] as String?,
      artist: json['artist'] as String?,
      displaySubtitle: json['displaySubtitle'] as String?,
      displayTitle: json['displayTitle'] as String?,
      displayDescription: json['displayDescription'] as String?,
      album: json['album'] as String?,
    );

Map<String, dynamic> _$MediaRecordToJson(MediaRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mediaUri': instance.mediaUri,
      'title': instance.title,
      'mediaHeaders': instance.mediaHeaders,
      'duration': instance.duration?.inMicroseconds,
      'artHeaders': instance.artHeaders,
      'artUri': instance.artUri,
      'artist': instance.artist,
      'displaySubtitle': instance.displaySubtitle,
      'displayTitle': instance.displayTitle,
      'displayDescription': instance.displayDescription,
      'album': instance.album,
    };
