import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../l10n/app_localizations.dart';
import '../../models/report_model.dart';
import '../../models/user_model.dart';
import '../../services/location_service.dart';
import '../../services/notify_service.dart';
import '../../services/report_service.dart';
import '../../core/utils/report_labels.dart';

class AddReportScreen extends StatefulWidget {
  final UserModel user;

  const AddReportScreen({super.key, required this.user});

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _locationService = LocationService();
  final _reportService = ReportService();
  final _notifyService = NotifyService();

  ReportType _type = ReportType.flood;
  Severity _severity = Severity.yellow;
  Position? _position;
  bool _locating = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Try to get the location as soon as the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) => _getLocation());
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    final t = AppLocalizations.of(context)!;
    setState(() => _locating = true);

    try {
      final pos = await _locationService.getCurrentPosition();
      if (!mounted) return;
      setState(() => _position = pos);
    } on LocationException catch (e) {
      if (!mounted) return;

      String message = t.locationFailed;
      VoidCallback? settingsAction;

      switch (e.error) {
        case LocationError.serviceDisabled:
          message = t.locationServiceDisabled;
          settingsAction = _locationService.openLocationSettings;
          break;
        case LocationError.denied:
          message = t.locationDenied;
          break;
        case LocationError.deniedForever:
          message = t.locationDeniedForever;
          settingsAction = _locationService.openAppSettings;
          break;
        case LocationError.unknown:
          message = t.locationFailed;
          break;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          action: settingsAction == null
              ? null
              : SnackBarAction(
                  label: t.openSettings,
                  onPressed: settingsAction,
                ),
        ),
      );
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    // A report without a location is useless on the map
    if (_position == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.locationNeeded)));
      return;
    }

    setState(() => _saving = true);
    try {
      final reportId = await _reportService.addReport(
        ReportModel(
          userId: widget.user.uid,
          userName: widget.user.name,
          type: _type,
          severity: _severity,
          description: _descCtrl.text,
          latitude: _position!.latitude,
          longitude: _position!.longitude,
          district: widget.user.district,
        ),
      );

      // Fire and forget: the user should not wait for the notification
      unawaited(_notifyService.notifyReport(reportId));

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.reportSubmitted)));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.reportIncident)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Incident type
                Text(t.reportType, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ReportType.values.map((type) {
                    return ChoiceChip(
                      avatar: Icon(typeIcon(type), size: 18),
                      label: Text(typeLabel(t, type)),
                      selected: _type == type,
                      onSelected: (_) => setState(() => _type = type),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Severity
                Text(t.severity, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: Severity.values.map((s) {
                    return ChoiceChip(
                      avatar: Icon(Icons.circle,
                          size: 14, color: severityColor(s)),
                      label: Text(severityLabel(t, s)),
                      selected: _severity == s,
                      selectedColor: severityColor(s).withValues(alpha: 0.3),
                      onSelected: (_) => setState(() => _severity = s),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Description
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 4,
                  maxLength: 300,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: t.description,
                    hintText: t.descriptionHint,
                    alignLabelWithHint: true,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return t.fieldRequired;
                    if (v.trim().length < 10) return t.descriptionShort;
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Location
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.my_location),
                    title: Text(t.location),
                    subtitle: Text(
                      _position == null
                          ? t.locationNeeded
                          : '${_position!.latitude.toStringAsFixed(5)}, '
                              '${_position!.longitude.toStringAsFixed(5)}',
                    ),
                    trailing: _locating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            tooltip: t.getLocation,
                            icon: const Icon(Icons.refresh),
                            onPressed: _getLocation,
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit
                FilledButton(
                  onPressed: _saving ? null : _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(t.submitReport),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}