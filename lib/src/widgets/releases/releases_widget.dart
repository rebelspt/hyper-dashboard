import 'dart:convert' show jsonDecode;
import 'package:http/http.dart' as http;
import 'package:dartkup/dartkup.dart';
import '../../services/services.dart';
import '../components/formatters.dart';
import '../components/nodes.dart';
import '../render_context.dart';
import '../widget.dart';

class _Release {
  final String repo;
  final String tagName;
  final String htmlUrl;
  final DateTime publishedAt;

  const _Release({
    required this.repo,
    required this.tagName,
    required this.htmlUrl,
    required this.publishedAt,
  });
}

({String source, String path}) _parseRepo(String raw) {
  if (raw.startsWith('github:')) {
    return (source: 'github', path: raw.substring(7));
  }
  if (raw.startsWith('gitlab:')) {
    return (source: 'gitlab', path: raw.substring(7));
  }
  if (raw.startsWith('codeberg:')) {
    return (source: 'codeberg', path: raw.substring(9));
  }
  if (raw.startsWith('dockerhub:')) {
    return (source: 'dockerhub', path: raw.substring(10));
  }
  return (source: 'github', path: raw);
}

class ReleasesWidget extends DashboardWidget {
  ReleasesWidget(super.config, super.id);

  @override
  String get type => 'releases';

  @override
  String get defaultTitle => 'Releases';

  @override
  Future<Node> renderBody(Services services, RenderContext ctx) async {
    final limit = config.options['limit'] as int? ?? 10;

    final items = await ctx.cache
        .fetch<List<_Release>>('releases', config.cache, () async {
      final repos = _repoList();
      final allReleases = <_Release>[];

      await Future.wait(
        repos.map((repo) async {
          try {
            allReleases.addAll(await _fetchReleases(services, repo));
          } catch (_) {}
        }),
      );

      allReleases.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return allReleases;
    });

    if (items.isEmpty) {
      return p({'cls': 'widget-empty'}, 'No releases found.');
    }

    return ul(
      {'cls': 'releases-list'},
      items
          .take(limit)
          .map(
            (r) => li(
              {'cls': 'releases-item'},
              [
                div({'cls': 'releases-repo'}, t(r.repo)),
                extLink(r.htmlUrl, t(r.tagName), cls: 'releases-tag'),
                span({'cls': 'releases-date'}, t(relativeAge(r.publishedAt))),
              ],
            ),
          )
          .toList(),
    );
  }

  List<String> _repoList() {
    final raw = config.options['repositories'];
    if (raw is! List) return const [];
    return raw.cast<String>();
  }

  Future<List<_Release>> _fetchReleases(Services services, String raw) {
    final (:source, :path) = _parseRepo(raw);
    return switch (source) {
      'gitlab' => _fetchGitLab(services, path),
      'codeberg' => _fetchCodeberg(services, path),
      'dockerhub' => _fetchDockerHub(services, path),
      _ => _fetchGitHub(services, path),
    };
  }

  // ── GitHub ──────────────────────────────────────────────────────────────────

  Future<List<_Release>> _fetchGitHub(Services services, String repo) async {
    final resp = await services.httpClient.get(
      Uri.parse('https://api.github.com/repos/$repo/releases?per_page=5'),
      headers: {'Accept': 'application/vnd.github.v3+json'},
    );
    _checkStatus(resp, repo);
    return (jsonDecode(resp.body) as List)
        .cast<Map<String, dynamic>>()
        .map(
          (r) => _Release(
            repo: repo,
            tagName: r['tag_name'] as String? ?? '',
            htmlUrl: r['html_url'] as String? ?? '#',
            publishedAt: DateTime.parse(r['published_at'] as String),
          ),
        )
        .toList();
  }

  // ── GitLab ──────────────────────────────────────────────────────────────────

  Future<List<_Release>> _fetchGitLab(Services services, String repo) async {
    final encoded = Uri.encodeComponent(repo);
    final resp = await services.httpClient.get(
      Uri.parse(
        'https://gitlab.com/api/v4/projects/$encoded/releases?per_page=5',
      ),
    );
    _checkStatus(resp, repo);
    return (jsonDecode(resp.body) as List)
        .cast<Map<String, dynamic>>()
        .map((r) {
      final links = r['_links'] as Map<String, dynamic>? ?? {};
      return _Release(
        repo: repo,
        tagName: r['tag_name'] as String? ?? '',
        htmlUrl:
            links['self'] as String? ?? 'https://gitlab.com/$repo/-/releases',
        publishedAt: DateTime.parse(r['released_at'] as String),
      );
    }).toList();
  }

  // ── Codeberg ─────────────────────────────────────────────────────────────────

  Future<List<_Release>> _fetchCodeberg(Services services, String repo) async {
    final resp = await services.httpClient.get(
      Uri.parse('https://codeberg.org/api/v1/repos/$repo/releases?limit=5'),
    );
    _checkStatus(resp, repo);
    return (jsonDecode(resp.body) as List)
        .cast<Map<String, dynamic>>()
        .map(
          (r) => _Release(
            repo: repo,
            tagName: r['tag_name'] as String? ?? '',
            htmlUrl: r['html_url'] as String? ??
                'https://codeberg.org/$repo/releases',
            publishedAt: DateTime.parse(r['published_at'] as String),
          ),
        )
        .toList();
  }

  // ── Docker Hub ───────────────────────────────────────────────────────────────

  Future<List<_Release>> _fetchDockerHub(Services services, String repo) async {
    final resp = await services.httpClient.get(
      Uri.parse(
        'https://hub.docker.com/v2/repositories/$repo/tags?page_size=5&ordering=last_updated',
      ),
    );
    _checkStatus(resp, repo);
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    final results =
        (body['results'] as List? ?? []).cast<Map<String, dynamic>>();
    return results.map((r) {
      final pushed =
          r['tag_last_pushed'] as String? ?? r['last_updated'] as String? ?? '';
      return _Release(
        repo: repo,
        tagName: r['name'] as String? ?? '',
        htmlUrl: 'https://hub.docker.com/r/$repo/tags',
        publishedAt: pushed.isNotEmpty
            ? DateTime.parse(pushed)
            : DateTime.fromMillisecondsSinceEpoch(0),
      );
    }).toList();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  void _checkStatus(http.Response resp, String repo) {
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode} for $repo');
    }
  }
}
