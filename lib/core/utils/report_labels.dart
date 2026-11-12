import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/report_model.dart';

// Localized name of an incident type
String typeLabel(AppLocalizations t, ReportType type) {
  switch (type) {
    case ReportType.flood:
      return t.flood;
    case ReportType.landslide:
      return t.landslide;
    case ReportType.roadBlocked:
      return t.roadBlocked;
  }
}

// Icon for each incident type
IconData typeIcon(ReportType type) {
  switch (type) {
    case ReportType.flood:
      return Icons.water;
    case ReportType.landslide:
      return Icons.landscape;
    case ReportType.roadBlocked:
      return Icons.block;
  }
}

// Localized name of a severity level
String severityLabel(AppLocalizations t, Severity severity) {
  switch (severity) {
    case Severity.yellow:
      return t.severityYellow;
    case Severity.orange:
      return t.severityOrange;
    case Severity.red:
      return t.severityRed;
  }
}

// Color for each severity level (also used for map pins later)
Color severityColor(Severity severity) {
  switch (severity) {
    case Severity.yellow:
      return const Color(0xFFF9A825);
    case Severity.orange:
      return const Color(0xFFEF6C00);
    case Severity.red:
      return const Color(0xFFC62828);
  }
}