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

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get loginSubtitle => 'Login to stay informed and stay safe';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get passwordMin => 'Password must be at least 6 characters';

  @override
  String get createAccount => 'Create account';

  @override
  String get registerSubtitle =>
      'Join your community and help others stay safe';

  @override
  String get fullName => 'Full name';

  @override
  String get district => 'District';

  @override
  String get selectDistrict => 'Select your district';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordsNotMatch => 'Passwords do not match';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get logout => 'Logout';

  @override
  String get welcome => 'Welcome';

  @override
  String get role => 'Role';

  @override
  String get profile => 'Profile';

  @override
  String get save => 'Save';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get addContact => 'Add contact';

  @override
  String get contactName => 'Name';

  @override
  String get contactPhone => 'Phone number';

  @override
  String get invalidPhone => 'Enter a valid phone number';

  @override
  String get noContacts => 'No emergency contacts yet';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get maxContacts => 'You can add up to 5 contacts';

  @override
  String get emergencyContactsHint =>
      'These people will receive your SOS message in an emergency';
}
