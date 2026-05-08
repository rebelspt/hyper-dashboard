enum AbsMode {
  newest,
  continueListening,
  continueSeries,
  listenAgain,
  newestEpisodes,
  recentlyAdded;

  static AbsMode from(String? value) => switch (value) {
        'continue' || 'continue-listening' => AbsMode.continueListening,
        'continue-series' => AbsMode.continueSeries,
        'listen-again' => AbsMode.listenAgain,
        'newest-episodes' => AbsMode.newestEpisodes,
        'recently-added' => AbsMode.recentlyAdded,
        _ => AbsMode.newest,
      };

  bool get usesPersonalizedEndpoint => switch (this) {
        AbsMode.continueSeries ||
        AbsMode.listenAgain ||
        AbsMode.newestEpisodes ||
        AbsMode.recentlyAdded =>
          true,
        _ => false,
      };

  String get shelfId => switch (this) {
        AbsMode.continueSeries => 'continue-series',
        AbsMode.listenAgain => 'listen-again',
        AbsMode.newestEpisodes => 'newest-episodes',
        AbsMode.recentlyAdded => 'recently-added',
        _ => throw StateError('$this has no shelf ID'),
      };
}

enum AbsMediaType {
  book,
  podcast,
  unknown;

  static AbsMediaType from(String? value) => switch (value) {
        'book' => AbsMediaType.book,
        'podcast' => AbsMediaType.podcast,
        _ => AbsMediaType.unknown,
      };
}

class AbsItem {
  final String id;
  final String title;
  final String subtitle;
  final double progress;
  final String coverUrl;
  final String itemUrl;
  final int addedAt;
  final String streamUrl;

  const AbsItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.coverUrl,
    required this.itemUrl,
    this.addedAt = 0,
    this.streamUrl = '',
  });
}
