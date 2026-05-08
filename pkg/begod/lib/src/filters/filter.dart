abstract class MustacheFilter {
  String get name;
  Object? apply(Object? input, List<Object?> args);
}
