import 'package:flutter/foundation.dart';
import '../models/asset.dart';
import '../models/complaint.dart';
import '../models/maintenance_record.dart';

class MetroDatabase extends ChangeNotifier {
  // Singleton pattern for instant app-wide access
  static final MetroDatabase instance = MetroDatabase._internal();
  MetroDatabase._internal() {
    _seedInitialData();
  }

  final Map<String, MetroAsset> _assets = {};
  final List<Complaint> _complaints = [];
  final Map<String, List<MaintenanceRecord>> _maintenance = {};

  List<MetroAsset> get assets => _assets.values.toList();
  List<Complaint> get complaints => List.unmodifiable(_complaints);

  int get highPriorityCount =>
      _complaints.where((c) => c.status == 'OPEN' && c.priority == 'HIGH').length;

  int get mediumPriorityCount =>
      _complaints.where((c) => c.status == 'OPEN' && c.priority == 'MEDIUM').length;

  int get lowPriorityCount =>
      _complaints.where((c) => c.status == 'OPEN' && c.priority == 'LOW').length;

  MetroAsset? getAsset(String id) => _assets[id];

  List<Complaint> getOpenComplaintsForAsset(String assetId) {
    return _complaints
        .where((c) => c.assetId == assetId && c.status == 'OPEN')
        .toList();
  }

  List<MaintenanceRecord> getMaintenanceRecordsForAsset(String assetId) {
    return _maintenance[assetId] ?? [];
  }

  /// Rule-based Smart Priority Engine
  /// Safety keywords → HIGH
  /// Operational failure → MEDIUM/HIGH
  /// Minor issue → LOW
  static String calculatePriority(String problem, String description) {
    final text = '$problem $description'.toLowerCase();

    // 1. Critical safety keywords
    final safetyWords = [
      'fire',
      'smoke',
      'shock',
      'danger',
      'spark',
      'fall',
      'blood',
      'injury',
      'emergency',
      'trapped',
      'hazard',
      'electric'
    ];
    for (final word in safetyWords) {
      if (text.contains(word)) return 'HIGH';
    }

    // 2. Operational stoppage/failure keywords
    final operationalWords = [
      'not working',
      'stuck',
      'broken',
      'stopped',
      'jammed',
      'halted',
      'power off',
      'dead',
      'unresponsive'
    ];
    for (final word in operationalWords) {
      if (text.contains(word)) return 'HIGH';
    }

    // 3. Medium severity keywords
    final mediumWords = [
      'noise',
      'grinding',
      'door problem',
      'door',
      'slow',
      'shaking',
      'vibration',
      'screen'
    ];
    for (final word in mediumWords) {
      if (text.contains(word)) return 'MEDIUM';
    }

    return 'LOW';
  }

  /// Submit a new passenger complaint with automated repeated issue detection
  Future<Complaint> submitComplaint({
    required String assetId,
    required String problem,
    required String description,
    bool hasPhoto = false,
  }) async {
    final asset = _assets[assetId];
    if (asset == null) {
      throw Exception('Asset $assetId not found');
    }

    // Determine base priority via Smart Engine
    String priority = calculatePriority(problem, description);

    // Repeated complaint detection (incident cluster):
    // If recent open complaints exist for the same asset within 2 hours
    final existingOpenForAsset = _complaints.where((c) {
      if (c.assetId != assetId || c.status != 'OPEN') return false;
      final diff = DateTime.now().difference(c.timestamp);
      return diff.inHours < 2;
    }).toList();

    final clusterCount = existingOpenForAsset.length + 1;
    final isRepeated = clusterCount >= 2;

    // "Repeated complaints = automatic escalation to HIGH"
    if (isRepeated) {
      priority = 'HIGH';
      // Escalate existing open complaints for this asset to HIGH as well
      for (int i = 0; i < _complaints.length; i++) {
        if (_complaints[i].assetId == assetId &&
            _complaints[i].status == 'OPEN') {
          _complaints[i] = _complaints[i].copyWith(
            priority: 'HIGH',
            isRepeatedIssue: true,
            clusterCount: clusterCount,
          );
        }
      }
    }

    final newId = 'C-${100 + _complaints.length + 1}';
    final complaint = Complaint(
      id: newId,
      assetId: asset.id,
      station: asset.station,
      location: asset.location,
      category: asset.type,
      problem: problem,
      description: description,
      priority: priority,
      status: 'OPEN',
      timestamp: DateTime.now(),
      hasPhoto: hasPhoto,
      isRepeatedIssue: isRepeated,
      clusterCount: clusterCount,
    );

    // Prepend so newest is at the top
    _complaints.insert(0, complaint);
    notifyListeners();
    return complaint;
  }

