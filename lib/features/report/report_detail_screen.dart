import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../../l10n/app_localizations.dart';
import '../../models/report_model.dart';
import '../../core/utils/report_labels.dart';

class ReportDetailScreen extends StatelessWidget {
  final ReportModel report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final color = severityColor(report.severity);
    final point = LatLng(report.latitude, report.longitude);

    final time = report.createdAt == null
        ? '-'
        : DateFormat('yyyy-MM-dd HH:mm').format(report.createdAt!);

    return Scaffold(
      appBar: AppBar(title: Text(t.reportDetails)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header: type icon, type name and severity
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color,
                child: Icon(typeIcon(report.type),
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(typeLabel(t, report.type),
                        style: theme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Chip(
                      avatar: Icon(Icons.circle, size: 12, color: color),
                      label: Text(severityLabel(t, report.severity)),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.description, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Text(report.description),
                ],
              ),
            ),
          ),

          // Info rows
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.location_city),
                  title: Text(t.district),
                  subtitle: Text(report.district),
                ),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(t.reportedBy),
                  subtitle: Text(report.userName),
                ),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(t.reportedOn),
                  subtitle: Text(time),
                ),
                ListTile(
                  leading: const Icon(Icons.verified_outlined),
                  title: Text(t.confirmations),
                  subtitle: Text('${report.confirmCount}'),
                ),
                ListTile(
                  leading: const Icon(Icons.pin_drop_outlined),
                  title: Text(t.coordinates),
                  subtitle: Text(
                    '${report.latitude.toStringAsFixed(5)}, '
                    '${report.longitude.toStringAsFixed(5)}',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Small non-interactive map showing where the incident is
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 200,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: point,
                  initialZoom: 14,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.flood_alert',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        width: 44,
                        height: 44,
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Icon(typeIcon(report.type),
                              color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      color: Colors.white70,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        t.mapCredit,
                        style: const TextStyle(
                            fontSize: 10, color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}