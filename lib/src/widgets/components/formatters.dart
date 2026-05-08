/// Returns a human-readable relative age string for [dt] (e.g. "5m ago", "3d ago").
///
/// Uses the most complete variant across all widgets: minutes, hours, days, months.
String relativeAge(DateTime dt) {
  final diff = DateTime.now().difference(dt).abs();
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 30) return '${diff.inDays}d ago';
  final months = (diff.inDays / 30).floor();
  return '$months month${months == 1 ? '' : 's'} ago';
}
