/// A message in the conversation — either plain AI text or a GenUI surface.
class ConversationMessage {
  const ConversationMessage.text(this.text) : surfaceId = null;
  const ConversationMessage.surface(this.surfaceId) : text = null;

  final String? text;
  final String? surfaceId;

  bool get isSurface => surfaceId != null;
}
