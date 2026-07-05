// Chat models for the read-only clerk assistant.

enum ChatRole { user, assistant }

/// Something the assistant referenced this turn, rendered as a tappable chip:
/// a canonical part or a diagram/assembly.
sealed class ChatCitation {
  const ChatCitation();

  /// Backend tags each citation with `type`; a missing type is an older-shape
  /// part citation.
  factory ChatCitation.fromJson(Map<String, dynamic> j) {
    return j['type'] == 'assembly'
        ? AssemblyCitation.fromJson(j)
        : PartCitation.fromJson(j);
  }
}

/// A catalog part, opening its detail screen.
class PartCitation extends ChatCitation {
  const PartCitation({required this.partId, required this.name, required this.primaryNumber});

  final String partId;
  final String name;
  final String? primaryNumber;

  factory PartCitation.fromJson(Map<String, dynamic> j) => PartCitation(
    partId: j['partId'] as String,
    name: j['name'] as String,
    primaryNumber: j['primaryNumber'] as String?,
  );
}

/// A diagram/assembly, opening its diagram screen.
class AssemblyCitation extends ChatCitation {
  const AssemblyCitation({
    required this.assemblyId,
    required this.code,
    required this.name,
    required this.machine,
  });

  final String assemblyId;
  final String code; // E-4 / F-13
  final String name; // Cylinder Head
  final String machine; // "Honda PCX160"

  factory AssemblyCitation.fromJson(Map<String, dynamic> j) => AssemblyCitation(
    assemblyId: j['assemblyId'] as String,
    code: j['code'] as String,
    name: j['name'] as String,
    machine: j['machine'] as String,
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
