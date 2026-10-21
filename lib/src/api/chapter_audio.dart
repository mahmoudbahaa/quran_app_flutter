class WordTiming {
  const WordTiming(this.verse, this.word, this.from, this.to);
  final String verse;
  final int word;
  final int from;
  final int to;
}

/// Adapter for Content v4's single-chapter audio response.
class ChapterAudio {
  ChapterAudio(
    this.chapter,
    this.url,
    this.fileSize,
    this.durationMs,
    this.timings,
  );
  final int chapter;
  final String url;
  final double fileSize;
  final int durationMs;
  final List<WordTiming> timings;

  factory ChapterAudio.fromJson(
    Map<String, dynamic> data,
    int expectedChapter,
  ) {
    final file = data['audio_file'];
    if (file is! Map ||
        file['chapter_id'] != expectedChapter ||
        file['audio_url'] is! String) {
      throw const FormatException('Invalid chapter audio response');
    }
    final url = Uri.tryParse(file['audio_url'] as String);
    if (url == null || url.scheme != 'https' || url.host.isEmpty) {
      throw const FormatException('Invalid chapter audio URL');
    }
    final timings = <WordTiming>[];
    final seen = <String>{};
    var duration = 0;
    final timestamps = file['timestamps'];
    if (timestamps != null && timestamps is! List) {
      throw const FormatException('Invalid timestamps');
    }
    for (final stamp in (timestamps as List? ?? [])) {
      if (stamp is! Map ||
          stamp['verse_key'] is! String ||
          !RegExp('^$expectedChapter:[1-9][0-9]*\$')
              .hasMatch(stamp['verse_key'] as String)) {
        throw const FormatException('Invalid verse timestamp');
      }
      final end = stamp['timestamp_to'];
      if (end is num && end.isFinite && end > duration) duration = end.floor();
      final segments = stamp['segments'];
      if (segments == null) continue;
      if (segments is! List) {
        throw const FormatException('Invalid word segments');
      }
      for (final segment in segments) {
        // Some recordings include one-element marker entries between timings.
        if (segment is! List || segment.length != 3) continue;
        if (segment.any((value) => value is! num || !value.isFinite)) continue;
        final word = (segment[0] as num).toInt();
        final from = (segment[1] as num).floor();
        final to = (segment[2] as num).floor();
        if (word < 1 || from < 0 || to <= from) continue;
        final verse = stamp['verse_key'] as String;
        if (seen.add('$verse:$word:$from:$to')) {
          timings.add(WordTiming(verse, word, from, to));
        }
      }
    }
    final size = file['file_size'];
    if (size is! num || !size.isFinite || size < 0) {
      throw const FormatException('Invalid file size');
    }
    return ChapterAudio(
      expectedChapter,
      url.toString(),
      size.toDouble(),
      duration,
      timings,
    );
  }
}
