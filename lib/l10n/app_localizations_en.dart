// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flood Alert';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get reportIncident => 'Report Incident';

  @override
  String get flood => 'Flood';

  @override
  String get landslide => 'Landslide';

  @override
  String get emergencyContacts => 'Emergency Contacts';

  @override
  String get language => 'Language';

  @override
  String get darkMode => 'Dark Mode';
}
