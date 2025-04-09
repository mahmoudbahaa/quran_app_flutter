import 'package:audio_service/audio_service.dart';
import 'package:media_kit/media_kit.dart';

part 'media_record.g.dart';

/// key to identify media uri stored in extras in [MediaItem]
const String mediaUriKey = 'mu';
const String mediaHeadersKey = 'mh';

/// Store media information here
class MediaRecord {
  MediaRecord({
    required this.id,
    required this.title,
    required this.mediaUri,
    this.mediaHeaders,
    this.duration,
    this.artHeaders,
    this.artUri,
    this.artist,
    this.displaySubtitle,
    this.displayTitle,
    this.displayDescription,
    this.album,
  });

  factory MediaRecord.fromJson(Map<String, dynamic> json) =>
      _$MediaRecordFromJson(json);

  factory MediaRecord.fromMediaKit(Media media) {
    if (media.extras == null) {
      throw Exception(
        'Media.extras is empty this should not happen'
            '\nReport this issue on https://github.com/RA341/vinyl',
      );
    }
    return MediaRecord.fromJson(media.extras!);
  }

  factory MediaRecord.fromMediaItem(MediaItem mItem) {
    if (mItem.extras == null || !mItem.extras!.containsKey(mediaUriKey) ||
        !mItem.extras!.containsKey(mediaHeadersKey)) {
      throw Exception(
        'MediaItem.extras is empty this should not happen'
            '\nReport this issue on https://github.com/RA341/vinyl',
      );
    }

    final uri = mItem.extras![mediaUriKey]! as String;
    final mHeaders = mItem.extras![mediaHeadersKey]! as Map<String,String>?;

    return MediaRecord(
        id: mItem.id,
        title: mItem.title,
        mediaUri: uri,
        displayTitle: mItem.displayTitle,
        duration: mItem.duration,
        displaySubtitle: mItem.displaySubtitle,
        displayDescription: mItem.displayDescription,
        album: mItem.album,
        artist: mItem.artist,
        artUri: mItem.artUri?.toString(),
        artHeaders: mItem.artHeaders,
        mediaHeaders: mHeaders,
    );
  }

  Map<String, dynamic> toJson() => _$MediaRecordToJson(this);

  /// Convert [MediaRecord] to [MediaItem] for audio_service
  MediaItem toMediaItem() {
    return MediaItem(
      id: id,
      title: title,
      artHeaders: artHeaders,
      // ':' is a invalid uri; to force null to return
      artUri: Uri.tryParse(artUri ?? ':'),
      artist: artist,
      extras: {mediaUriKey: mediaUri, mediaHeadersKey: mediaHeaders},
      album: album,
      displayDescription: displayDescription,
      displaySubtitle: displaySubtitle,
      duration: duration,
      displayTitle: displayTitle,
    );
  }

  /// Convert [MediaRecord] to [Media] for mediakit
  Media toMediaKit() {
    return Media(mediaUri, extras: toJson(), httpHeaders: mediaHeaders);
  }

  final String id;

  /// store media url can be file or web
  final String mediaUri;

  final String title;

  /// headers for the media file
  final Map<String, String>? mediaHeaders;

  final Duration? duration;

  final Map<String, String>? artHeaders;
  final String? artUri;
  final String? artist;
  final String? displaySubtitle;
  final String? displayTitle;
  final String? displayDescription;
  final String? album;
}
