import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../domain/chat_session.dart';

/// Notifier that holds the AWS Bedrock credentials and config.
class BedrockCredentialsNotifier extends Notifier<BedrockCredentials> {
  @override
  BedrockCredentials build() => const BedrockCredentials.empty();

  void setCredentials(BedrockCredentials creds) => state = creds;

  void clear() => state = const BedrockCredentials.empty();
}

/// Provider for the AWS Bedrock credentials.
final apiKeyProvider =
    NotifierProvider<BedrockCredentialsNotifier, BedrockCredentials>(
      BedrockCredentialsNotifier.new,
    );

/// Riverpod provider for the [ChatSession].
///
/// Returns `null` when credentials are incomplete, so the UI can show the
/// API-key entry screen instead of crashing.
final chatSessionProvider = Provider<ChatSession?>((ref) {
  final creds = ref.watch(apiKeyProvider);
  if (!creds.isValid) return null;
  final session = ChatSession(creds);
  ref.onDispose(session.dispose);
  return session;
});
