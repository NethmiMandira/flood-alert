import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';

class ReportService {
  final CollectionReference<Map<String, dynamic>> _reports =
      FirebaseFirestore.instance.collection('reports');

  // Save a new report
   // Save a new report and return its document id
  Future<String> addReport(ReportModel report) async {
    final ref = await _reports.add(report.toMap());
    return ref.id;
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