  /// Mark all open complaints for an asset as resolved
  Future<void> resolveAllComplaintsForAsset(String assetId) async {
    final now = DateTime.now();
    bool updated = false;

    for (int i = 0; i < _complaints.length; i++) {
      if (_complaints[i].assetId == assetId &&
          _complaints[i].status == 'OPEN') {
        _complaints[i] = _complaints[i].copyWith(
          status: 'RESOLVED',
          resolvedBy: 'Technician',
          resolvedAt: now,
        );
        updated = true;
      }
    }

    if (updated) {
      // Append a maintenance entry
      final records = _maintenance[assetId] ?? [];
      records.insert(
        0,
        MaintenanceRecord(
          id: 'M-${DateTime.now().millisecondsSinceEpoch}',
          assetId: assetId,
          dateText: 'Today (${_formatTime(now)})',
          type: '🔧 Resolved by Staff',
          description: 'Inspected and verified all reported issues resolved',
          technician: 'Senior Technician #42',
          timestamp: now,
        ),
      );
      _maintenance[assetId] = records;
      notifyListeners();
    }
  }

  /// Mark a specific complaint as resolved
  Future<void> resolveComplaint(String complaintId) async {
    final index = _complaints.indexWhere((c) => c.id == complaintId);
    if (index != -1) {
      final now = DateTime.now();
      final current = _complaints[index];
      _complaints[index] = current.copyWith(
        status: 'RESOLVED',
        resolvedBy: 'Technician',
        resolvedAt: now,
      );

      // Check if any open complaints remain for this asset
      final remainingOpen = getOpenComplaintsForAsset(current.assetId);
      if (remainingOpen.isEmpty) {
        final records = _maintenance[current.assetId] ?? [];
        records.insert(
          0,
          MaintenanceRecord(
            id: 'M-${DateTime.now().millisecondsSinceEpoch}',
            assetId: current.assetId,
            dateText: 'Today (${_formatTime(now)})',
            type: '🔧 Issue Resolved',
            description: 'Fixed: ${current.problem} - ${current.description}',
            technician: 'Technician #14',
            timestamp: now,
          ),
        );
        _maintenance[current.assetId] = records;
      }

      notifyListeners();
    }
  }

  void resetDemoData() {
    _complaints.clear();
    _maintenance.clear();
    _assets.clear();
    _seedInitialData();
    notifyListeners();
  }

