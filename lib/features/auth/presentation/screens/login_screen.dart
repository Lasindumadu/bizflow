import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';

/// A modern, tactile, glassmorphic Cashier PIN & Operator authentication screen.
class LoginScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const LoginScreen({
    super.key,
    required this.onAuthenticated,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  bool _isError = false;
  bool _isSuccess = false;
  bool _showPasswordMode = false;
  final TextEditingController _usernameController =
      TextEditingController(text: 'admin');
  final TextEditingController _passwordController = TextEditingController();

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  final List<Map<String, String>> _operators = [
    {'name': 'Alex Rivera', 'role': 'Store Manager', 'avatar': 'AR'},
    {'name': 'Sarah Chen', 'role': 'Head Cashier', 'avatar': 'SC'},
    {'name': 'David Kim', 'role': 'Sales Associate', 'avatar': 'DK'},
  ];

  late int _selectedOperatorIndex = 0;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onNumberTap(String number) {
    if (_pin.length >= 4) return;
    setState(() {
      _isError = false;
      _pin += number;
    });

    if (_pin.length == 4) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() {
      _isError = false;
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  void _verifyPin() {
    // Default demo passcode or manager bypass
    if (_pin == '1234' || _pin == '0000' || _pin == '9999' || _pin.length == 4) {
      setState(() {
        _isSuccess = true;
      });
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) {
          widget.onAuthenticated();
        }
      });
    } else {
      setState(() {
        _isError = true;
        _pin = '';
      });
      _shakeController.forward(from: 0);
    }
  }

  void _submitCredentials() {
    setState(() {
      _isSuccess = true;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        widget.onAuthenticated();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Ambient Glow orbs in the background
          Positioned(
            top: -120,
            left: -100,
            child: _buildAuraOrb(
              color: AppColors.primaryLight.withValues(alpha: 0.35),
              radius: 360,
            ),
          ),
          Positioned(
            bottom: -150,
            right: -100,
            child: _buildAuraOrb(
              color: AppColors.accent.withValues(alpha: 0.3),
              radius: 400,
            ),
          ),
          Positioned(
            top: size.height * 0.4,
            right: -50,
            child: _buildAuraOrb(
              color: AppColors.cyan.withValues(alpha: 0.2),
              radius: 260,
            ),
          ),

          // Main Interactive Glass Container
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  final offset = math.sin(_shakeAnimation.value * math.pi * 4) * 8;
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  );
                },
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 440),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.08),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildBrandHeader(),
                      const SizedBox(height: 24),
                      _buildOperatorSelector(),
                      const SizedBox(height: 28),
                      if (!_showPasswordMode) ...[
                        _buildPinVisualizer(),
                        const SizedBox(height: 32),
                        _buildNumberKeypad(),
                      ] else ...[
                        _buildCredentialForm(),
                      ],
                      const SizedBox(height: 24),
                      _buildFooterToggle(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuraOrb({required Color color, required double radius}) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            gradient: AppDecor.indigoGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.bolt_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'BizFlow Terminal',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Enter operator PIN or switch cashier',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }

  Widget _buildOperatorSelector() {
    final operator = _operators[_selectedOperatorIndex];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                operator['avatar']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  operator['name']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  operator['role']!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<int>(
            tooltip: 'Switch Cashier',
            icon: Icon(
              Icons.unfold_more_rounded,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            color: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
            ),
            onSelected: (idx) {
              setState(() {
                _selectedOperatorIndex = idx;
                _pin = '';
                _isError = false;
              });
            },
            itemBuilder: (context) {
              return List.generate(_operators.length, (i) {
                final op = _operators[i];
                return PopupMenuItem<int>(
                  value: i,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          op['avatar']!,
                          style: const TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        op['name']!,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPinVisualizer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isFilled = index < _pin.length;
        Color dotColor = Colors.white.withValues(alpha: 0.2);
        if (_isError) {
          dotColor = AppColors.error;
        } else if (_isSuccess) {
          dotColor = AppColors.success;
        } else if (isFilled) {
          dotColor = AppColors.primaryLight;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: isFilled ? 18 : 14,
          height: isFilled ? 18 : 14,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            boxShadow: isFilled
                ? [
                    BoxShadow(
                      color: dotColor.withValues(alpha: 0.6),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
        );
      }),
    );
  }

  Widget _buildNumberKeypad() {
    return Column(
      children: [
        _buildKeyRow(['1', '2', '3']),
        const SizedBox(height: 14),
        _buildKeyRow(['4', '5', '6']),
        const SizedBox(height: 14),
        _buildKeyRow(['7', '8', '9']),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSpecialKey(
              icon: Icons.fingerprint_rounded,
              onTap: () {
                // Biometrics / Bypass shortcut
                _verifyPin();
              },
            ),
            const SizedBox(width: 16),
            _buildKeyButton('0'),
            const SizedBox(width: 16),
            _buildSpecialKey(
              icon: Icons.backspace_outlined,
              onTap: _onBackspace,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((key) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _buildKeyButton(key),
        );
      }).toList(),
    );
  }

  Widget _buildKeyButton(String label) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onNumberTap(label),
        borderRadius: BorderRadius.circular(22),
        splashColor: AppColors.primaryLight.withValues(alpha: 0.3),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Center(
            child: Icon(icon, color: Colors.white70, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialForm() {
    return Column(
      children: [
        TextField(
          controller: _usernameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Username or Email',
            labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            prefixIcon: const Icon(Icons.person_outline_rounded, color: Colors.white70),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
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
            labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.white70),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            onPressed: _submitCredentials,
            child: const Text(
              'Sign In to Terminal',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterToggle() {
    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white70,
      ),
      onPressed: () {
        setState(() {
          _showPasswordMode = !_showPasswordMode;
          _pin = '';
          _isError = false;
        });
      },
      icon: Icon(
        _showPasswordMode ? Icons.pin_rounded : Icons.password_rounded,
        size: 18,
      ),
      label: Text(
        _showPasswordMode
            ? 'Switch to Quick PIN Pad'
            : 'Login with Username & Password',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
