//
//  location_picker_view.dart
//
//  Messenger-style location sheet, redesigned as a proper bottom sheet:
//  a small drag handle, a map filling ~40% of the sheet with a fixed centre
//  pin (pan to aim), a green "send my current location" card, and a list of
//  nearby places below it. The places list is powered by TDLib's own
//  @foursquare inline bot — the same venue-search mechanism the official
//  Telegram apps use — instead of a generic reverse-geocode lookup.
//
//  Uses the native Apple Maps (MapKit) on iOS and flutter_map + OpenStreetMap
//  tiles elsewhere.
//

import 'dart:async';
import 'dart:io';

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as amap;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../components/app_icons.dart';
import '../components/ui_components.dart';
import '../tdlib/json_helpers.dart';
import '../tdlib/td_client.dart';
import '../theme/app_theme.dart';

const defaultLocationPickerCenter = LatLng(35.681236, 139.767125);

Future<LatLng> resolveLocationPickerStart() async {
  try {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return defaultLocationPickerCenter;
    }
    final position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  } catch (_) {
    return defaultLocationPickerCenter;
  }
}

class LocationPickerResult {
  const LocationPickerResult({required this.center, required this.zoom});

  final LatLng center;
  final double zoom;
}

class LocationShareResult {
  const LocationShareResult({required this.center, required this.address});

  final LatLng center;
  final String address;
}

class _Venue {
  const _Venue({
    required this.title,
    required this.address,
    required this.location,
  });

  final String title;
  final String address;
  final LatLng location;
}

/// Presents the location picker as a proper rounded bottom sheet over the
/// current screen (rather than a full-screen page push), matching the
/// reference layout. Returns whatever [LocationPickerView] itself would pop.
Future<T?> showLocationPickerSheet<T>({
  required BuildContext context,
  required LatLng initial,
  double initialZoom = 16,
  bool returnCamera = false,
  bool returnShareResult = false,
  int? chatId,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => LocationPickerView(
      initial: initial,
      initialZoom: initialZoom,
      returnCamera: returnCamera,
      returnShareResult: returnShareResult,
      chatId: chatId,
    ),
  );
}

class LocationPickerView extends StatefulWidget {
  const LocationPickerView({
    super.key,
    required this.initial,
    this.initialZoom = 16,
    this.returnCamera = false,
    this.returnShareResult = false,
    this.chatId,
  });

  final LatLng initial;
  final double initialZoom;
  final bool returnCamera;
  final bool returnShareResult;

  /// Needed to resolve nearby places through TDLib's inline-bot mechanism
  /// (inline queries are always scoped to a chat). If omitted, the "Ou
  /// escolha um lugar" section is simply left empty.
  final int? chatId;

  @override
  State<LocationPickerView> createState() => _LocationPickerViewState();
}

class _LocationPickerViewState extends State<LocationPickerView> {
  static const _minimumZoom = 3.0;
  static const _maximumZoom = 20.0;

  final MapController _map = MapController(); // flutter_map (Android / OSM)
  amap.AppleMapController? _appleCtrl; // Apple MapKit (iOS)
  late LatLng _center = widget.initial;
  late double _zoom = widget.initialZoom;
  double? _myAccuracyMeters;
  Timer? _debounce;

  List<_Venue> _venues = [];
  bool _venuesLoading = false;
  int? _foursquareBotUserId;

  @override
  void initState() {
    super.initState();
    unawaited(_refreshMyAccuracy());
    unawaited(_loadVenues());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _map.dispose();
    super.dispose();
  }

