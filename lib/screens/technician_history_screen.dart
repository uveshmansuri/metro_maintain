import 'package:flutter/material.dart';
import '../models/asset.dart';
import '../services/metro_database.dart';

class TechnicianHistoryScreen extends StatefulWidget {
  final String initialAssetId;

  const TechnicianHistoryScreen({
    super.key,
    this.initialAssetId = 'L-05',
  });

  @override
  State<TechnicianHistoryScreen> createState() =>
      _TechnicianHistoryScreenState();
}

class _TechnicianHistoryScreenState extends State<TechnicianHistoryScreen> {
  late String _currentAssetId;
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    _currentAssetId = widget.initialAssetId;
  }

  Future<void> _markAsResolved() async {
    setState(() => _isResolving = true);

    await MetroDatabase.instance.resolveAllComplaintsForAsset(_currentAssetId);

    if (!mounted) return;
    setState(() => _isResolving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'All open complaints for $_currentAssetId marked as RESOLVED by Technician.',
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showAssetPickerModal(List<MetroAsset> assets) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.qr_code_scanner, color: Color(0xFF38BDF8)),
                  SizedBox(width: 10),
                  Text(
                    'Scan / Select Metro Asset',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...assets.map((asset) {
                final isSelected = asset.id == _currentAssetId;
                final openCount = MetroDatabase.instance
                    .getOpenComplaintsForAsset(asset.id)
                    .length;
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: isSelected
                      ? const Color(0xFF0284C7).withValues(alpha: 0.25)
                      : Colors.transparent,
                  leading: Text(asset.icon, style: const TextStyle(fontSize: 24)),
                  title: Text(
                    asset.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    '${asset.station} • ${asset.location}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  trailing: openCount > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$openCount open',
                            style: const TextStyle(
                              color: Color(0xFFF87171),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : const Text(
                          '✓ Clear',
                          style: TextStyle(color: Color(0xFF10B981), fontSize: 12),
                        ),
                  onTap: () {
                    setState(() => _currentAssetId = asset.id);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = MetroDatabase.instance;

    return ListenableBuilder(
      listenable: db,
      builder: (context, _) {
        final assets = db.assets;
        final asset = db.getAsset(_currentAssetId) ??
            (assets.isNotEmpty ? assets.first : null);

        if (asset == null) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F172A),
            body: Center(child: Text('Asset not found')),
          );
        }

        final openComplaints = db.getOpenComplaintsForAsset(asset.id);
        final maintenanceRecords = db.getMaintenanceRecordsForAsset(asset.id);
        final hasOpenIssues = openComplaints.isNotEmpty;

        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E293B),
            elevation: 0,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TECHNICIAN CONSOLE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Asset History & Field Resolution',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF38BDF8),
                ),
                icon: const Icon(Icons.qr_code, size: 18),
                label: const Text('Change Asset'),
                onPressed: () => _showAssetPickerModal(assets),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ASSET DETAILS Box (matching prompt mockup)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF334155)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'ASSET DETAILS',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'QR: METRO-${asset.id}',
                                style: const TextStyle(
                                  color: Color(0xFF38BDF8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Color(0xFF334155), height: 20),
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFF334155)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                asset.icon,
                                style: const TextStyle(fontSize: 30),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${asset.icon} ${asset.name.toUpperCase()}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${asset.station} • ${asset.location}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // STATUS Section
                        const Text(
                          'STATUS',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: hasOpenIssues
                                ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                                : const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: hasOpenIssues
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF10B981),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                hasOpenIssues ? '🔴' : '🟢',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                hasOpenIssues
                                    ? 'NEEDS ATTENTION'
                                    : 'OPERATIONAL / ALL CLEAR',
                                style: TextStyle(
                                  color: hasOpenIssues
                                      ? const Color(0xFFFCA5A5)
                                      : const Color(0xFF6EE7B7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // OPEN COMPLAINTS Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'OPEN COMPLAINTS: ${openComplaints.length}',
                        style: TextStyle(
                          color: hasOpenIssues
                              ? const Color(0xFFF87171)
                              : const Color(0xFF6EE7B7),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      if (hasOpenIssues)
                        const Text(
                          'Requires Inspection',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (openComplaints.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Color(0xFF10B981), size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No pending reports. All equipment operating within normal limits.',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: openComplaints.map((c) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: c.priority == 'HIGH'
                                  ? const Color(0xFFEF4444).withValues(alpha: 0.6)
                                  : const Color(0xFF334155),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    c.priority == 'HIGH' ? '🔴' : '🟠',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      c.problem,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444)
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      c.priority,
                                      style: const TextStyle(
                                        color: Color(0xFFFCA5A5),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                c.description,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              if (c.isRepeatedIssue) ...[
                                const SizedBox(height: 6),
                                Text(
                                  '⚠️ ${c.clusterCount} incident reports clustered in 20 min',
                                  style: const TextStyle(
                                    color: Color(0xFFF87171),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 18),

                  // [ MARK AS RESOLVED ] Button (enabled when openComplaints > 0)
                  if (hasOpenIssues)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isResolving ? null : _markAsResolved,
                      icon: _isResolving
                          ? const SizedBox.shrink()
                          : const Icon(Icons.task_alt, size: 22),
                      label: _isResolving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'MARK AS RESOLVED',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                    ),

                  const SizedBox(height: 28),

                  // MAINTENANCE HISTORY Section matching prompt exactly:
                  // 10 Oct 🔧 Door sensor
                  // 28 Sep ✓ Routine check
                  // 15 Sep 🔧 Motor issue
                  const Text(
                    'MAINTENANCE HISTORY',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      children: maintenanceRecords.isEmpty
                          ? [
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'No prior records logged.',
                                  style: TextStyle(color: Colors.white54),
                                ),
                              )
                            ]
                          : maintenanceRecords.map((record) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 60,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Text(
                                        record.dateText,
                                        style: const TextStyle(
                                          color: Color(0xFF38BDF8),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            record.type,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            record.description,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'By: ${record.technician}',
                                            style: const TextStyle(
                                              color: Color(0xFF64748B),
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
