import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: s.themeMode,
      locale: s.locale,
      supportedLocales: const [Locale('si'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SetupTestScreen(),
    );
  }
}

class SetupTestScreen extends StatelessWidget {
  const SetupTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final s = context.watch<SettingsProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(t.appTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(t.language, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => s.setLocale('si'),
                  child: const Text('සිංහල'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => s.setLocale('en'),
                  child: const Text('English'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: Text(t.darkMode),
              value: s.isDark,
              onChanged: s.setDark,
            ),
          ],
        ),
      ),
    );
  }
}