import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final uid = _auth.currentUser!.uid;

    return StreamBuilder<UserModel?>(
      stream: _auth.userStream(uid),
      builder: (context, snapshot) {
        final user = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: Text(t.appTitle),
            actions: [
              // Profile button (only once the profile has loaded)
              if (user != null)
                IconButton(
                  tooltip: t.profile,
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(user: user),
                      ),
                    );
                  },
                ),
              IconButton(
                tooltip: t.logout,
                icon: const Icon(Icons.logout),
                onPressed: () => _auth.logout(),
              ),
            ],
          ),
          body: user == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${t.welcome}, ${user.name}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Text('${t.email}: ${user.email}'),
                      Text('${t.district}: ${user.district}'),
                      Text('${t.role}: ${user.role}'),
                      Text(
                        '${t.emergencyContacts}: '
                        '${user.emergencyContacts.length}',
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}