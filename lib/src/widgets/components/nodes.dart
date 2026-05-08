import 'package:dartkup/dartkup.dart';

/// External link with security attributes baked in.
///
/// Eliminates repeating `target: _blank, rel: noopener noreferrer` across widgets.
Node extLink(
  String href,
  Object? children, {
  String? cls,
  Map<String, dynamic>? extra,
}) =>
    a(
      {
        'href': href,
        if (cls != null) 'cls': cls,
        'target': '_blank',
        'rel': 'noopener noreferrer',
        if (extra != null) ...extra,
      },
      children,
    );

/// Icon image loaded from the Simple Icons CDN.
///
/// Hides itself via `onerror` when the icon name is not found in the CDN.
Node simpleIcon(String name, {required String cls}) => img({
      'src': 'https://cdn.simpleicons.org/$name',
      'cls': cls,
      'alt': '',
      'onerror': "this.style.display='none'",
    });
