import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models.dart';

class AssistantReply {
  const AssistantReply({required this.reply, required this.citations});
  final String reply;
  final List<ChatCitation> citations;
}

class AssistantApiException implements Exception {
  AssistantApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Client for the read-only clerk chat endpoint (`POST /chat`). Online-only.
class AssistantApi {
  AssistantApi({required this.baseUrl, http.Client? client}) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  String get _base => baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;

  /// Is the backend reachable? Used to drive the online/offline banner.
  Future<bool> ping() async {
    try {
      final res = await _client
          .get(Uri.parse('$_base/health'))
          .timeout(const Duration(seconds: 4));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<AssistantReply> send(List<ChatMessage> history) async {
    final payload = {
      'messages': [
        for (final m in history)
          if (!m.isError)
            {'role': m.role == ChatRole.user ? 'user' : 'assistant', 'content': m.text},
      ],
    };

    final http.Response res;
    try {
      res = await _client
          .post(
            Uri.parse('$_base/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 60));
    } catch (e) {
      throw AssistantApiException('Can’t reach the assistant ($e).');
    }

    if (res.statusCode == 503) {
      throw AssistantApiException('The assistant isn’t configured on the server yet.');
    }
    if (res.statusCode != 200) {
      throw AssistantApiException('Assistant error (HTTP ${res.statusCode}).');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return AssistantReply(
      reply: (body['reply'] as String?)?.trim().isNotEmpty == true
          ? body['reply'] as String
          : '(no answer)',
      citations: [
        for (final c in (body['citations'] as List<dynamic>? ?? const []))
          ChatCitation.fromJson(c as Map<String, dynamic>),
      ],
    );
  }

  void dispose() => _client.close();
}
