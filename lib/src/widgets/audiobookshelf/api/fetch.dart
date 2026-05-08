import 'dart:convert' show jsonDecode;
import '../../../services/services.dart';
import '../models.dart';
import 'parsers.dart';

Future<List<AbsItem>> fetchPersonalized(
  Services services,
  String baseUrl,
  String apiKey,
  Map<String, String> headers,
  String libraryName,
  AbsMode mode,
  int limit,
) async {
  final libsResp = await services.httpClient.get(
    Uri.parse('$baseUrl/api/libraries'),
    headers: headers,
  );
  if (libsResp.statusCode != 200) {
    throw Exception('Audiobookshelf libraries: HTTP ${libsResp.statusCode}');
  }

  final libraries =
      ((jsonDecode(libsResp.body) as Map<String, dynamic>)['libraries'] as List)
          .cast<Map<String, dynamic>>();

  Map<String, dynamic>? lib;
  for (final l in libraries) {
    if ((l['name'] as String?)?.toLowerCase() == libraryName.toLowerCase()) {
      lib = l;
      break;
    }
  }
  if (lib == null) {
    final available = libraries
        .map((l) => l['name'] as String? ?? '')
        .where((n) => n.isNotEmpty)
        .join(', ');
    throw Exception(
      'Audiobookshelf library "$libraryName" not found. Available: $available',
    );
  }

  final libId = lib['id'] as String;
  final resp = await services.httpClient.get(
    Uri.parse(
      '$baseUrl/api/libraries/$libId/personalized?include=rssfeed,numEpisodesIncomplete,share',
    ),
    headers: headers,
  );
  if (resp.statusCode != 200) {
    throw Exception('Audiobookshelf personalized: HTTP ${resp.statusCode}');
  }

  final shelves = (jsonDecode(resp.body) as List).cast<Map<String, dynamic>>();

  Map<String, dynamic>? shelfData;
  for (final s in shelves) {
    if (s['id'] == mode.shelfId) {
      shelfData = s;
      break;
    }
  }
  if (shelfData == null) return [];

  final entities =
      (shelfData['entities'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  return entities
      .take(limit)
      .map((e) => parsePersonalizedEntity(e, baseUrl, apiKey, mode))
      .whereType<AbsItem>()
      .toList();
}

Future<List<AbsItem>> fetchNewest(
  Services services,
  String baseUrl,
  String apiKey,
  Map<String, String> headers,
  int limit,
) async {
  final libsResp = await services.httpClient.get(
    Uri.parse('$baseUrl/api/libraries'),
    headers: headers,
  );
  if (libsResp.statusCode != 200) {
    throw Exception('Audiobookshelf libraries: HTTP ${libsResp.statusCode}');
  }

  final libraries =
      ((jsonDecode(libsResp.body) as Map<String, dynamic>)['libraries'] as List)
          .cast<Map<String, dynamic>>();

  if (libraries.isEmpty) return [];

  final allItems = <AbsItem>[];
  await Future.wait(
    libraries.map((lib) async {
      try {
        final libId = lib['id'] as String;
        final mediaType = AbsMediaType.from(lib['mediaType'] as String?);
        if (mediaType == AbsMediaType.podcast) {
          allItems.addAll(
            await fetchRecentEpisodes(
              services,
              baseUrl,
              libId,
              apiKey,
              headers,
              limit,
            ),
          );
        } else {
          allItems.addAll(
            await fetchRecentBooks(
              services,
              baseUrl,
              libId,
              apiKey,
              headers,
              limit,
            ),
          );
        }
      } catch (_) {}
    }),
  );

  allItems.sort((a, b) => b.addedAt.compareTo(a.addedAt));
  return allItems.take(limit).toList();
}

Future<List<AbsItem>> fetchRecentBooks(
  Services services,
  String baseUrl,
  String libId,
  String apiKey,
  Map<String, String> headers,
  int limit,
) async {
  final resp = await services.httpClient.get(
    Uri.parse(
      '$baseUrl/api/libraries/$libId/items?sort=addedAt&desc=1&limit=$limit',
    ),
    headers: headers,
  );
  if (resp.statusCode != 200) return [];

  final results =
      ((jsonDecode(resp.body) as Map<String, dynamic>)['results'] as List?)
              ?.cast<Map<String, dynamic>>() ??
          [];

  return results
      .map((r) => parseBookItem(r, baseUrl, apiKey))
      .whereType<AbsItem>()
      .toList();
}

Future<List<AbsItem>> fetchRecentEpisodes(
  Services services,
  String baseUrl,
  String libId,
  String apiKey,
  Map<String, String> headers,
  int limit,
) async {
  final resp = await services.httpClient.get(
    Uri.parse('$baseUrl/api/libraries/$libId/recent-episodes?limit=$limit'),
    headers: headers,
  );
  if (resp.statusCode != 200) return [];

  final episodes =
      ((jsonDecode(resp.body) as Map<String, dynamic>)['episodes'] as List?)
              ?.cast<Map<String, dynamic>>() ??
          [];

  return episodes
      .map((ep) => parseRecentEpisode(ep, baseUrl, apiKey))
      .whereType<AbsItem>()
      .toList();
}

Future<List<AbsItem>> fetchInProgress(
  Services services,
  String baseUrl,
  String apiKey,
  Map<String, String> headers,
  int limit,
) async {
  final resp = await services.httpClient.get(
    Uri.parse('$baseUrl/api/me/items-in-progress'),
    headers: headers,
  );
  if (resp.statusCode != 200) {
    throw Exception('Audiobookshelf in-progress: HTTP ${resp.statusCode}');
  }

  final body = jsonDecode(resp.body) as Map<String, dynamic>;

  final libraryItems =
      (body['libraryItems'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  final episodeItems =
      (body['episodeItems'] as List?)?.cast<Map<String, dynamic>>() ?? [];

  final items = <AbsItem>[];

  for (final r in libraryItems) {
    if (AbsMediaType.from(r['mediaType'] as String?) == AbsMediaType.podcast) {
      continue;
    }
    final item =
        parseBookItem(r, baseUrl, apiKey, progress: extractProgress(r));
    if (item != null) items.add(item);
  }

  for (final r in episodeItems) {
    final item = parseInProgressEpisode(r, baseUrl, apiKey);
    if (item != null) items.add(item);
  }

  return items.take(limit).toList();
}
