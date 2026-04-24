import 'package:genui/genui.dart';
import 'package:logging/logging.dart';

import '../tools/sales_data_tool.dart';
import 'bedrock_client.dart';

/// A GenUI [Transport] adapter for BedrockClient.
final class BedrockTransport implements Transport {
  BedrockTransport({
    required String apiKey,
    required String region,
    required String modelId,
    required String systemInstruction,
    required void Function(Object error, StackTrace? stack) onError,
    BedrockClient? client,
  }) : _systemInstruction = systemInstruction,
       _onError = onError,
       _adapter = A2uiTransportAdapter(),
       _client =
           client ??
           BedrockClient(region: region, apiKey: apiKey, modelId: modelId);

  static const int _maxRounds = 5;

  final A2uiTransportAdapter _adapter;
  final BedrockClient _client;
  final String _systemInstruction;
  final void Function(Object error, StackTrace? stack) _onError;
  final Logger _logger = Logger('BedrockTransport');

  /// Full Converse message history. Converse is stateless, so we send this
  /// on every request.
  final List<Map<String, Object?>> _messages = [];

  @override
  Stream<A2uiMessage> get incomingMessages => _adapter.incomingMessages;

  @override
  Stream<String> get incomingText => _adapter.incomingText;

  static String _extractUserText(ChatMessage message) {
    final buffer = StringBuffer();
    for (final part in message.parts) {
      if (part.isUiInteractionPart) {
        buffer.write(part.asUiInteractionPart!.interaction);
      } else if (part is TextPart) {
        buffer.write(part.text);
      }
    }
    return buffer.toString();
  }

  @override
  Future<void> sendRequest(ChatMessage message) async {
    final userText = _extractUserText(message);
    if (userText.isEmpty) return;

    // Snapshot history so we can roll back if the round throws.
    final savedLength = _messages.length;

    _messages.add({
      'role': 'user',
      'content': [
        {'text': userText},
      ],
    });

    try {
      final system = [
        {'text': _systemInstruction},
      ];

      var response = await _client.converseRaw(
        system: system,
        messages: _messages,
        toolConfig: salesDataToolConfig,
      );

      // Tool-use loop — run up to [_maxRounds] tool rounds per turn.
      var rounds = 0;
      while (response['stopReason'] == 'tool_use') {
        if (++rounds > _maxRounds) {
          throw StateError(
            'Exceeded $_maxRounds tool-use rounds without a final response.',
          );
        }

        final content = _assistantContent(response);

        // Append the assistant's turn (including toolUse blocks) to history.
        _messages.add({'role': 'assistant', 'content': content});

        // Execute every toolUse block and collect results.
        final toolResults = <Map<String, Object?>>[];
        for (final block in content) {
          final toolUse = block['toolUse'] as Map<String, Object?>?;
          if (toolUse == null) continue;

          final toolUseId = toolUse['toolUseId'] as String;
          final name = toolUse['name'] as String;
          final input = Map<String, Object?>.from(
            (toolUse['input'] as Map?) ?? const {},
          );

          Map<String, Object?> result;
          bool isError = false;
          try {
            _logger.info('Tool call: $name args=$input');
            result = await _runTool(name, input);
          } catch (e, st) {
            _logger.warning('Tool $name failed', e, st);
            result = {'error': '$e'};
            isError = true;
          }

          toolResults.add({
            'toolResult': {
              'toolUseId': toolUseId,
              'content': [
                {'json': result},
              ],
              if (isError) 'status': 'error',
            },
          });
        }

        _messages.add({'role': 'user', 'content': toolResults});

        response = await _client.converseRaw(
          system: system,
          messages: _messages,
          toolConfig: salesDataToolConfig,
        );
      }

      // Final assistant turn — no more tool use. Capture text for A2UI
      // parsing and append to history.
      final finalContent = _assistantContent(response);
      _messages.add({'role': 'assistant', 'content': finalContent});

      final textBuffer = StringBuffer();
      for (final block in finalContent) {
        final text = block['text'] as String?;
        if (text != null) textBuffer.write(text);
      }

      final finalText = textBuffer.toString();
      if (finalText.isNotEmpty) {
        // Forward the entire response to the A2UI adapter. It parses the
        // incremental JSONL and drives SurfaceController; the conversation
        // layer also exposes the raw text via [incomingText].
        _adapter.addChunk(finalText);
      }
    } catch (e, st) {
      // Roll back history so the next request starts from a known-good state.
      while (_messages.length > savedLength) {
        _messages.removeLast();
      }
      _onError(e, st);
      rethrow;
    }
  }

  /// Extracts the `content` list from a Converse response's
  /// `output.message.content`, or an empty list if missing.
  List<Map<String, Object?>> _assistantContent(Map<String, Object?> response) {
    final output = response['output'] as Map<String, Object?>?;
    final message = output?['message'] as Map<String, Object?>?;
    final content = message?['content'] as List<Object?>?;
    if (content == null) return const [];
    return content.whereType<Map<String, Object?>>().toList(growable: false);
  }

  /// Dispatches a Bedrock tool-use invocation to the matching handler.
  Future<Map<String, Object?>> _runTool(
    String name,
    Map<String, Object?> input,
  ) async {
    switch (name) {
      case 'get_sales_data':
        return handleGetSalesData(input);
      default:
        return {'error': 'Unknown tool: $name'};
    }
  }

  @override
  void dispose() {
    _adapter.dispose();
    _client.close();
  }
}
