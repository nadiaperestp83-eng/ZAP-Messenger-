//
//  ghost_mode_controller.dart
//
//  "Modo Ghost": lets the person read messages without the ordinary
//  read-receipt (✓✓) ever being sent — TDLib simply never advances its read
//  cursor for incoming messages while this is on, so the sender keeps seeing
//  the chat as unread until Ghost Mode is turned back off.
//
//  A second, independent switch ("Cortar internet") fully pauses the app's
//  connection to Telegram via TDLib's own `setNetworkType`, the same way a
//  WhatsApp-mod-style "airplane mode for this app only" toggle works: no
//  messages are sent or received while it's on, without touching the phone's
//  real Wi-Fi/mobile data.
//
//  A plain singleton ChangeNotifier on purpose — this needs to be readable
//  from chat_view_model.dart without threading a new constructor dependency
//  through every call site that builds a ChatViewModel.
//

import 'package:flutter/foundation.dart';

import '../tdlib/td_client.dart';

class GhostModeController extends ChangeNotifier {
  GhostModeController._();

  static final GhostModeController instance = GhostModeController._();

  bool _enabled = false;

  /// When true, incoming messages are never marked as read with TDLib, so no
  /// read receipt is sent to the sender.
  bool get enabled => _enabled;

  set enabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    notifyListeners();
  }

  bool _networkPaused = false;

  /// When true, TDLib believes the device has no network connection at all,
  /// so the app neither sends nor receives anything until this is turned
  /// back off.
  bool get networkPaused => _networkPaused;

  Future<void> setNetworkPaused(bool paused) async {
    if (_networkPaused == paused) return;
    try {
      await TdClient.shared.query({
        '@type': 'setNetworkType',
        'type': {
          '@type': paused ? 'networkTypeNone' : 'networkTypeOther',
        },
      });
      _networkPaused = paused;
      notifyListeners();
    } catch (_) {
      // Leave the flag unchanged if TDLib rejected the call, so the sheet's
      // switch snaps back to reflect the true state.
    }
  }
}
