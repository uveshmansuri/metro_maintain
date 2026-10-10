import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'control_dashboard_screen.dart';
import 'technician_history_screen.dart';

class LoginScreen extends StatefulWidget {
  final UserRole role;

  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final error = await AuthService.instance.login(
      _emailController.text,
      _passwordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (error != null) {
        setState(() => _errorMsg = error);
      } else {
        // Navigate based on role
        if (widget.role == UserRole.controlRoom) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const ControlDashboardScreen()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const TechnicianHistoryScreen()),
            (route) => false,
          );
        }
      }
    }
  }

  void _fillDemoCredentials(String email, String password) {
    _emailController.text = email;
    _passwordController.text = password;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.role == UserRole.controlRoom
        ? 'Control Room Login'
        : 'Technician Login';
    final accentColor = widget.role == UserRole.controlRoom
        ? const Color(0xFFF59E0B)
        : const Color(0xFF8B5CF6);

    final demoCreds = AuthService.getDemoCredentials(widget.role);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                widget.role == UserRole.controlRoom
                    ? Icons.dashboard_rounded
                    : Icons.build_rounded,
                size: 64,
                color: accentColor,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please enter your credentials to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),

              // Form
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.email, color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accentColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.lock, color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accentColor),
                  ),
                ),
              ),

              if (_errorMsg != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMsg!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'LOGIN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
              ),

              const SizedBox(height: 48),

              // Demo users helper
              const Divider(color: Colors.white24),
              const SizedBox(height: 16),
              const Text(
                'Demo Accounts',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ...demoCreds.map((cred) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ActionChip(
                  label: Text('${cred['email']}'),
                  backgroundColor: const Color(0xFF1E293B),
                  labelStyle: const TextStyle(color: Colors.white),
                  onPressed: () => _fillDemoCredentials(cred['email']!, cred['password']!),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
