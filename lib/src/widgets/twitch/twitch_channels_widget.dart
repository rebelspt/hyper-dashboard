import 'dart:convert' show jsonDecode;
import 'package:dartkup/dartkup.dart';
import '../../services/services.dart';
import '../components/nodes.dart';
import '../render_context.dart';
import '../widget.dart';
import 'twitch_api.dart';

class TwitchChannelsWidget extends DashboardWidget {
  TwitchChannelsWidget(super.config, super.id);

  @override
  String get type => 'twitch-channels';

  @override
  String get defaultTitle => 'Twitch Channels';

  @override
  Future<Node> renderBody(Services services, RenderContext ctx) async {
    final clientId = config.options['client-id'] as String? ?? '';
    final clientSecret = config.options['client-secret'] as String? ?? '';

    if (clientId.isEmpty || clientSecret.isEmpty) {
      return p(
        {'cls': 'widget-error'},
        'Twitch client-id and client-secret are required.',
      );
    }

    final rawChannels = config.options['channels'];
    final channels = rawChannels is List
        ? rawChannels.cast<Object>().map((e) => e.toString()).toList()
        : <String>[];

    if (channels.isEmpty) {
      return p({'cls': 'widget-empty'}, 'No channels configured.');
    }

    final collapseAfter =
        config.options['collapse-after'] as int? ?? channels.length;

    final allChannels = await ctx.cache
        .fetch<List<_ChannelInfo>>('channels', config.cache, () async {
      final token =
          await fetchTwitchToken(ctx, services, clientId, clientSecret);
      final loginParams = channels.map((c) => 'user_login=$c').join('&');

      final results = await Future.wait([
        services.httpClient.get(
          Uri.parse('https://api.twitch.tv/helix/streams?$loginParams'),
          headers: {'Client-Id': clientId, 'Authorization': 'Bearer $token'},
        ),
        services.httpClient.get(
          Uri.parse('https://api.twitch.tv/helix/users?$loginParams'),
          headers: {'Client-Id': clientId, 'Authorization': 'Bearer $token'},
        ),
      ]);

      final streamsResp = results[0];
      final usersResp = results[1];

      if (streamsResp.statusCode != 200) {
        throw Exception('Twitch streams API: HTTP ${streamsResp.statusCode}');
      }
      if (usersResp.statusCode != 200) {
        throw Exception('Twitch users API: HTTP ${usersResp.statusCode}');
      }

      final streamsData = (jsonDecode(streamsResp.body)
          as Map<String, dynamic>)['data'] as List;
      final usersData =
          (jsonDecode(usersResp.body) as Map<String, dynamic>)['data'] as List;

      final liveByLogin = <String, Map<String, dynamic>>{};
      for (final s in streamsData.cast<Map<String, dynamic>>()) {
        if (s['type'] == 'live') {
          liveByLogin[(s['user_login'] as String? ?? '').toLowerCase()] = s;
        }
      }

      final usersByLogin = <String, Map<String, dynamic>>{};
      for (final u in usersData.cast<Map<String, dynamic>>()) {
        usersByLogin[(u['login'] as String? ?? '').toLowerCase()] = u;
      }

      final infos = channels.map((ch) {
        final loginKey = ch.toLowerCase();
        final user = usersByLogin[loginKey];
        final stream = liveByLogin[loginKey];
        return _ChannelInfo(
          login: loginKey,
          displayName: user?['display_name'] as String? ?? ch,
          profileImage: user?['profile_image_url'] as String? ?? '',
          isLive: stream != null,
          gameName: stream?['game_name'] as String? ?? '',
          viewerCount: stream?['viewer_count'] as int? ?? 0,
          streamTitle: stream?['title'] as String? ?? '',
        );
      }).toList();

      infos.sort((a, b) {
        if (a.isLive == b.isLive) return 0;
        return a.isLive ? -1 : 1;
      });

      return infos;
    });

    if (allChannels.isEmpty) {
      return p({'cls': 'widget-empty'}, 'No channel data available.');
    }

    final visibleChannels = allChannels.take(collapseAfter).toList();
    final hiddenChannels = allChannels.length > collapseAfter
        ? allChannels.skip(collapseAfter).toList()
        : <_ChannelInfo>[];

    final visibleItems = visibleChannels.map(_buildChannelItem).toList();

    if (hiddenChannels.isEmpty) {
      return ul({'cls': 'twitch-list'}, visibleItems);
    }

    final hiddenItems = hiddenChannels.map(_buildChannelItem).toList();
    final groupId = 'twitch-more-$id';

    final js = '''
(function(){
  var btn = document.getElementById('$groupId-btn');
  var extra = document.getElementById('$groupId');
  if(btn && extra){
    btn.addEventListener('click', function(){
      extra.style.display = extra.style.display === 'none' ? '' : 'none';
      btn.textContent = extra.style.display === 'none' ? 'Show ${hiddenChannels.length} more' : 'Show less';
    });
  }
}());''';

    return fragment([
      ul(
        {'cls': 'twitch-list'},
        [
          ...visibleItems,
          li(
            {},
            button(
              {'cls': 'twitch-show-more', 'id': '$groupId-btn'},
              'Show ${hiddenChannels.length} more',
            ),
          ),
          ul(
            {'cls': 'twitch-list', 'id': groupId, 'style': 'display:none'},
            hiddenItems,
          ),
        ],
      ),
      script({}, raw(js)),
    ]);
  }

  Node _buildChannelItem(_ChannelInfo ch) {
    if (ch.isLive) {
      return li(
        {'cls': 'twitch-channel twitch-channel--live'},
        [
          if (ch.profileImage.isNotEmpty)
            img({'src': ch.profileImage, 'cls': 'twitch-avatar', 'alt': ''}),
          div(
            {'cls': 'twitch-info'},
            [
              extLink(
                'https://twitch.tv/${ch.login}',
                t(ch.displayName),
                cls: 'twitch-name',
              ),
              div({'cls': 'twitch-game'}, t(ch.gameName)),
            ],
          ),
          span({'cls': 'twitch-viewers'}, t(_formatViewers(ch.viewerCount))),
          span({'cls': 'twitch-badge twitch-badge--live'}, 'LIVE'),
        ],
      );
    } else {
      return li(
        {'cls': 'twitch-channel twitch-channel--offline'},
        [
          if (ch.profileImage.isNotEmpty)
            img({'src': ch.profileImage, 'cls': 'twitch-avatar', 'alt': ''}),
          div(
            {'cls': 'twitch-info'},
            [
              extLink(
                'https://twitch.tv/${ch.login}',
                t(ch.displayName),
                cls: 'twitch-name',
              ),
              div({'cls': 'twitch-game twitch-offline'}, 'Offline'),
            ],
          ),
        ],
      );
    }
  }

  String _formatViewers(int count) {
    if (count >= 1000) {
      final k = count / 1000;
      return '${k.toStringAsFixed(1)}k viewers';
    }
    return '$count viewers';
  }
}

class _ChannelInfo {
  final String login;
  final String displayName;
  final String profileImage;
  final bool isLive;
  final String gameName;
  final int viewerCount;
  final String streamTitle;

  const _ChannelInfo({
    required this.login,
    required this.displayName,
    required this.profileImage,
    required this.isLive,
    required this.gameName,
    required this.viewerCount,
    required this.streamTitle,
  });
}
