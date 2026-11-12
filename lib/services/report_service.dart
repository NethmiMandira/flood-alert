import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';

class ReportService {
  final CollectionReference<Map<String, dynamic>> _reports =
      FirebaseFirestore.instance.collection('reports');

  // Save a new report
  Future<void> addReport(ReportModel report) async {
    await _reports.add(report.toMap());
  }

  // Live stream of the latest reports, newest first.
  // Filtering by status is done on the client so we do not need
  // a composite Firestore index yet.
  Stream<List<ReportModel>> activeReportsStream({int limit = 100}) {
    return _reports
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ReportModel.fromDoc(doc))
            .where((r) => r.isActive)
            .toList());
  }
}