Object? resolveValue(String name, Object? context) {
  if (context == null) return null;
  if (name == '.') return context;

  if (context is Map<String, Object?>) {
    if (context.containsKey(name)) return context[name];
  }

  final parts = name.split('.');
  if (parts.length < 2) return null;
  Object? current = context;
  for (final part in parts) {
    if (current is Map<String, Object?>) {
      if (!current.containsKey(part)) return null;
      current = current[part];
    } else {
      return null;
    }
  }
  return current;
}
