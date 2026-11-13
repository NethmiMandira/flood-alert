import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/report_service.dart';
import '../../models/user_model.dart';
import '../../models/report_model.dart';
import '../profile/profile_screen.dart';
import '../report/add_report_screen.dart';
import '../report/widgets/report_card.dart';
import '../map/map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = AuthService();
  final _reportService = ReportService();

  // Created once, so rebuilding the screen does not restart the Firestore stream
  late final Stream<List<ReportModel>> _reportsStream =
      _reportService.activeReportsStream();

  int _tab = 0; // 0 = list, 1 = map

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final uid = _auth.currentUser!.uid;

    return StreamBuilder<UserModel?>(
      stream: _auth.userStream(uid),
      builder: (context, userSnap) {
        final user = userSnap.data;

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
                  heroTag: 'add_report',
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

          bottomNavigationBar: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.list_alt),
                label: t.list,
              ),
              NavigationDestination(
                icon: const Icon(Icons.map_outlined),
                selectedIcon: const Icon(Icons.map),
                label: t.map,
              ),
            ],
          ),

          body: user == null
              ? const Center(child: CircularProgressIndicator())
              : StreamBuilder<List<ReportModel>>(
                  stream: _reportsStream,
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return Center(child: Text('${snap.error}'));
                    }
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final reports = snap.data!;

                    // IndexedStack keeps the map alive (zoom and position)
                    // when switching tabs
                    return IndexedStack(
                      index: _tab,
                      children: [
                        _ReportsTab(userName: user.name, reports: reports),
                        MapScreen(reports: reports),
                      ],
                    );
                  },
                ),
        );
      },
    );
  }
}

// List tab: welcome text and the list of recent reports
class _ReportsTab extends StatelessWidget {
  final String userName;
  final List<ReportModel> reports;

  const _ReportsTab({required this.userName, required this.reports});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('${t.welcome}, $userName',
              style: theme.textTheme.titleLarge),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(t.recentReports, style: theme.textTheme.titleMedium),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: reports.isEmpty
              ? Center(child: Text(t.noReports))
              : ListView.builder(
                  // Extra bottom space so the button does not cover the last card
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: reports.length,
                  itemBuilder: (_, i) => ReportCard(report: reports[i]),
                ),
        ),
      ],
    );
  }
}