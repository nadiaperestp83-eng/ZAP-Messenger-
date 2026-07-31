//
//  self_destruct_protocol.dart
//
//  A client-side-only "self-destruct" text message. Telegram's protocol has
//  no such concept for plain text, so this works by encoding the real
//  message behind a marker inside the ordinary message text:
//
//    🔒 Mensagem autodestrutiva enviada via ZapZap
//    Baixe o app pra revelar o conteúdo: https://zapzap.app
//    ##ZZSD##<base64 of the real text>##
//
//  - Someone using ZapZap: the bubble hides the invite line entirely and
//    shows a locked card instead. Tapping it reveals the real text for 5
//    seconds with a countdown, then the message is deleted for real.
//  - Someone using stock Telegram (or any other client): they just see the
//    plain text above — the invite line, plus a line of base64 gibberish
//    they can't casually read. Not cryptographically secure (base64 is not
//    encryption), just enough to keep it from being readable at a glance,
//    while still working as a soft invite to try the app.
//
//  Only plain text is supported for now — rich formatting (bold/italic/
//  links) on the hidden content is not preserved.
//

import 'dart:convert';

const _marker = '##ZZSD##';
const _inviteLine1 = '🔒 Mensagem autodestrutiva enviada via ZapZap';
const _inviteLine2 =
    'Baixe o app pra revelar o conteúdo: https://zapzap.app';

/// Builds the text that actually gets sent through Telegram for a
/// self-destruct message.
String buildSelfDestructText(String realContent) {
  final payload = base64Url.encode(utf8.encode(realContent));
  return '$_inviteLine1\n$_inviteLine2\n$_marker$payload$_marker';
}

/// If [rawText] is a self-destruct message, returns the decoded real
/// content. Returns null for any ordinary message.
String? extractSelfDestructPayload(String rawText) {
  final start = rawText.indexOf(_marker);
  if (start < 0) return null;
  final end = rawText.indexOf(_marker, start + _marker.length);
  if (end < 0) return null;
  final encoded = rawText.substring(start + _marker.length, end);
  try {
    return utf8.decode(base64Url.decode(encoded));
  } catch (_) {
    return null;
  }
}

/// True if [rawText] looks like a self-destruct message (cheap check, no
/// decoding — safe to call on every message while scrolling a long chat).
bool looksLikeSelfDestruct(String rawText) => rawText.contains(_marker);
