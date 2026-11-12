import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/report_service.dart';
import '../../models/user_model.dart';
import '../../models/report_model.dart';
import '../profile/profile_screen.dart';
import '../report/add_report_screen.dart';
import '../report/widgets/report_card.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final _auth = AuthService();
  final _reports = ReportService();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final uid = _auth.currentUser!.uid;

    return StreamBuilder<UserModel?>(
      stream: _auth.userStream(uid),
      builder: (context, snapshot) {
        final user = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: Text(t.appTitle),
            actions: [
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

          // Button to report a new incident
          floatingActionButton: user == null
              ? null
              : FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddReportScreen(user: user),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_alert),
                  label: Text(t.reportIncident),
                ),

          body: user == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        '${t.welcome}, ${user.name}',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        t.recentReports,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Live list of recent reports
                    Expanded(
                      child: StreamBuilder<List<ReportModel>>(
                        stream: _reports.activeReportsStream(),
                        builder: (context, snap) {
                          if (snap.hasError) {
                            return Center(child: Text('${snap.error}'));
                          }
                          if (!snap.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final reports = snap.data!;
                          if (reports.isEmpty) {
                            return Center(child: Text(t.noReports));
                          }

                          return ListView.builder(
                            // Extra bottom space so the button does not cover the last card
                            padding: const EdgeInsets.only(bottom: 88),
                            itemCount: reports.length,
                            itemBuilder: (_, i) =>
                                ReportCard(report: reports[i]),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}