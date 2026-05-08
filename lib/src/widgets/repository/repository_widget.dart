import 'dart:convert' show jsonDecode;
import 'package:dartkup/dartkup.dart';
import '../../services/services.dart';
import '../components/formatters.dart';
import '../components/nodes.dart';
import '../render_context.dart';
import '../widget.dart';

class RepositoryWidget extends DashboardWidget {
  RepositoryWidget(super.config, super.id);

  @override
  String get type => 'repository';

  @override
  String get defaultTitle => 'Repository';

  @override
  Future<Node> renderBody(Services services, RenderContext ctx) async {
    final repo = config.options['repository'] as String? ?? '';
    final prLimit = config.options['pull-requests-limit'] as int? ?? 3;
    final issuesLimit = config.options['issues-limit'] as int? ?? 3;
    final commitsLimit = config.options['commits-limit'] as int? ?? 5;

    if (repo.isEmpty) {
      return p({'cls': 'widget-empty'}, 'No repository configured.');
    }

    final data = await ctx.cache
        .fetch<Map<String, dynamic>>('info', config.cache, () async {
      final headers = {'Accept': 'application/vnd.github.v3+json'};

      final responses = await Future.wait([
        services.httpClient.get(
          Uri.parse('https://api.github.com/repos/$repo'),
          headers: headers,
        ),
        services.httpClient.get(
          Uri.parse(
            'https://api.github.com/repos/$repo/pulls?state=open&per_page=$prLimit',
          ),
          headers: headers,
        ),
        services.httpClient.get(
          Uri.parse(
            'https://api.github.com/repos/$repo/issues?state=open&per_page=${issuesLimit + 10}&pulls=false',
          ),
          headers: headers,
        ),
        services.httpClient.get(
          Uri.parse(
            'https://api.github.com/repos/$repo/commits?per_page=$commitsLimit',
          ),
          headers: headers,
        ),
      ]);

      for (final r in responses) {
        if (r.statusCode != 200) {
          throw Exception('GitHub API HTTP ${r.statusCode}');
        }
      }

      final repoData = jsonDecode(responses[0].body) as Map<String, dynamic>;
      final prsData = jsonDecode(responses[1].body) as List;
      final issuesRaw = jsonDecode(responses[2].body) as List;
      final commitsData = jsonDecode(responses[3].body) as List;

      final issuesData = issuesRaw
          .cast<Map<String, dynamic>>()
          .where((i) => !i.containsKey('pull_request'))
          .take(issuesLimit)
          .toList();

      return {
        'repo': repoData,
        'prs': prsData.cast<Map<String, dynamic>>(),
        'issues': issuesData,
        'commits': commitsData.cast<Map<String, dynamic>>(),
      };
    });

    final repoData = data['repo'] as Map<String, dynamic>;
    final prs = data['prs'] as List<Map<String, dynamic>>;
    final issues = data['issues'] as List<Map<String, dynamic>>;
    final commits = data['commits'] as List<Map<String, dynamic>>;

    final stars = repoData['stargazers_count'] as int? ?? 0;
    final forks = repoData['forks_count'] as int? ?? 0;
    final openIssues = repoData['open_issues_count'] as int? ?? 0;
    final description = repoData['description'] as String? ?? '';
    final repoUrl = repoData['html_url'] as String? ?? '#';

    return div(
      {},
      [
        div(
          {'cls': 'repo-stats'},
          [
            span({}, t('⭐ $stars')),
            span({}, t('🍴 $forks')),
            span({}, t('🐛 $openIssues')),
          ],
        ),
        if (description.isNotEmpty) p({'cls': 'repo-desc'}, t(description)),
        div(
          {'cls': 'repo-section'},
          [
            div({'cls': 'repo-section-title'}, t('Pull Requests')),
            if (prs.isEmpty)
              p({'cls': 'widget-empty'}, 'No open pull requests.')
            else
              ul(
                {'cls': 'repo-list'},
                prs.map((pr) {
                  final number = pr['number'] as int? ?? 0;
                  final title = pr['title'] as String? ?? '';
                  final url = pr['html_url'] as String? ?? repoUrl;
                  final user = (pr['user'] as Map<String, dynamic>?)?['login']
                          as String? ??
                      '';
                  final createdAt = pr['created_at'] as String? ?? '';
                  final age = createdAt.isNotEmpty
                      ? relativeAge(DateTime.parse(createdAt))
                      : '';

                  return li(
                    {},
                    [
                      extLink(url, t('#$number $title')),
                      span({'cls': 'repo-meta'}, t('by $user · $age')),
                    ],
                  );
                }).toList(),
              ),
          ],
        ),
        div(
          {'cls': 'repo-section'},
          [
            div({'cls': 'repo-section-title'}, t('Issues')),
            if (issues.isEmpty)
              p({'cls': 'widget-empty'}, 'No open issues.')
            else
              ul(
                {'cls': 'repo-list'},
                issues.map((issue) {
                  final number = issue['number'] as int? ?? 0;
                  final title = issue['title'] as String? ?? '';
                  final url = issue['html_url'] as String? ?? repoUrl;
                  final user = (issue['user']
                          as Map<String, dynamic>?)?['login'] as String? ??
                      '';
                  final createdAt = issue['created_at'] as String? ?? '';
                  final age = createdAt.isNotEmpty
                      ? relativeAge(DateTime.parse(createdAt))
                      : '';

                  return li(
                    {},
                    [
                      extLink(url, t('#$number $title')),
                      span({'cls': 'repo-meta'}, t('by $user · $age')),
                    ],
                  );
                }).toList(),
              ),
          ],
        ),
        div(
          {'cls': 'repo-section'},
          [
            div({'cls': 'repo-section-title'}, t('Commits')),
            if (commits.isEmpty)
              p({'cls': 'widget-empty'}, 'No commits found.')
            else
              ul(
                {'cls': 'repo-list'},
                commits.map((c) {
                  final sha = (c['sha'] as String? ?? '').substring(0, 7);
                  final commitObj = c['commit'] as Map<String, dynamic>? ?? {};
                  final message =
                      (commitObj['message'] as String? ?? '').split('\n').first;
                  final url = c['html_url'] as String? ?? repoUrl;
                  final author = (commitObj['author']
                          as Map<String, dynamic>?)?['name'] as String? ??
                      '';
                  final dateStr = (commitObj['author']
                          as Map<String, dynamic>?)?['date'] as String? ??
                      '';
                  final age = dateStr.isNotEmpty
                      ? relativeAge(DateTime.parse(dateStr))
                      : '';

                  return li(
                    {},
                    [
                      extLink(url, t('$sha $message')),
                      span({'cls': 'repo-meta'}, t('by $author · $age')),
                    ],
                  );
                }).toList(),
              ),
          ],
        ),
      ],
    );
  }
}
