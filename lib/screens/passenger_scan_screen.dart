import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/asset.dart';
import '../services/metro_database.dart';
import 'passenger_report_screen.dart';

class PassengerScanScreen extends StatefulWidget {
  final Function(MetroAsset asset)? onAssetSelected;

  const PassengerScanScreen({super.key, this.onAssetSelected});

  @override
  State<PassengerScanScreen> createState() => _PassengerScanScreenState();
}

class _PassengerScanScreenState extends State<PassengerScanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  late Animation<double> _laserAnimation;
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _isScanned = false;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      final code = barcodes.first.rawValue!;
      final asset = MetroDatabase.instance.getAsset(code);
      if (asset != null) {
        setState(() => _isScanned = true);
        _openAssetReport(asset);
        // Reset after returning
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _isScanned = false);
        });
      }
    }
  }

  @override
  void dispose() {
    _laserController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _openAssetReport(MetroAsset asset) {
    if (widget.onAssetSelected != null) {
      widget.onAssetSelected!(asset);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PassengerReportScreen(asset: asset),
        ),
      );
    }
  }

  void _simulateScanModal() {
    showModalBottomSheet(
      context: context,
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
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner, color: Color(0xFF38BDF8), size: 28),
                  SizedBox(width: 10),
                  Text(
                    'QR Code Detected!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Simulating scan on closest metro station equipment:',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Text('🛗', style: TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lift L-05',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Thaltej • Platform 1',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward),
                label: const Text(
                  'Continue to Report Problem',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  final asset = MetroDatabase.instance.getAsset('L-05');
                  if (asset != null) {
                    _openAssetReport(asset);
                  }
                },
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
    final assets = MetroDatabase.instance.assets;
    final gate = assets.firstWhere((a) => a.id == 'A-102', orElse: () => assets.first);
    final lift = assets.firstWhere((a) => a.id == 'L-05', orElse: () => assets.first);
    final escalator = assets.firstWhere((a) => a.id == 'E-12', orElse: () => assets.first);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Brand
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('🚇', style: TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'METROFIX',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                      Text(
                        'PASSENGER PORTAL',
                        style: TextStyle(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.9),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Viewfinder Scanner Box
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 340),
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF334155),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Real Camera Feed
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: MobileScanner(
                        controller: _scannerController,
                        onDetect: _onDetect,
                        errorBuilder: (context, error, child) {
                          return const Center(
                            child: Icon(Icons.qr_code_scanner, color: Colors.white24, size: 80),
                          );
                        },
                      ),
                    ),

                    // Corner targeting brackets
                    Positioned(
                      top: 16,
                      left: 16,
                      child: _cornerBracket(isTop: true, isLeft: true),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: _cornerBracket(isTop: true, isLeft: false),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: _cornerBracket(isTop: false, isLeft: true),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: _cornerBracket(isTop: false, isLeft: false),
                    ),

                    // Animated laser line
                    AnimatedBuilder(
                      animation: _laserAnimation,
                      builder: (context, child) {
                        return Positioned(
                          top: 250 * _laserAnimation.value,
                          left: 28,
                          right: 28,
                          child: Container(
                            height: 2.5,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Color(0xFF38BDF8),
                                  Colors.cyanAccent,
                                  Color(0xFF38BDF8),
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.8),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Center Scan QR action button
                    Positioned(
                      bottom: 28,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _simulateScanModal,
                        icon: const Icon(Icons.camera_alt, size: 20),
                        label: const Text(
                          '📷 SCAN QR',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              const Text(
                'Report a problem with any metro equipment.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 22),

              // Demo QR Buttons Section
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR TEST WITH DEMO QR CODES',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3 Demo QR buttons exactly as specified in prompt:
              // [ 🚪 Gate A-102 ]
              // [ 🛗 Lift L-05 ]
              // [ ⚡ Escalator E-12 ]
              _demoQrButton(
                asset: gate,
                label: '🚪 Gate A-102',
                sublabel: '${gate.station} • ${gate.location}',
                badge: 'Entry AFC',
                color: const Color(0xFF0284C7),
              ),
              const SizedBox(height: 12),
              _demoQrButton(
                asset: lift,
                label: '🛗 Lift L-05',
                sublabel: '${lift.station} • ${lift.location}',
                badge: 'Elevator',
                color: const Color(0xFFE11D48),
                highlightBadge: 'HIGH TRAFFIC',
              ),
              const SizedBox(height: 12),
              _demoQrButton(
                asset: escalator,
                label: '⚡ Escalator E-12',
                sublabel: '${escalator.station} • ${escalator.location}',
                badge: 'Concourse',
                color: const Color(0xFFF59E0B),
              ),
              const SizedBox(height: 20),

              // Info card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF38BDF8), size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Every metro asset carries a unique QR code. Tapping any asset mimics instant camera scanning.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cornerBracket({required bool isTop, required bool isLeft}) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(color: Color(0xFF38BDF8), width: 3)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: Color(0xFF38BDF8), width: 3)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(color: Color(0xFF38BDF8), width: 3)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: Color(0xFF38BDF8), width: 3)
              : BorderSide.none,
        ),
      ),
    );
  }

  Widget _demoQrButton({
    required MetroAsset asset,
    required String label,
    required String sublabel,
    required String badge,
    required Color color,
    String? highlightBadge,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openAssetReport(asset),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF334155),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                alignment: Alignment.center,
                child: Text(
                  asset.icon,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (highlightBadge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFEF4444),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              highlightBadge,
                              style: const TextStyle(
                                color: Color(0xFFFCA5A5),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      sublabel,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF64748B),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
