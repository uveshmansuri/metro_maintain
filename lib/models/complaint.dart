class Complaint {
  final String id; // e.g. "C-101"
  final String assetId; // e.g. "L-05"
  final String station; // e.g. "Thaltej"
  final String location; // e.g. "Platform 1"
  final String category; // e.g. "Lift"
  final String problem; // e.g. "Not working"
  final String description; // e.g. "Lift stopped on platform 1..."
  final String priority; // "HIGH", "MEDIUM", "LOW"
  final String status; // "OPEN", "RESOLVED"
  final DateTime timestamp;
  final bool hasPhoto;
  final bool isRepeatedIssue;
  final int clusterCount; // number of repeated reports
  final String? resolvedBy;
  final DateTime? resolvedAt;

  const Complaint({
    required this.id,
    required this.assetId,
    required this.station,
    required this.location,
    required this.category,
    required this.problem,
    required this.description,
    required this.priority,
    required this.status,
    required this.timestamp,
    this.hasPhoto = false,
    this.isRepeatedIssue = false,
    this.clusterCount = 1,
    this.resolvedBy,
    this.resolvedAt,
  });

  Complaint copyWith({
    String? id,
    String? assetId,
    String? station,
    String? location,
    String? category,
    String? problem,
    String? description,
    String? priority,
    String? status,
    DateTime? timestamp,
    bool? hasPhoto,
    bool? isRepeatedIssue,
    int? clusterCount,
    String? resolvedBy,
    DateTime? resolvedAt,
  }) {
    return Complaint(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      station: station ?? this.station,
      location: location ?? this.location,
      category: category ?? this.category,
      problem: problem ?? this.problem,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      hasPhoto: hasPhoto ?? this.hasPhoto,
      isRepeatedIssue: isRepeatedIssue ?? this.isRepeatedIssue,
      clusterCount: clusterCount ?? this.clusterCount,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'assetId': assetId,
        'station': station,
        'location': location,
        'category': category,
        'problem': problem,
        'description': description,
        'priority': priority,
        'status': status,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'hasPhoto': hasPhoto,
        'isRepeatedIssue': isRepeatedIssue,
        'clusterCount': clusterCount,
        'resolvedBy': resolvedBy,
        'resolvedAt': resolvedAt?.millisecondsSinceEpoch,
      };

  factory Complaint.fromMap(Map<String, dynamic> map) => Complaint(
        id: map['id'] ?? '',
        assetId: map['assetId'] ?? '',
        station: map['station'] ?? '',
        location: map['location'] ?? '',
        category: map['category'] ?? '',
        problem: map['problem'] ?? '',
        description: map['description'] ?? '',
        priority: map['priority'] ?? 'MEDIUM',
        status: map['status'] ?? 'OPEN',
        timestamp: DateTime.fromMillisecondsSinceEpoch(
            map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
        hasPhoto: map['hasPhoto'] ?? false,
        isRepeatedIssue: map['isRepeatedIssue'] ?? false,
        clusterCount: map['clusterCount'] ?? 1,
        resolvedBy: map['resolvedBy'],
        resolvedAt: map['resolvedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['resolvedAt'])
            : null,
      );
}