  void _onMove(MapCamera camera, bool hasGesture) {
    _center = camera.center;
    _zoom = camera.zoom;
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 650),
      () => unawaited(_loadVenues()),
    );
  }

  Future<void> _refreshMyAccuracy() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted) setState(() => _myAccuracyMeters = position.accuracy);
    } catch (_) {}
  }

  /// Nearby places via TDLib's @foursquare inline bot — the same mechanism
  /// the official Telegram apps use for venue search.
  Future<void> _loadVenues() async {
    final chatId = widget.chatId;
    if (chatId == null) return;
    setState(() => _venuesLoading = true);
    try {
      var botUserId = _foursquareBotUserId;
      if (botUserId == null) {
        final botChat = await TdClient.shared.query({
          '@type': 'searchPublicChat',
          'username': 'foursquare',
        });
        botUserId = botChat.obj('type')?.int64('user_id');
        _foursquareBotUserId = botUserId;
      }
      if (botUserId == null) {
        if (mounted) setState(() => _venuesLoading = false);
        return;
      }
      final result = await TdClient.shared.query({
        '@type': 'getInlineQueryResults',
        'bot_user_id': botUserId,
        'chat_id': chatId,
        'query': '',
        'user_location': {
          '@type': 'location',
          'latitude': _center.latitude,
          'longitude': _center.longitude,
        },
      });
      final raw = result.objects('results') ?? const <Map<String, dynamic>>[];
      final venues = <_Venue>[];
      for (final entry in raw) {
        final venue = entry.obj('venue');
        if (venue == null) continue;
        final loc = venue.obj('location');
        final lat = (loc?['latitude'] as num?)?.toDouble();
        final lng = (loc?['longitude'] as num?)?.toDouble();
        if (lat == null || lng == null) continue;
        venues.add(
          _Venue(
            title: venue.str('title') ?? '',
            address: venue.str('address') ?? '',
            location: LatLng(lat, lng),
          ),
        );
      }
      if (mounted) setState(() => _venues = venues);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _venuesLoading = false);
    }
  }

  Future<void> _myLocation() async {
    try {
      final p = await resolveLocationPickerStart();
      if (Platform.isIOS) {
        unawaited(
          _appleCtrl?.animateCamera(
            amap.CameraUpdate.newLatLngZoom(
              amap.LatLng(p.latitude, p.longitude),
              16,
            ),
          ),
        );
      } else {
        _map.move(p, 16);
      }
      _center = p;
      _zoom = 16;
      unawaited(_loadVenues());
      unawaited(_refreshMyAccuracy());
    } catch (_) {}
  }

  void _changeZoom(double delta) {
    final next = (_zoom + delta).clamp(_minimumZoom, _maximumZoom);
    if ((next - _zoom).abs() < 0.01) return;
    setState(() => _zoom = next);
    if (Platform.isIOS) {
      unawaited(
        _appleCtrl?.animateCamera(
          amap.CameraUpdate.newLatLngZoom(
            amap.LatLng(_center.latitude, _center.longitude),
            next,
          ),
        ),
      );
    } else {
      _map.move(_center, next);
    }
  }

  void _pop(LatLng point, {String address = ''}) => Navigator.of(context).pop(
    widget.returnCamera
        ? LocationPickerResult(center: point, zoom: _zoom)
        : widget.returnShareResult
        ? LocationShareResult(center: point, address: address)
        : point,
  );

  void _sendMyLocationNow() => _pop(_center);

  void _sendVenue(_Venue venue) => _pop(venue.location, address: venue.title);

  /// Native Apple Maps (MapKit) on iOS; flutter_map + OSM tiles elsewhere.
  Widget _mapWidget() {
    if (Platform.isIOS) {
      return amap.AppleMap(
        initialCameraPosition: amap.CameraPosition(
          target: amap.LatLng(
            widget.initial.latitude,
            widget.initial.longitude,
          ),
          zoom: widget.initialZoom,
        ),
        myLocationEnabled: true,
        onMapCreated: (c) => _appleCtrl = c,
        onCameraMove: (pos) {
          _center = LatLng(pos.target.latitude, pos.target.longitude);
          _zoom = pos.zoom;
        },
        onCameraIdle: () {
          _debounce?.cancel();
          _debounce = Timer(
            const Duration(milliseconds: 350),
            () => unawaited(_loadVenues()),
          );
        },
      );
    }
    return FlutterMap(
      mapController: _map,
      options: MapOptions(
        initialCenter: widget.initial,
        initialZoom: widget.initialZoom,
        onPositionChanged: _onMove,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'ad.neko.mithka',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final sheetHeight = MediaQuery.of(context).size.height * 0.86;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        height: sheetHeight,
        color: c.background,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: c.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 10),
            // Map — roughly 40% of the sheet.
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  Positioned.fill(child: _mapWidget()),
                  IgnorePointer(
                    child: Center(
                      child: Transform.translate(
                        offset: const Offset(0, -18),
                        child: AppIcon(
                          HeroAppIcons.locationDot,
                          size: 34,
                          color: AppTheme.brand,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          decoration: BoxDecoration(
                            color: c.card,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _mapControlButton(
                                c,
                                HeroAppIcons.plus,
                                () => _changeZoom(1),
                              ),
                              Divider(height: 1, color: c.divider),
                              _mapControlButton(
                                c,
                                HeroAppIcons.minus,
                                () => _changeZoom(-1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _myLocation,
                          child: Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: c.card,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: AppIcon(
                              HeroAppIcons.locationDot,
                              size: 18,
                              color: AppTheme.brand,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Green "send my current location" card + nearby places — ~60%.
            Expanded(
              flex: 6,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _sendMyLocationNow,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.brand,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                            child: const AppIcon(
                              HeroAppIcons.locationDot,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Enviar Minha Localização Atual',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                if (_myAccuracyMeters != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Precisão de ${_myAccuracyMeters!.round()} metros',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withValues(
                                        alpha: 0.85,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Ou escolha um lugar',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (widget.chatId == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Lugares próximos indisponíveis aqui.',
                        style: TextStyle(fontSize: 13, color: c.textTertiary),
                      ),
                    )
                  else if (_venuesLoading && _venues.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        ),
                      ),
                    )
                  else if (_venues.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Nenhum lugar encontrado por aqui.',
                        style: TextStyle(fontSize: 13, color: c.textTertiary),
                      ),
                    )
                  else
                    for (final venue in _venues)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _sendVenue(venue),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: c.groupedBackground,
                                  shape: BoxShape.circle,
                                ),
                                child: AppIcon(
                                  HeroAppIcons.locationPin,
                                  size: 18,
                                  color: c.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      venue.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: c.textPrimary,
                                      ),
                                    ),
                                    if (venue.address.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        venue.address,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: c.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapControlButton(AppColors c, AppIconData icon, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: 36,
        child: Center(child: AppIcon(icon, size: 18, color: c.textPrimary)),
      ),
    );
  }
}
