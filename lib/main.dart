import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart' show A2uiValidationException;
import 'package:logging/logging.dart';

import 'providers/providers.dart';
import 'presentation/api_key/api_key_screen.dart';
import 'presentation/chat/chat_screen.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();

      // Route all package logs to the Flutter debug console.
      Logger.root.level = Level.ALL;
      Logger.root.onRecord.listen((record) {
        debugPrint(
          '${record.level.name}: ${record.loggerName}: ${record.message}',
        );
      });

      runApp(const ProviderScope(child: SalesAnalyticsApp()));
    },
    (error, stackTrace) {
      // These are expected when the LLM outputs non-A2UI JSON
      if (error is A2uiValidationException) {
        debugPrint('WARNING: GenUI: A2uiValidationException (ignored): $error');
        return;
      }
      FlutterError.reportError(
        FlutterErrorDetails(exception: error, stack: stackTrace),
      );
    },
  );
}

class SalesAnalyticsApp extends ConsumerWidget {
  const SalesAnalyticsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(chatSessionProvider);
    return MaterialApp(
      title: 'GenUI Sales Analytics',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: session == null ? const ApiKeyScreen() : const ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
