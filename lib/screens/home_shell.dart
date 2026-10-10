import 'package:flutter/material.dart';
import '../models/asset.dart';
import '../services/metro_database.dart';
import 'passenger_scan_screen.dart';
import 'passenger_report_screen.dart';
import 'control_dashboard_screen.dart';
import 'technician_history_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  // Current active mode:
  // 0: Passenger Mode
  // 1: Control Room
  // 2: Technician Mode
  int _currentModeIndex = 0;

  // Active asset for Passenger Report Screen (if scanned)
  MetroAsset? _selectedPassengerAsset;

  // Active asset for Technician Screen
  String _selectedTechnicianAssetId = 'L-05';

  void _onPassengerAssetSelected(MetroAsset asset) {
    setState(() {
      _selectedPassengerAsset = asset;
    });
  }

  void _onNavigateToTechnician(String assetId) {
    setState(() {
      _selectedTechnicianAssetId = assetId;
      _currentModeIndex = 2; // Switch to Technician Mode
    });
  }

  @override
  Widget build(BuildContext context) {
    final db = MetroDatabase.instance;

    return ListenableBuilder(
      listenable: db,
      builder: (context, _) {
        final highCount = db.highPriorityCount;

        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          // Top Mode Switcher Bar - Essential for Demo & Hackathon Judges
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Container(
              color: const Color(0xFF0B132B),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: SafeArea(
                child: Row(
                  children: [
                    _modeTabButton(
                      index: 0,
                      label: 'Passenger',
                      icon: '👤',
                    ),
                    const SizedBox(width: 6),
                    _modeTabButton(
                      index: 1,
                      label: 'Control Room',
                      icon: '🚨',
                      badge: highCount > 0 ? '$highCount' : null,
                    ),
                    const SizedBox(width: 6),
                    _modeTabButton(
                      index: 2,
                      label: 'Technician',
                      icon: '🔧',
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: IndexedStack(
            index: _currentModeIndex,
            children: [
              // Mode 0: Passenger Experience
              // Either Scan Screen (Screen 1) or Report Screen (Screen 2)
              _selectedPassengerAsset == null
                  ? PassengerScanScreen(
                      onAssetSelected: _onPassengerAssetSelected,
                    )
                  : PassengerReportScreen(
                      asset: _selectedPassengerAsset!,
                      onComplaintSubmitted: () {
                        setState(() {
                          _selectedPassengerAsset = null;
                          _currentModeIndex = 1; // Auto-navigate to Control Room for demo effect!
                        });
                      },
                    ),

              // Mode 1: Control Room Dashboard (Screen 3)
              ControlDashboardScreen(
                onNavigateToTechnician: _onNavigateToTechnician,
              ),

              // Mode 2: Technician Asset History (Screen 4)
              TechnicianHistoryScreen(
                initialAssetId: _selectedTechnicianAssetId,
              ),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              border: Border(
                top: BorderSide(color: Color(0xFF334155), width: 1),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentModeIndex,
              onTap: (index) {
                setState(() {
                  _currentModeIndex = index;
                  if (index == 0) {
                    // Reset to scan screen when tapping Passenger
                    _selectedPassengerAsset = null;
                  }
                });
              },
              backgroundColor: const Color(0xFF1E293B),
              selectedItemColor: const Color(0xFF38BDF8),
              unselectedItemColor: const Color(0xFF94A3B8),
              selectedFontSize: 12,
              unselectedFontSize: 12,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code_scanner),
                  label: 'Passenger Scan',
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.dashboard_rounded),
                      if (highCount > 0)
                        Positioned(
                          top: -3,
                          right: -6,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$highCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: 'Control Room',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.build_rounded),
                  label: 'Technician View',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _modeTabButton({
    required int index,
    required String label,
    required String icon,
    String? badge,
  }) {
    final isSelected = _currentModeIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _currentModeIndex = index;
              if (index == 0) {
                _selectedPassengerAsset = null;
              }
            });
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF0284C7)
                  : const Color(0xFF1E293B).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF38BDF8)
                    : const Color(0xFF334155),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(icon, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
