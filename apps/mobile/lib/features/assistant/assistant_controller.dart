import 'package:flutter/foundation.dart';

import '../../core/settings/app_settings.dart';
import 'data/assistant_api.dart';
import 'models.dart';

/// Drives the read-only, online-only assistant chat. Holds the transcript and
/// connectivity state; never mutates catalog data.
class AssistantController extends ChangeNotifier {
  AssistantController({required this.settings}) {
    probe();
  }

  final AppSettings settings;

  final List<ChatMessage> messages = [];
  bool sending = false;
  bool? online; // null = unknown/checking

  AssistantApi _api() => AssistantApi(baseUrl: settings.baseUrl);

  Future<void> probe() async {
    final api = _api();
    try {
      online = await api.ping();
    } finally {
      api.dispose();
      notifyListeners();
    }
  }

  Future<void> send(String text) async {
    final content = text.trim();
    if (content.isEmpty || sending) return;

    messages.add(ChatMessage(role: ChatRole.user, text: content));
    sending = true;
    notifyListeners();

    final api = _api();
    try {
      final reply = await api.send(messages);
      messages.add(ChatMessage(role: ChatRole.assistant, text: reply.reply, citations: reply.citations));
      online = true;
    } catch (e) {
      final msg = e is AssistantApiException ? e.message : '$e';
      messages.add(ChatMessage(role: ChatRole.assistant, text: msg, isError: true));
      online = false;
    } finally {
      api.dispose();
      sending = false;
      notifyListeners();
    }
  }

  void clear() {
    messages.clear();
    notifyListeners();
  }
}
