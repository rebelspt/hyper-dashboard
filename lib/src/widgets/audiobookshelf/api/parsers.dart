import '../models.dart';

AbsItem? parsePersonalizedEntity(
  Map<String, dynamic> entity,
  String baseUrl,
  String apiKey,
  AbsMode mode,
) {
  final id = entity['id'] as String? ?? '';
  if (id.isEmpty) return null;

  final mediaType = AbsMediaType.from(entity['mediaType'] as String?);
  final addedAt = entity['addedAt'] as int? ?? 0;
  String title, subtitle;
  String streamUrl = '';

  if (mediaType == AbsMediaType.book) {
    final meta = ((entity['media'] as Map<String, dynamic>?) ?? {})['metadata']
            as Map<String, dynamic>? ??
        {};
    title = meta['title'] as String? ?? '';
    subtitle = meta['authorName'] as String? ?? '';
  } else {
    final meta = ((entity['media'] as Map<String, dynamic>?) ?? {})['metadata']
            as Map<String, dynamic>? ??
        {};
    final podcastTitle = meta['title'] as String? ?? '';
    final recentEpisode =
        entity['recentEpisode'] as Map<String, dynamic>? ?? {};
    final episodeTitle = recentEpisode['title'] as String? ?? '';
    final numIncomplete = entity['numEpisodesIncomplete'] as int? ?? 0;

    if (mode == AbsMode.recentlyAdded && numIncomplete > 0) {
      title = podcastTitle;
      subtitle = '$numIncomplete new episode${numIncomplete == 1 ? '' : 's'}';
    } else {
      title = episodeTitle.isNotEmpty ? episodeTitle : podcastTitle;
      subtitle = podcastTitle;
    }

    final audioFile = recentEpisode['audioFile'] as Map<String, dynamic>? ?? {};
    final ino = audioFile['ino'] as String? ?? '';
    final episodeLibItemId = recentEpisode['libraryItemId'] as String? ?? id;
    if (ino.isNotEmpty) {
      streamUrl =
          '$baseUrl/api/items/$episodeLibItemId/file/$ino?token=$apiKey';
    }
  }

  return AbsItem(
    id: id,
    title: title,
    subtitle: subtitle,
    progress: -1,
    coverUrl: '$baseUrl/api/items/$id/cover?token=$apiKey&width=52',
    itemUrl: '$baseUrl/item/$id',
    addedAt: addedAt,
    streamUrl: streamUrl,
  );
}

AbsItem? parseBookItem(
  Map<String, dynamic> r,
  String baseUrl,
  String apiKey, {
  double progress = -1,
}) {
  final id = r['id'] as String? ?? '';
  if (id.isEmpty) return null;

  final meta = ((r['media'] as Map<String, dynamic>?) ?? {})['metadata']
          as Map<String, dynamic>? ??
      {};
  final title = meta['title'] as String? ?? '';
  final author =
      meta['authorName'] as String? ?? meta['author'] as String? ?? '';
  final addedAt = r['addedAt'] as int? ?? 0;

  return AbsItem(
    id: id,
    title: title,
    subtitle: author,
    progress: progress,
    coverUrl: '$baseUrl/api/items/$id/cover?token=$apiKey&width=52',
    itemUrl: '$baseUrl/item/$id',
    addedAt: addedAt,
  );
}

AbsItem? parseRecentEpisode(
  Map<String, dynamic> ep,
  String baseUrl,
  String apiKey,
) {
  final libraryItemId = ep['libraryItemId'] as String? ?? '';
  if (libraryItemId.isEmpty) return null;

  final episodeTitle = ep['title'] as String? ?? '';
  final podcast = ep['podcast'] as Map<String, dynamic>? ?? {};
  final podcastMeta = podcast['metadata'] as Map<String, dynamic>? ?? podcast;
  final podcastTitle =
      podcastMeta['title'] as String? ?? ep['podcastTitle'] as String? ?? '';
  final addedAt = ep['addedAt'] as int? ?? ep['publishedAt'] as int? ?? 0;

  final audioFile = ep['audioFile'] as Map<String, dynamic>? ?? {};
  final ino = audioFile['ino'] as String? ?? '';
  final streamUrl = ino.isNotEmpty
      ? '$baseUrl/api/items/$libraryItemId/file/$ino?token=$apiKey'
      : '';

  return AbsItem(
    id: libraryItemId,
    title: episodeTitle.isNotEmpty ? episodeTitle : podcastTitle,
    subtitle: podcastTitle,
    progress: -1,
    coverUrl: '$baseUrl/api/items/$libraryItemId/cover?token=$apiKey&width=52',
    itemUrl: '$baseUrl/item/$libraryItemId',
    addedAt: addedAt,
    streamUrl: streamUrl,
  );
}

AbsItem? parseInProgressEpisode(
  Map<String, dynamic> r,
  String baseUrl,
  String apiKey,
) {
  final libraryItemId = r['id'] as String? ?? '';
  if (libraryItemId.isEmpty) return null;

  final episode = r['recentEpisode'] as Map<String, dynamic>? ?? {};
  final meta = ((r['media'] as Map<String, dynamic>?) ?? {})['metadata']
          as Map<String, dynamic>? ??
      {};
  final episodeTitle = episode['title'] as String? ?? '';
  final podcastTitle = meta['title'] as String? ?? '';

  final audioFile = episode['audioFile'] as Map<String, dynamic>? ?? {};
  final ino = audioFile['ino'] as String? ?? '';
  final streamUrl = ino.isNotEmpty
      ? '$baseUrl/api/items/$libraryItemId/file/$ino?token=$apiKey'
      : '';

  return AbsItem(
    id: libraryItemId,
    title: episodeTitle.isNotEmpty ? episodeTitle : podcastTitle,
    subtitle: podcastTitle,
    progress: extractProgress(r),
    coverUrl: '$baseUrl/api/items/$libraryItemId/cover?token=$apiKey&width=52',
    itemUrl: '$baseUrl/item/$libraryItemId',
    streamUrl: streamUrl,
  );
}

double extractProgress(Map<String, dynamic> r) {
  final prog = r['userMediaProgress'] as Map<String, dynamic>?;
  return (prog?['progress'] as num?)?.toDouble() ?? 0.0;
}
