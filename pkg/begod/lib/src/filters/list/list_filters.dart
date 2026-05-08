import '../filter.dart';

class SplitFilter extends MustacheFilter {
  @override
  String get name => 'split';

  @override
  Object? apply(Object? input, List<Object?> args) {
    if (input is! String) return <String>[];
    final delimiter =
        args.isNotEmpty && args[0] is String ? args[0] as String : ',';
    return input.split(delimiter);
  }
}

class JoinFilter extends MustacheFilter {
  @override
  String get name => 'join';

  @override
  Object? apply(Object? input, List<Object?> args) {
    if (input is! List) return input?.toString() ?? '';
    final delimiter =
        args.isNotEmpty && args[0] is String ? args[0] as String : '';
    return input.map((e) => e.toString()).join(delimiter);
  }
}

class SizeFilter extends MustacheFilter {
  @override
  String get name => 'size';

  @override
  Object? apply(Object? input, List<Object?> args) {
    if (input is List) return input.length;
    if (input is String) return input.length;
    if (input is Map) return input.length;
    return 0;
  }
}

class FirstFilter extends MustacheFilter {
  @override
  String get name => 'first';

  @override
  Object? apply(Object? input, List<Object?> args) {
    if (input is List && input.isNotEmpty) return input.first;
    if (input is String && input.isNotEmpty) return input[0];
    return '';
  }
}

class LastFilter extends MustacheFilter {
  @override
  String get name => 'last';

  @override
  Object? apply(Object? input, List<Object?> args) {
    if (input is List && input.isNotEmpty) return input.last;
    if (input is String && input.isNotEmpty) return input[input.length - 1];
    return '';
  }
}

class AtFilter extends MustacheFilter {
  @override
  String get name => 'at';

  @override
  Object? apply(Object? input, List<Object?> args) {
    if (args.isEmpty || args[0] is! num) return '';
    final index = (args[0] as num).toInt();
    if (input is List) {
      final i = index < 0 ? input.length + index : index;
      if (i < 0 || i >= input.length) return '';
      return input[i];
    }
    if (input is String) {
      final i = index < 0 ? input.length + index : index;
      if (i < 0 || i >= input.length) return '';
      return input[i];
    }
    return '';
  }
}

class TakeFilter extends MustacheFilter {
  @override
  String get name => 'take';

  @override
  Object? apply(Object? input, List<Object?> args) {
    if (args.isEmpty || args[0] is! num) return '';
    final count = (args[0] as num).toInt();
    if (count <= 0) return '';
    if (input is List) return input.take(count).toList();
    if (input is String)
      return input.substring(0, count.clamp(0, input.length));
    return '';
  }
}
