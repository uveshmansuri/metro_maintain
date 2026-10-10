import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'passenger_scan_screen.dart';
import 'login_screen.dart';

/// Initial landing screen — user picks their role.
/// Passengers go directly to QR scan. Others go to login.
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Brand Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🚇', style: TextStyle(fontSize: 40)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'METROFIX',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'QR-Based Metro Asset Maintenance',
                  style: TextStyle(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 48),

                // Section label
                const Text(
                  'SELECT YOUR ROLE',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 20),

                // Passenger — direct access (no login)
                _RoleCard(
                  icon: Icons.qr_code_scanner,
                  emoji: '👤',
                  title: 'Passenger',
                  subtitle: 'Scan QR & report issues instantly',
                  badge: 'NO LOGIN REQUIRED',
                  badgeColor: const Color(0xFF10B981),
                  accentColor: const Color(0xFF38BDF8),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PassengerScanScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Control Room — login required
                _RoleCard(
                  icon: Icons.dashboard_rounded,
                  emoji: '🚨',
                  title: 'Control Room',
                  subtitle: 'Monitor live complaints & dispatch',
                  badge: 'LOGIN REQUIRED',
                  badgeColor: const Color(0xFFF59E0B),
                  accentColor: const Color(0xFFF59E0B),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const LoginScreen(role: UserRole.controlRoom),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Technician — login required
                _RoleCard(
                  icon: Icons.build_rounded,
                  emoji: '🔧',
                  title: 'Technician',
                  subtitle: 'View asset history & resolve issues',
                  badge: 'LOGIN REQUIRED',
                  badgeColor: const Color(0xFFF59E0B),
                  accentColor: const Color(0xFF8B5CF6),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const LoginScreen(role: UserRole.technician),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 36),

                // Footer info
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Color(0xFF38BDF8), size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Passengers can scan QR codes on any metro equipment without registration. Staff must login.',
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
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String emoji;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final Color accentColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: badgeColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: accentColor.withValues(alpha: 0.5),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
