//
//  keyword_blocker.dart
//
//  Local keyword-based spam blocker. Keywords are stored in SharedPreferences
//  and applied client-side to message text/notifications.
//

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KeywordBlocker extends ChangeNotifier {
  KeywordBlocker._();
  static final KeywordBlocker shared = KeywordBlocker._();

  static const _prefsKey = 'spamBlockKeywords';

  SharedPreferences? _prefs;
  List<String> _keywords = const [];

  List<String> get keywords => List.unmodifiable(_keywords);
  bool get isEnabled => _keywords.isNotEmpty;

  void initialize(SharedPreferences prefs) {
    _prefs = prefs;
    _keywords = _normalizeList(prefs.getStringList(_prefsKey) ?? const []);
  }

  bool matches(String text) {
    if (_keywords.isEmpty || text.trim().isEmpty) return false;
    final normalized = text.toLowerCase();
    return _keywords.any(
      (keyword) => normalized.contains(keyword.toLowerCase()),
    );
  }

  void add(String value) {
    final keyword = _normalize(value);
    if (keyword == null) return;
    if (_keywords.any((k) => k.toLowerCase() == keyword.toLowerCase())) return;
    _keywords = [..._keywords, keyword];
    _save();
  }

  void remove(String value) {
    final lower = value.toLowerCase();
    final next = _keywords.where((k) => k.toLowerCase() != lower).toList();
    if (next.length == _keywords.length) return;
    _keywords = next;
    _save();
  }

  void replaceAll(List<String> values) {
    _keywords = _normalizeList(values);
    _save();
  }

  static List<String> _normalizeList(List<String> values) {
    final out = <String>[];
    final seen = <String>{};
    for (final value in values) {
      final keyword = _normalize(value);
      if (keyword == null) continue;
      final key = keyword.toLowerCase();
      if (seen.add(key)) out.add(keyword);
    }
    return out;
  }

  static String? _normalize(String value) {
    final keyword = value.trim();
    return keyword.isEmpty ? null : keyword;
  }

  void _save() {
    _prefs?.setStringList(_prefsKey, _keywords);
    notifyListeners();
  }
}
