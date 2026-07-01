// Chat models for the read-only clerk assistant.

enum ChatRole { user, assistant }

/// A catalog part the assistant referenced, rendered as a tappable chip.
class ChatCitation {
  const ChatCitation({required this.partId, required this.name, required this.primaryNumber});

  final String partId;
  final String name;
  final String? primaryNumber;

  factory ChatCitation.fromJson(Map<String, dynamic> j) => ChatCitation(
    partId: j['partId'] as String,
    name: j['name'] as String,
    primaryNumber: j['primaryNumber'] as String?,
  );
}

class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.text,
    this.citations = const [],
    this.isError = false,
  });

  final ChatRole role;
  final String text;
  final List<ChatCitation> citations;
  final bool isError;
}
