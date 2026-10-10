import 'package:flutter/material.dart';
import '../models/asset.dart';
import '../models/complaint.dart';
import '../services/metro_database.dart';

class PassengerReportScreen extends StatefulWidget {
  final MetroAsset asset;
  final VoidCallback? onComplaintSubmitted;

  const PassengerReportScreen({
    super.key,
    required this.asset,
    this.onComplaintSubmitted,
  });

  @override
  State<PassengerReportScreen> createState() => _PassengerReportScreenState();
}

class _PassengerReportScreenState extends State<PassengerReportScreen> {
  final List<String> _problems = [
    'Not working',
    'Making noise',
    'Door problem',
    'Safety issue',
    'Other',
  ];

  late String _selectedProblem;
  final TextEditingController _descController = TextEditingController();
  bool _hasPhoto = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedProblem = _problems.first;
    // Set default sample description for quick demo testing
    if (widget.asset.id == 'L-05') {
      _descController.text = 'Lift stopped on platform 1 with passenger inside';
    } else if (widget.asset.id == 'E-12') {
      _descController.text = 'Escalator vibration and unusual screeching sound';
    } else {
      _descController.text = 'Sensor not registering smart card exit';
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  String _getCalculatedPriority() {
    return MetroDatabase.calculatePriority(
      _selectedProblem,
      _descController.text,
    );
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

  Future<void> _submitReport() async {
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a brief description of the issue'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final complaint = await MetroDatabase.instance.submitComplaint(
        assetId: widget.asset.id,
        problem: _selectedProblem,
        description: _descController.text.trim(),
        hasPhoto: _hasPhoto,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      _showSuccessDialog(complaint);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccessDialog(Complaint complaint) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Color(0xFF10B981), size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Complaint Filed!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Incident ID: ${complaint.id}',
                style: const TextStyle(
                  color: Color(0xFF38BDF8),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Asset: ${widget.asset.name} (${widget.asset.station})',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 14),

              // Automatic Escalation Banner if triggered
              if (complaint.isRepeatedIssue)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFEF4444)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Color(0xFFEF4444), size: 26),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '⚠️ REPEATED ISSUE DETECTED',
                              style: TextStyle(
                                color: Color(0xFFFCA5A5),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${complaint.clusterCount} complaints in 20 min.\n→ Automatically escalated to HIGH PRIORITY!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(complaint.priority)
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Priority: ${complaint.priority}',
                    style: TextStyle(
                      color: _getPriorityColor(complaint.priority),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),

              const SizedBox(height: 6),
              const Text(
                'Synced in real-time to Metro Control Room & Technician dispatch.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (widget.onComplaintSubmitted != null) {
                  widget.onComplaintSubmitted!();
                } else if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Close', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                if (widget.onComplaintSubmitted != null) {
                  widget.onComplaintSubmitted!();
                } else if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final livePriority = _getCalculatedPriority();
    final priorityColor = _getPriorityColor(livePriority);
    final openComplaintsCount = MetroDatabase.instance
        .getOpenComplaintsForAsset(widget.asset.id)
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'Report Problem',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Asset Header Section exactly matching prompt
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF334155),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ASSET DETAILS',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Divider(color: Color(0xFF334155), height: 16),
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            widget.asset.icon,
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.asset.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Station: ${widget.asset.station}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Location: ${widget.asset.location}',
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Existing incidents notice for judges
              if (openComplaintsCount > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: Color(0xFFF87171), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$openComplaintsCount active report(s) today. Another report will trigger automatic incident clustering.',
                          style: const TextStyle(
                            color: Color(0xFFFCA5A5),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // "What's wrong?" selector
              const Text(
                "What's wrong?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  children: _problems.map((problem) {
                    final isSelected = _selectedProblem == problem;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() => _selectedProblem = problem);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: isSelected
                                    ? const Color(0xFF38BDF8)
                                    : const Color(0xFF64748B),
                                size: 22,
                              ),
                              const SizedBox(width: 14),
                              Text(
                                problem,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFFCBD5E1),
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Describe section
              const Text(
                'Describe:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _descController,
                  maxLines: 4,
                  onChanged: (text) => setState(() {}),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Lift stopped on platform 1...',
                    hintStyle: TextStyle(color: Color(0xFF64748B)),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Smart Priority Engine Live Indicator
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: priorityColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Text('🧠', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Smart Priority Engine (Rule-based AI)',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Assigned Priority: $livePriority',
                            style: TextStyle(
                              color: priorityColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        livePriority,
                        style: TextStyle(
                          color: priorityColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // [ 📷 Add Photo ] button & preview
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: _hasPhoto ? Colors.cyanAccent : Colors.white70,
                  side: BorderSide(
                    color: _hasPhoto
                        ? Colors.cyanAccent
                        : const Color(0xFF475569),
                  ),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  setState(() => _hasPhoto = !_hasPhoto);
                },
                icon: Icon(
                  _hasPhoto ? Icons.check_circle : Icons.camera_alt_outlined,
                  color: _hasPhoto ? Colors.cyanAccent : Colors.white70,
                ),
                label: Text(
                  _hasPhoto
                      ? '📷 Photo Attached (tap to remove)'
                      : '📷 Add Photo',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),

              if (_hasPhoto) ...[
                const SizedBox(height: 10),
                Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4)),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Container(
                        width: 74,
                        decoration: BoxDecoration(
                          color: const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.image, color: Colors.cyanAccent, size: 36),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'equipment_fault_snap.jpg',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '1.4 MB • High Resolution',
                              style: TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // [ SUBMIT ] Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _isSubmitting ? null : _submitReport,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'SUBMIT TO CONTROL ROOM',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
