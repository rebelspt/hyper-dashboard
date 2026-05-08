import 'filter.dart';
import 'string/string_filters.dart';
import 'number/number_filters.dart';
import 'list/list_filters.dart';

class FilterRegistry {
  final Map<String, MustacheFilter> _filters = {};

  void register(MustacheFilter filter) {
    _filters[filter.name] = filter;
  }

  MustacheFilter? get(String name) => _filters[name];

  bool contains(String name) => _filters.containsKey(name);

  static FilterRegistry defaults() {
    final registry = FilterRegistry();
    registry.register(UppercaseFilter());
    registry.register(LowercaseFilter());
    registry.register(CapitalizeFilter());
    registry.register(TruncateFilter());
    registry.register(DefaultFilter());
    registry.register(ReplaceFilter());
    registry.register(SliceFilter());
    registry.register(StripHtmlFilter());
    registry.register(UrlEncodeFilter());
    registry.register(TrimFilter());
    registry.register(RoundFilter());
    registry.register(NumberFilter());
    registry.register(FileSizeFilter());
    registry.register(AbsFilter());
    registry.register(SplitFilter());
    registry.register(JoinFilter());
    registry.register(SizeFilter());
    registry.register(FirstFilter());
    registry.register(LastFilter());
    registry.register(AtFilter());
    registry.register(TakeFilter());
    return registry;
  }
}
