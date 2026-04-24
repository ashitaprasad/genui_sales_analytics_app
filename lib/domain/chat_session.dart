import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:genui/genui.dart';
import 'package:logging/logging.dart';

import '../models/models.dart';
import '../presentation/catalogs/sales_catalog.dart';
import '../utils/bedrock_transport.dart';
import 'sales_system_prompts.dart';

/// Manages a single GenUI conversation session.
class ChatSession extends ChangeNotifier {
  ChatSession(this._credentials) {
    _init();
  }

  final BedrockCredentials _credentials;
  final Logger _logger = Logger('ChatSession');

  late final BedrockTransport _transport;
  late final SurfaceController _surfaceController;
  late final Conversation _conversation;
  StreamSubscription<ConversationEvent>? _eventsSubscription;

  SurfaceHost get surfaceController => _surfaceController;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final List<ConversationMessage> _messages = [];
  List<ConversationMessage> get messages => List.unmodifiable(_messages);

  void _init() {
    final catalog = buildCatalog();

    final promptBuilder = PromptBuilder.chat(
      catalog: catalog,
      systemPromptFragments: buildSalesSystemPromptFragments(),
    );

    final systemPrompt = promptBuilder.systemPromptJoined();

    _transport = BedrockTransport(
      apiKey: _credentials.apiKey,
      region: _credentials.region,
      modelId: _credentials.modelId,
      systemInstruction: systemPrompt,
      onError: (error, stackTrace) {
        _logger.severe('Transport error', error, stackTrace);
      },
    );

    _surfaceController = SurfaceController(catalogs: [catalog]);

    _conversation = Conversation(
      controller: _surfaceController,
      transport: _transport,
    );

    // Keep isProcessing in sync with conversation state.
    _conversation.state.addListener(_onConversationStateChanged);

    // Map GenUI conversation events to our simplified message list.
    _eventsSubscription = _conversation.events.listen(_onConversationEvent);

    // Kick off the conversation so the AI renders the input form immediately.
    Future<void>.microtask(
      () => _conversation.sendRequest(ChatMessage.user('Start')),
    );
  }

  void _onConversationStateChanged() {
    final isWaiting = _conversation.state.value.isWaiting;
    if (_isProcessing != isWaiting) {
      _isProcessing = isWaiting;
      notifyListeners();
    }
  }

  void _onConversationEvent(ConversationEvent event) {
    switch (event) {
      case ConversationSurfaceAdded(:final surfaceId):
        final alreadyAdded = _messages.any((m) => m.surfaceId == surfaceId);
        if (!alreadyAdded) {
          _messages.add(ConversationMessage.surface(surfaceId));
          notifyListeners();
        }

      case ConversationContentReceived(:final text):
        if (text.isEmpty) return;
        if (_messages.isNotEmpty && !_messages.last.isSurface) {
          // Accumulate streamed text into the last text message.
          final updated = _messages.last.text! + text;
          _messages[_messages.length - 1] = ConversationMessage.text(updated);
        } else {
          _messages.add(ConversationMessage.text(text));
        }
        notifyListeners();

      case ConversationError(:final error):
        _logger.severe('Conversation error', error);
        _errorMessage = '$error';
        _messages.add(ConversationMessage.text('Error: $error'));
        notifyListeners();

      case ConversationWaiting():
      case ConversationComponentsUpdated():
      case ConversationSurfaceRemoved():
        break;
    }
  }

  /// Sends a user message to the AI (e.g., follow-up questions).
  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    _conversation.sendRequest(ChatMessage.user(text));
  }

  @override
  void dispose() {
    _conversation.state.removeListener(_onConversationStateChanged);
    _eventsSubscription?.cancel();
    _transport.dispose();
    super.dispose();
  }
}
