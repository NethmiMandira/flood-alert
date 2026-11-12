import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/report_model.dart';
import '../../../core/utils/report_labels.dart';

// One report in the list: severity-colored icon, type, description, meta line
class ReportCard extends StatelessWidget {
  final ReportModel report;

  const ReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    // createdAt is null for a moment while the server timestamp is pending
    final time = report.createdAt == null
        ? ''
        : DateFormat('MMM d, HH:mm').format(report.createdAt!);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        isThreeLine: true,
        leading: CircleAvatar(
          backgroundColor: severityColor(report.severity),
          child: Icon(typeIcon(report.type), color: Colors.white),
        ),
        title: Text('${typeLabel(t, report.type)} • ${report.district}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${t.reportedBy} ${report.userName}  •  $time  •  '
              '${t.confirmations}: ${report.confirmCount}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}