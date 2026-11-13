import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../l10n/app_localizations.dart';
import '../../models/report_model.dart';
import '../../services/location_service.dart';
import '../../core/utils/report_labels.dart';
import '../report/report_detail_screen.dart';

class MapScreen extends StatefulWidget {
  final List<ReportModel> reports;

  const MapScreen({super.key, required this.reports});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Center of Sri Lanka, used as the starting view
  static const _sriLanka = LatLng(7.8731, 80.7718);

  final _mapController = MapController();
  final _locationService = LocationService();
  bool _locating = false;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // Move the map to the user's current position
  Future<void> _goToMyLocation() async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _locating = true);

    try {
      final pos = await _locationService.getCurrentPosition();
      if (!mounted) return;
      _mapController.move(LatLng(pos.latitude, pos.longitude), 13);
    } on LocationException {
      messenger.showSnackBar(SnackBar(content: Text(t.locationFailed)));
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    // One colored pin per report
    final markers = widget.reports.map((r) {
      return Marker(
        point: LatLng(r.latitude, r.longitude),
        width: 44,
        height: 44,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ReportDetailScreen(report: r),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: severityColor(r.severity),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(blurRadius: 4, color: Colors.black38),
              ],
            ),
            child: Icon(typeIcon(r.type), color: Colors.white, size: 22),
          ),
        ),
      );
    }).toList();

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: _sriLanka,
            initialZoom: 7.5,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.flood_alert',
            ),
            MarkerLayer(markers: markers),

            // Required map data credit
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                color: Colors.white70,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  t.mapCredit,
                  style:
                      const TextStyle(fontSize: 10, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),

        // "My location" button
        Positioned(
          top: 12,
          right: 12,
          child: FloatingActionButton.small(
            heroTag: 'my_location',
            tooltip: t.myLocation,
            onPressed: _locating ? null : _goToMyLocation,
            child: _locating
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
          ),
        ),

        // Severity legend
        Positioned(
          top: 12,
          left: 12,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: Severity.values.map((s) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 12, color: severityColor(s)),
                      const SizedBox(width: 6),
                      Text(severityLabel(t, s),
                          style: const TextStyle(fontSize: 12)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}