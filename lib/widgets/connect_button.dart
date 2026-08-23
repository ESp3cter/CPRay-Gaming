import 'package:flutter/material.dart';
import '../services/vpn_service.dart';

class ConnectButton extends StatefulWidget {
  final VpnStatus status;
  final VoidCallback onTap;

  const ConnectButton({
    super.key,
    required this.status,
    required this.onTap,
  });

  @override
  State<ConnectButton> createState() => _ConnectButtonState();
}

class _ConnectButtonState extends State<ConnectButton> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor;
    Color glowColor;
    String label;
    IconData icon;

    switch (widget.status) {
      case VpnStatus.connected:
        primaryColor = const Color(0xFF00FF88);
        glowColor = const Color(0xFF00FF88).withOpacity(0.45);
        label = 'CONNECTED';
        icon = Icons.power_settings_new_rounded;
        break;
      case VpnStatus.connecting:
      case VpnStatus.disconnecting:
        primaryColor = const Color(0xFFFFB300);
        glowColor = const Color(0xFFFFB300).withOpacity(0.45);
        label = 'CONNECTING...';
        icon = Icons.sync_rounded;
        break;
      case VpnStatus.error:
        primaryColor = const Color(0xFFFF3366);
        glowColor = const Color(0xFFFF3366).withOpacity(0.45);
        label = 'ERROR';
        icon = Icons.warning_amber_rounded;
        break;
      case VpnStatus.disconnected:
      default:
        primaryColor = const Color(0xFF00D4FF);
        glowColor = const Color(0xFF00D4FF).withOpacity(0.25);
        label = 'START TUNNEL';
        icon = Icons.power_settings_new_rounded;
        break;
    }

    final isAnimating = widget.status == VpnStatus.connected || widget.status == VpnStatus.connecting;

    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          final scale = isAnimating ? _pulseAnim.value : 1.0;
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(100),
          splashColor: primaryColor.withOpacity(0.3),
          child: Container(
            width: 175,
            height: 175,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF161A29),
                  const Color(0xFF0D0F18),
                ],
              ),
              border: Border.all(
                color: primaryColor.withOpacity(0.8),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: glowColor,
                  blurRadius: 35,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 56,
                  color: primaryColor,
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
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
