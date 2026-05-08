import '../filter.dart';

class RoundFilter extends MustacheFilter {
  @override
  String get name => 'round';

  @override
  Object? apply(Object? input, List<Object?> args) {
    if (input is! num) return input?.toString() ?? '';
    final decimals =
        args.isNotEmpty && args[0] is num ? (args[0] as num).toInt() : 0;
    return (input).toStringAsFixed(decimals);
  }
}

class NumberFilter extends MustacheFilter {
  @override
  String get name => 'number';

  @override
  Object? apply(Object? input, List<Object?> args) {
    if (input is! num) return input?.toString() ?? '';
    final parts = input.toString().split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
      buf.write(intPart[i]);
    }
    if (parts.length > 1) buf.write('.${parts[1]}');
    return buf.toString();
  }
}

class FileSizeFilter extends MustacheFilter {
  @override
  String get name => 'filesize';

  @override
  Object? apply(Object? input, List<Object?> args) {
    if (input is! num || input < 0) return input?.toString() ?? '';
    const units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
    var size = input.toDouble();
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    final formatted = size.toStringAsFixed(1);
    return '$formatted ${units[unitIndex]}';
  }
}

class AbsFilter extends MustacheFilter {
  @override
  String get name => 'abs';

  @override
  Object? apply(Object? input, List<Object?> args) {
    if (input is! num) return input?.toString() ?? '';
    return input.abs().toString();
  }
}
