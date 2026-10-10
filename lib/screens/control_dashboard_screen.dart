import 'package:flutter/material.dart';
import '../models/complaint.dart';
import '../services/metro_database.dart';
import 'technician_history_screen.dart';

class ControlDashboardScreen extends StatefulWidget {
  final Function(String assetId)? onNavigateToTechnician;

  const ControlDashboardScreen({super.key, this.onNavigateToTechnician});

  @override
  State<ControlDashboardScreen> createState() => _ControlDashboardScreenState();
}

class _ControlDashboardScreenState extends State<ControlDashboardScreen> {
  String _selectedFilter = 'ALL'; // ALL, HIGH, LIFT, ESCALATOR, GATE

  final List<String> _filters = ['ALL', 'HIGH', 'LIFT', 'ESCALATOR', 'GATE'];

  List<Complaint> _filterComplaints(List<Complaint> all) {
    return all.where((c) {
      if (_selectedFilter == 'ALL') return true;
      if (_selectedFilter == 'HIGH') return c.priority == 'HIGH';
      if (_selectedFilter == 'LIFT') {
        return c.category.toUpperCase().contains('LIFT');
      }
      if (_selectedFilter == 'ESCALATOR') {
        return c.category.toUpperCase().contains('ESCALATOR');
      }
      if (_selectedFilter == 'GATE') {
        return c.category.toUpperCase().contains('GATE');
      }
      return true;
    }).toList();
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'HIGH':
        return const Color(0xFFEF4444);
      case 'MEDIUM':
        return const Color(0xFFF59E0B);
      case 'LOW':
      default:
        return const Color(0xFF10B981);
    }
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _showComplaintDetail(Complaint complaint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E293B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Incident #${complaint.id}',
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(complaint.priority)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getPriorityColor(complaint.priority),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      '${complaint.priority} PRIORITY',
                      style: TextStyle(
                        color: _getPriorityColor(complaint.priority),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                '${complaint.assetId} (${complaint.category})',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Station: ${complaint.station} • ${complaint.location}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 14),

              // Repeated Escalation notification if applicable
              if (complaint.isRepeatedIssue)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEF4444)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Color(0xFFEF4444), size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '⚠️ Automatic Escalation: ${complaint.clusterCount} reports registered today in short window.',
                          style: const TextStyle(
                            color: Color(0xFFFCA5A5),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),
              const Text(
                'Reported Problem:',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                complaint.problem,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Passenger Description:',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  complaint.description,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),

              if (complaint.hasPhoto) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.photo_camera,
                        color: Colors.cyanAccent, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'Photo Evidence Attached',
                      style: TextStyle(color: Colors.cyanAccent, fontSize: 13),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('View Image',
                          style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF38BDF8),
                        side: const BorderSide(color: Color(0xFF38BDF8)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        if (widget.onNavigateToTechnician != null) {
                          widget.onNavigateToTechnician!(complaint.assetId);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TechnicianHistoryScreen(
                                initialAssetId: complaint.assetId,
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.build_circle_outlined),
                      label: const Text('Asset History'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (complaint.status == 'OPEN')
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await MetroDatabase.instance.resolveComplaint(complaint.id);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Incident #${complaint.id} marked as RESOLVED'),
                              backgroundColor: const Color(0xFF10B981),
                            ),
                          );
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Resolve'),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
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
        final highCount = db.highPriorityCount;
        final mediumCount = db.mediumPriorityCount;
        final lowCount = db.lowPriorityCount;
        final filteredList = _filterComplaints(db.complaints);

        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E293B),
            elevation: 0,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'METROFIX CONTROL ROOM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Live Network Monitoring',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            actions: [
              // Live RTDB indicator badge
              Container(
                margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.4),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 4,
                      backgroundColor: Color(0xFF10B981),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'RTDB LIVE',
                      style: TextStyle(
                        color: Color(0xFF6EE7B7),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white70),
                color: const Color(0xFF1E293B),
                onSelected: (value) {
                  if (value == 'reset') {
                    db.resetDemoData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Demo data reloaded to initial state')),
                    );
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'reset',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, color: Colors.white70, size: 20),
                        SizedBox(width: 10),
                        Text('Reset Demo Data', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Top Priority Counters exactly matching prompt:
                // 🔴 HIGH 3
                // 🟠 MEDIUM 5
                // 🟢 LOW 8
                Container(
                  color: const Color(0xFF1E293B),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _priorityStatCard(
                          icon: '🔴',
                          title: 'HIGH',
                          count: highCount,
                          color: const Color(0xFFEF4444),
                          onTap: () {
                            setState(() => _selectedFilter = 'HIGH');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _priorityStatCard(
                          icon: '🟠',
                          title: 'MEDIUM',
                          count: mediumCount,
                          color: const Color(0xFFF59E0B),
                          onTap: () {
                            setState(() => _selectedFilter = 'ALL');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _priorityStatCard(
                          icon: '🟢',
                          title: 'LOW',
                          count: lowCount,
                          color: const Color(0xFF10B981),
                          onTap: () {
                            setState(() => _selectedFilter = 'ALL');
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Filters Row exactly matching prompt:
                // [ALL] [HIGH] [LIFT] [ESCALATOR] [GATE]
                Container(
                  width: double.infinity,
                  color: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              filter,
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                                fontWeight:
                                    isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                            backgroundColor: const Color(0xFF1E293B),
                            selectedColor: const Color(0xFF0284C7),
                            checkmarkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF38BDF8)
                                    : const Color(0xFF334155),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const Divider(color: Color(0xFF334155), height: 1),

                // Complaint List
                Expanded(
                  child: filteredList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  color: Color(0xFF64748B), size: 48),
                              const SizedBox(height: 12),
                              Text(
                                'No complaints for filter "$_selectedFilter"',
                                style: const TextStyle(
                                    color: Color(0xFF94A3B8), fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredList.length,
                          separatorBuilder: (_, _) =>
                              const Divider(color: Color(0xFF334155), height: 20),
                          itemBuilder: (context, index) {
                            final complaint = filteredList[index];
                            return _complaintRowItem(complaint);
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _priorityStatCard({
    required String icon,
    required String title,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(icon, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _complaintRowItem(Complaint complaint) {
    final isOpen = complaint.status == 'OPEN';
    final pColor = _getPriorityColor(complaint.priority);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: complaint.isRepeatedIssue && isOpen
              ? const Color(0xFFEF4444).withValues(alpha: 0.8)
              : const Color(0xFF334155),
          width: complaint.isRepeatedIssue && isOpen ? 1.5 : 1.0,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Priority Dot + Asset Name + Status
          Row(
            children: [
              Text(
                complaint.priority == 'HIGH'
                    ? '🔴'
                    : (complaint.priority == 'MEDIUM' ? '🟠' : '🟢'),
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${complaint.assetId} ${complaint.category}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!isOpen)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'RESOLVED',
                    style: TextStyle(
                      color: Color(0xFF6EE7B7),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Text(
                  _formatTimeAgo(complaint.timestamp),
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                ),
            ],
          ),

          const SizedBox(height: 4),
          // Station • Location
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              '${complaint.station} • ${complaint.location}',
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: 10),
          // Problem in quotes
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              '"${complaint.problem} - ${complaint.description}"',
              style: const TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 12),
          // Footer: reports count badge & [ VIEW ] button
          Row(
            children: [
              const SizedBox(width: 24),
              if (complaint.isRepeatedIssue && isOpen)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt, color: Color(0xFFF87171), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${complaint.clusterCount} reports today (Escalated)',
                        style: const TextStyle(
                          color: Color(0xFFFCA5A5),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  'Priority: ${complaint.priority}',
                  style: TextStyle(
                    color: pColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _showComplaintDetail(complaint),
                child: const Text(
                  'VIEW',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
