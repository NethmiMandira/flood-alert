import 'package:cloud_firestore/cloud_firestore.dart';

// Kinds of incidents a user can report
enum ReportType { flood, landslide, roadBlocked }

// Severity levels: yellow = low, orange = medium, red = high
enum Severity { yellow, orange, red }

class ReportModel {
  final String id;
  final String userId;
  final String userName;
  final ReportType type;
  final Severity severity;
  final String description;
  final double latitude;
  final double longitude;
  final String district;
  final String status; // "active" or "resolved"
  final List<String> confirmedBy; // uids of users who confirmed this report
  final DateTime? createdAt;

  ReportModel({
    this.id = '',
    required this.userId,
    required this.userName,
    required this.type,
    required this.severity,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.district,
    this.status = 'active',
    this.confirmedBy = const [],
    this.createdAt,
  });

  int get confirmCount => confirmedBy.length;
  bool get isActive => status == 'active';

  // Convert to a Firestore map (id is the document id, so it is not stored)
  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'type': type.name,
        'severity': severity.name,
        'description': description.trim(),
        'location': GeoPoint(latitude, longitude),
        'district': district,
        'status': status,
        'confirmedBy': confirmedBy,
        'createdAt': FieldValue.serverTimestamp(),
      };

  // Build a model from a Firestore document
  factory ReportModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? {};
    final geo = map['location'] as GeoPoint?;

    return ReportModel(
      id: doc.id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      type: ReportType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ReportType.flood,
      ),
      severity: Severity.values.firstWhere(
        (e) => e.name == map['severity'],
        orElse: () => Severity.yellow,
      ),
      description: map['description'] ?? '',
      latitude: geo?.latitude ?? 0,
      longitude: geo?.longitude ?? 0,
      district: map['district'] ?? '',
      status: map['status'] ?? 'active',
      confirmedBy: List<String>.from(map['confirmedBy'] ?? []),
      // createdAt is null briefly while the server timestamp is pending
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}