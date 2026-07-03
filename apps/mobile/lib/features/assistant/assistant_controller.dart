import 'package:flutter/foundation.dart';

import '../../core/settings/app_settings.dart';
import 'data/assistant_api.dart';
import 'models.dart';

/// Drives the read-only, online-only assistant chat. Holds the transcript;
/// never mutates catalog data. Connectivity state comes from the app-wide
/// ConnectivityController (the screen watches it), not from here.
class AssistantController extends ChangeNotifier {
  AssistantController({required this.settings});

  final AppSettings settings;

  final List<ChatMessage> messages = [];
  bool sending = false;

  AssistantApi _api() => AssistantApi(baseUrl: settings.baseUrl, apiKey: settings.apiKey);

  Future<void> send(String text) async {
    final content = text.trim();
    if (content.isEmpty || sending) return;
    messages.add(ChatMessage(role: ChatRole.user, text: content));
    await _run();
  }

  /// Re-send after a failure: drop the trailing error bubble(s) and run the
  /// request again with the same history — the clerk doesn't retype.
  Future<void> retry() async {
    if (sending) return;
    while (messages.isNotEmpty && messages.last.isError) {
      messages.removeLast();
    }
    if (messages.isEmpty || messages.last.role != ChatRole.user) {
      notifyListeners();
      return;
    }
    await _run();
  }

  Future<void> _run() async {
    sending = true;
    notifyListeners();

    final api = _api();
    try {
      final reply = await api.send(messages);
      messages.add(ChatMessage(role: ChatRole.assistant, text: reply.reply, citations: reply.citations));
    } catch (e) {
      final msg = e is AssistantApiException ? e.message : '$e';
      messages.add(ChatMessage(role: ChatRole.assistant, text: msg, isError: true));
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
