//
//  embedded_proxy_controller.dart
//
//  A one-tap "free built-in proxy" toggle for the "+" menu. Uses a publicly
//  documented, static MTProto proxy run by StormyCloud Inc (a US 501(c)(3)
//  nonprofit) — see https://stormycloud.org/mtproto/. Unlike the rotating
//  proxy-directory sites, this address is meant to stay fixed, but like any
//  free third-party proxy it could still go offline someday; if that
//  happens, swap the constants below for a different working proxy.
//
//  Reuses the exact same TDLib calls (addProxy / disableProxy / getProxies)
//  and persistence (ProxyConfig) the app's own Proxy settings screen already
//  uses, so this toggle and that screen always agree on the current state.
//

import 'package:flutter/foundation.dart';

import '../tdlib/json_helpers.dart';
import '../tdlib/td_client.dart';
import 'proxy_config.dart';

const embeddedProxyConfig = ProxyConfig(
  configured: true,
  enabled: true,
  type: 'mtproto',
  server: '23.128.248.150',
  port: 3128,
  secret: 'ddc5d1717f50bdab002e1ba52d9ed8f2fe',
);

class EmbeddedProxyController extends ChangeNotifier {
  EmbeddedProxyController._();

  static final EmbeddedProxyController instance = EmbeddedProxyController._();

  bool _enabled = false;
  bool _busy = false;

  bool get enabled => _enabled;
  bool get busy => _busy;

  /// Call once on app start (or before first showing the menu item) so the
  /// switch reflects whether this exact proxy is already the active one —
  /// e.g. if the person turned it on in a previous session, or enabled it
  /// manually from the real Proxy settings screen.
  Future<void> refresh() async {
    try {
      final result = await TdClient.shared.query({'@type': 'getProxies'});
      final proxies = result.objects('proxies') ?? const <Map<String, dynamic>>[];
      final match = proxies.where(
        (p) => embeddedProxyConfig.matchesTdProxy(p) && (p.boolean('is_enabled') ?? false),
      );
      _enabled = match.isNotEmpty;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggle() async {
    if (_busy) return;
    _busy = true;
    notifyListeners();
    try {
      if (_enabled) {
        await TdClient.shared.query({'@type': 'disableProxy'});
        await ProxyConfig.disable();
        _enabled = false;
      } else {
        await TdClient.shared.query(embeddedProxyConfig.addProxyRequest);
        await ProxyConfig.save(embeddedProxyConfig);
        _enabled = true;
      }
    } catch (_) {
      // Leave _enabled as it was — the menu item's switch will just show the
      // last known-good state.
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