  void _seedInitialData() {
    // 1. Pre-seeded Assets (Ahmedabad Metro sample stations)
    _assets['L-05'] = const MetroAsset(
      id: 'L-05',
      name: 'Lift L-05',
      type: 'Lift',
      station: 'Thaltej',
      location: 'Platform 1',
      icon: '🛗',
    );

    _assets['E-12'] = const MetroAsset(
      id: 'E-12',
      name: 'Escalator E-12',
      type: 'Escalator',
      station: 'Vastrapur',
      location: 'Exit 2',
      icon: '⚡',
    );

    _assets['A-102'] = const MetroAsset(
      id: 'A-102',
      name: 'Gate A-102',
      type: 'Gate',
      station: 'Old High Court',
      location: 'Concourse North',
      icon: '🚪',
    );

    _assets['TVM-03'] = const MetroAsset(
      id: 'TVM-03',
      name: 'Ticket TVM-03',
      type: 'Gate',
      station: 'Kalupur',
      location: 'Gate 3',
      icon: '🎫',
    );

    // 2. Pre-seeded Complaints matching prompt exactly:
    // L-05: High priority, 2 reports today
    final now = DateTime.now();

    _complaints.addAll([
      Complaint(
        id: 'C-001',
        assetId: 'L-05',
        station: 'Thaltej',
        location: 'Platform 1',
        category: 'Lift',
        problem: 'Not working',
        description: 'Lift stopped on platform 1 with doors stuck',
        priority: 'HIGH',
        status: 'OPEN',
        timestamp: now.subtract(const Duration(minutes: 12)),
        hasPhoto: true,
        isRepeatedIssue: true,
        clusterCount: 2,
      ),
      Complaint(
        id: 'C-002',
        assetId: 'L-05',
        station: 'Thaltej',
        location: 'Platform 1',
        category: 'Lift',
        problem: 'Door problem',
        description: 'Buttons blinking red, lift not arriving',
        priority: 'HIGH',
        status: 'OPEN',
        timestamp: now.subtract(const Duration(minutes: 6)),
        hasPhoto: false,
        isRepeatedIssue: true,
        clusterCount: 2,
      ),
      Complaint(
        id: 'C-003',
        assetId: 'E-12',
        station: 'Vastrapur',
        location: 'Exit 2',
        category: 'Escalator',
        problem: 'Making noise',
        description: 'Making unusual grinding noise near top steps',
        priority: 'MEDIUM',
        status: 'OPEN',
        timestamp: now.subtract(const Duration(minutes: 45)),
        hasPhoto: false,
        isRepeatedIssue: false,
        clusterCount: 1,
      ),
      Complaint(
        id: 'C-004',
        assetId: 'A-102',
        station: 'Old High Court',
        location: 'Concourse North',
        category: 'Gate',
        problem: 'Door problem',
        description: 'Flap barrier stays open after passenger passes',
        priority: 'LOW',
        status: 'OPEN',
        timestamp: now.subtract(const Duration(hours: 3)),
        hasPhoto: false,
        isRepeatedIssue: false,
        clusterCount: 1,
      ),
      Complaint(
        id: 'C-005',
        assetId: 'E-12',
        station: 'Vastrapur',
        location: 'Exit 2',
        category: 'Escalator',
        problem: 'Handrail loose',
        description: 'Left handrail moving slower than steps',
        priority: 'MEDIUM',
        status: 'RESOLVED',
        timestamp: now.subtract(const Duration(days: 2)),
        hasPhoto: false,
        resolvedBy: 'Technician',
        resolvedAt: now.subtract(const Duration(days: 1)),
      ),
    ]);

    // 3. Maintenance Records matching prompt for Technician screen:
    // "10 Oct 🔧 Door sensor"
    // "28 Sep ✓ Routine check"
    // "15 Sep 🔧 Motor issue"
    _maintenance['L-05'] = [
      MaintenanceRecord(
        id: 'M-001',
        assetId: 'L-05',
        dateText: '10 Oct',
        type: '🔧 Door sensor',
        description: 'Replaced infrared curtain door sensor on Platform 1',
        technician: 'Vikas Sharma',
        timestamp: DateTime(2024, 10, 10, 14, 30),
      ),
      MaintenanceRecord(
        id: 'M-002',
        assetId: 'L-05',
        dateText: '28 Sep',
        type: '✓ Routine check',
        description: 'Quarterly hydraulic pressure & cable tension inspection passed',
        technician: 'Amit Patel',
        timestamp: DateTime(2024, 9, 28, 10, 15),
      ),
      MaintenanceRecord(
        id: 'M-003',
        assetId: 'L-05',
        dateText: '15 Sep',
        type: '🔧 Motor issue',
        description: 'Tension drive motor bearing lubricated and realigned',
        technician: 'Ramesh Dave',
        timestamp: DateTime(2024, 9, 15, 17, 0),
      ),
    ];

    _maintenance['E-12'] = [
      MaintenanceRecord(
        id: 'M-004',
        assetId: 'E-12',
        dateText: '05 Oct',
        type: '🔧 Comb plate check',
        description: 'Upper landing comb plate teeth realigned and tightened',
        technician: 'Kishore Trivedi',
        timestamp: DateTime(2024, 10, 5, 11, 0),
      ),
      MaintenanceRecord(
        id: 'M-005',
        assetId: 'E-12',
        dateText: '20 Sep',
        type: '✓ Routine check',
        description: 'Emergency stop brake pad clearance certified',
        technician: 'Amit Patel',
        timestamp: DateTime(2024, 9, 20, 9, 30),
      ),
    ];

    _maintenance['A-102'] = [
      MaintenanceRecord(
        id: 'M-006',
        assetId: 'A-102',
        dateText: '12 Oct',
        type: '🔧 Optical sensor',
        description: 'Cleaned dust and calibrated passage sensors',
        technician: 'Pratik Solanki',
        timestamp: DateTime(2024, 10, 12, 16, 20),
      ),
      MaintenanceRecord(
        id: 'M-007',
        assetId: 'A-102',
        dateText: '01 Oct',
        type: '✓ Firmware update',
        description: 'AFC gate software upgraded to v2.4.1',
        technician: 'Pratik Solanki',
        timestamp: DateTime(2024, 10, 1, 8, 45),
      ),
    ];
  }

  static String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min';
  }
}
