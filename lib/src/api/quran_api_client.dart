import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class QuranApiException implements Exception {
  const QuranApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

/// Content requests go through our Worker. No QF credentials belong in Flutter.
class QuranApiClient {
  QuranApiClient({
    http.Client? client,
    String? baseUrl,
    this.timeout = const Duration(seconds: 15),
    this.maxAttempts = 3,
    Future<void> Function(Duration)? delay,
  }) : _client = client ?? http.Client(),
       baseUri = Uri.parse(baseUrl ?? configuredBaseUrl),
       _delay = delay ?? Future<void>.delayed {
    if (baseUri.scheme != 'https' ||
        baseUri.host.isEmpty ||
        baseUri.userInfo.isNotEmpty ||
        baseUri.hasQuery ||
        baseUri.hasFragment ||
        (baseUri.path.isNotEmpty && baseUri.path != '/')) {
      throw ArgumentError('QURAN_API_BASE_URL must be an HTTPS origin.');
    }
    if (maxAttempts < 1) throw ArgumentError('maxAttempts must be positive.');
  }

  static const configuredBaseUrl = String.fromEnvironment(
    'QURAN_API_BASE_URL',
    defaultValue: 'https://quran-content-production.mahmoudbahaa-eg.workers.dev',
  );
  static final instance = QuranApiClient();
  final http.Client _client;
  final Uri baseUri;
  final Duration timeout;
  final int maxAttempts;
  final Future<void> Function(Duration) _delay;

  // Separate backend environments without deleting the legacy offline database.
  String get cacheNamespace {
    var hash = 2166136261;
    for (final byte in utf8.encode(baseUri.origin)) {
      hash = ((hash ^ byte) * 16777619) & 0xffffffff;
    }
    return hash.toRadixString(16);
  }

  Uri uri(String path, [Map<String, String>? query]) =>
      baseUri.replace(path: '/content/api/v4/$path', queryParameters: query);

  Future<Map<String, dynamic>> getJson(Uri uri) async {
    if (uri.origin != baseUri.origin ||
        !uri.path.startsWith('/content/api/v4/')) {
      throw ArgumentError('Content URL must use the configured backend.');
    }
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final response = await _client
            .get(uri, headers: {'Accept': 'application/json'})
            .timeout(timeout);
        if (response.statusCode == 200) {
          final body = jsonDecode(utf8.decode(response.bodyBytes));
          if (body is! Map<String, dynamic>) {
            throw const FormatException('Expected an object');
          }
          return body;
        }
        final retryable =
            response.statusCode == 429 || response.statusCode >= 500;
        if (!retryable || attempt == maxAttempts - 1) {
          throw QuranApiException(
            'Quran content request failed (HTTP ${response.statusCode}).',
            statusCode: response.statusCode,
          );
        }
        final retryAfter = int.tryParse(response.headers['retry-after'] ?? '');
        // Avoid repeated requests during long provider rate-limit windows.
        if (retryAfter != null && retryAfter > 10) {
          throw QuranApiException(
            'Quran service is busy. Please try again later.',
            statusCode: response.statusCode,
          );
        }
        await _delay(
          Duration(
            seconds: retryAfter != null && retryAfter >= 0
                ? retryAfter
                : 1 << attempt,
          ),
        );
      } on FormatException {
        throw const QuranApiException('Quran service returned invalid data.');
      } on TimeoutException {
        if (attempt == maxAttempts - 1) {
          throw const QuranApiException('Quran service timed out.');
        }
        await _delay(Duration(seconds: 1 << attempt));
      } on http.ClientException {
        if (attempt == maxAttempts - 1) {
          throw const QuranApiException(
            'Could not connect to the Quran service.',
          );
        }
        await _delay(Duration(seconds: 1 << attempt));
      }
    }
    throw StateError('Unreachable');
  }

  Future<List<Map<String, dynamic>>> chapters() async =>
      _list(await getJson(uri('chapters')), 'chapters');

  Future<List<Map<String, dynamic>>> chapterReciters() async => _list(
    await getJson(uri('resources/chapter_reciters', {'language': 'ar'})),
    'reciters',
  );

  Future<Map<String, dynamic>> pageWords(
    int page,
    int mushaf,
    int code,
  ) => pageWordsFromUri(
    uri('verses/by_page/$page', {
      'mushaf': '$mushaf',
      'words': 'true',
      'per_page': '50',
      'word_fields':
          'code_v$code,text_uthmani_simple,text_imlaei,text_imlaei_simple,line_number,page_number',
    }),
  );

  Future<Map<String, dynamic>> pageWordsFromUri(Uri first) async {
    final verses = <Map<String, dynamic>>[];
    final visited = <int>{};
    var page = 1;
    while (true) {
      if (!visited.add(page) || visited.length > 1000) {
        throw const QuranApiException('Invalid verse pagination.');
      }
      final body = await getJson(
        first.replace(
          queryParameters: {...first.queryParameters, 'page': '$page'},
        ),
      );
      verses.addAll(_list(body, 'verses'));
      final pagination = body['pagination'];
      if (pagination is! Map) {
        throw const QuranApiException('Missing verse pagination.');
      }
      final next = pagination['next_page'];
      if (next == null) break;
      if (next is! int || next <= page) {
        throw const QuranApiException('Invalid verse pagination.');
      }
      page = next;
    }
    if (verses.isEmpty) {
      throw const QuranApiException(
        'This page layout is unavailable in the configured Quran service.',
      );
    }
    return {'verses': verses};
  }

  Uri chapterAudioUri(int reciter, int chapter) =>
      uri('chapter_recitations/$reciter/$chapter', {'segments': 'true'});

  static List<Map<String, dynamic>> _list(
    Map<String, dynamic> body,
    String key,
  ) {
    final list = body[key];
    if (list is! List || list.any((item) => item is! Map<String, dynamic>)) {
      throw QuranApiException('Missing or invalid $key data.');
    }
    return list.cast<Map<String, dynamic>>();
  }
}

/// v4 can return numeric HTML references for page-specific font glyphs.
String decodeGlyphCodes(String text) =>
    text.replaceAllMapped(RegExp(r'&#(?:x([0-9a-fA-F]+)|([0-9]+));'), (match) {
      final code = int.parse(
        match[1] ?? match[2]!,
        radix: match[1] == null ? 10 : 16,
      );
      if (code > 0x10ffff || (code >= 0xd800 && code <= 0xdfff)) {
        throw const FormatException('Invalid Quran glyph');
      }
      return String.fromCharCode(code);
    });
