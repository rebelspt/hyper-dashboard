import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

import 'package:hyper_dashboard/src/config/models.dart';
import 'package:hyper_dashboard/src/config/parser.dart';
import 'package:hyper_dashboard/src/server/server.dart';

Future<void> main(List<String> args) async {
  final argParser = ArgParser()
    ..addOption(
      'config',
      abbr: 'c',
      defaultsTo: 'config/hyper-dashboard.yaml',
      help: 'Path to YAML config file',
    )
    ..addOption(
      'port',
      abbr: 'p',
      defaultsTo: '8080',
      help: 'Port to listen on',
    )
    ..addOption(
      'host',
      defaultsTo: 'localhost',
      help: 'Host to bind to',
    )
    ..addOption(
      'assets',
      abbr: 'a',
      defaultsTo: 'assets',
      help: 'Path to assets directory',
    )
    ..addFlag(
      'local-assets',
      negatable: true,
      defaultsTo: false,
      help: 'Serve htmx and Alpine.js from local assets/ instead of CDN',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show usage',
    );

  final results = argParser.parse(args);

  if (results['help'] as bool) {
    print('Usage: dart run bin/hyper_dashboard.dart options\n${argParser.usage}');
    return;
  }

  final configPath = results['config'] as String;
  final port = int.tryParse(results['port'] as String) ?? 8080;
  final host = results['host'] as String;
  final assetsDir = results['assets'] as String;
  final localAssets = results['local-assets'] as bool;

  print('Loading config from $configPath …');

  if (!File(configPath).existsSync()) {
    stderr.writeln('Error: config file not found at "$configPath"');
    stderr.writeln();
    stderr.writeln('  Create one or use --config to point to an existing file.');
    stderr.writeln();
    stderr.writeln('  Examples:');
    stderr.writeln('    dart run bin/hyper_dashboard.dart --config config/demo.yaml');
    stderr.writeln('    dart run bin/hyper_dashboard.dart --config config/themes/tokyo-night.yaml');
    stderr.writeln();
    stderr.writeln('  Run with --help for all options.');
    exit(1);
  }

  late final DashboardConfig config;
  try {
    config = ConfigParser.parse(configPath);
  } on FormatException catch (e) {
    stderr.writeln('Error: invalid YAML in "$configPath" — ${e.message}');
    exit(1);
  }

  final dashboardServer = DashboardServer(config, assetsDir: assetsDir, useLocalAssets: localAssets);
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(dashboardServer.buildHandler());

  try {
    final httpServer = await io.serve(handler, host, port);
    print(
        'Dashboard running → http://${httpServer.address.host}:${httpServer.port}');
    print('Press Ctrl+C to stop.');

    final shutdown = Future(() async {
      await waitForSignal();
      await httpServer.close(force: true);
      print('\nServer shut down.');
    });

    await shutdown;
  } on SocketException catch (e) {
    stderr.writeln('Failed to bind to $host:$port — ${e.message}');
    stderr.writeln(
        'The port may already be in use. Try a different port with --port.');
    exit(1);
  }
}

Future<void> waitForSignal() async {
  final completer = Completer<void>();
  final sigInt = ProcessSignal.sigint.watch().listen((_) {
    print('\nReceived SIGINT, shutting down…');
    completer.complete();
  });
  final sigTerm = ProcessSignal.sigterm.watch().listen((_) {
    print('\nReceived SIGTERM, shutting down…');
    completer.complete();
  });
  await completer.future;
  await sigInt.cancel();
  await sigTerm.cancel();
}
