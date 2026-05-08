import 'helper.dart';
import 'if_helper.dart';
import 'unless_helper.dart';
import 'each_helper.dart';
import 'let_helper.dart';

class HelperRegistry {
  final Map<String, MustacheHelper> _helpers = {};

  void register(MustacheHelper helper) {
    _helpers[helper.name] = helper;
  }

  MustacheHelper? get(String name) => _helpers[name];

  bool contains(String name) => _helpers.containsKey(name);

  static HelperRegistry defaults() {
    final registry = HelperRegistry();
    registry.register(IfHelper());
    registry.register(UnlessHelper());
    registry.register(EachHelper());
    registry.register(LetHelper());
    return registry;
  }
}
