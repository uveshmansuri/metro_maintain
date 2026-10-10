class MaintenanceRecord {
  final String id;
  final String assetId;
  final String dateText; // e.g. "10 Oct"
  final String type; // e.g. "🔧 Repair", "✓ Routine check"
  final String description;
  final String technician;
  final DateTime timestamp;

  const MaintenanceRecord({
    required this.id,
    required this.assetId,
    required this.dateText,
    required this.type,
    required this.description,
    this.technician = 'Technician',
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'assetId': assetId,
        'dateText': dateText,
        'type': type,
        'description': description,
        'technician': technician,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };

  factory MaintenanceRecord.fromMap(Map<String, dynamic> map) =>
      MaintenanceRecord(
        id: map['id'] ?? '',
        assetId: map['assetId'] ?? '',
        dateText: map['dateText'] ?? '',
        type: map['type'] ?? '🔧 Check',
        description: map['description'] ?? '',
        technician: map['technician'] ?? 'Technician',
        timestamp: DateTime.fromMillisecondsSinceEpoch(
            map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
      );
}
