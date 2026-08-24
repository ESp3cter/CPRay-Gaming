import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_profile.dart';
import '../providers/vpn_provider.dart';
import '../services/localization_service.dart';

class GameProfilesView extends StatelessWidget {
  const GameProfilesView({super.key});

  @override
  Widget build(BuildContext context) {
    final vpnProvider = context.watch<VpnProvider>();
    final activeProfileId = vpnProvider.settings.activeGameProfileId;

    return Container(
      color: const Color(0xFF090B10),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocalizationService.tr('game_profiles'),
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '1-Click automated DNS, MTU, Anti-Sanction, and routing presets for competitive games',
                    style: TextStyle(color: Color(0xFF6B7A94), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          Expanded(
            child: ListView.builder(
              itemCount: GameProfile.defaultProfiles.length,
              itemBuilder: (context, index) {
                final profile = GameProfile.defaultProfiles[index];
                final isActive = activeProfileId == profile.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF14192A) : const Color(0xFF10131E),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isActive ? const Color(0xFF00FF88) : const Color(0xFF1E2438),
                      width: isActive ? 1.8 : 1.0,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: const Color(0xFF00FF88).withOpacity(0.15),
                              blurRadius: 14,
                              spreadRadius: 1,
                            )
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF151928),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(profile.icon, style: const TextStyle(fontSize: 26)),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  profile.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (profile.antiSanctionEnabled) ...[
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00D4FF).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'ANTI-SANCTION',
                                      style: TextStyle(
                                        color: Color(0xFF00D4FF),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              profile.description,
                              style: const TextStyle(color: Color(0xFF8C9BAE), fontSize: 12, height: 1.3),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              children: [
                                _buildTag('Target: ${profile.targetRegion}', const Color(0xFF9D00FF)),
                                _buildTag('DNS: ${profile.optimalDns}', const Color(0xFF00D4FF)),
                                _buildTag('Apps: ${profile.processNames.take(2).join(", ")}', const Color(0xFF6B7A94)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => vpnProvider.applyGameProfile(profile),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isActive ? const Color(0xFF00FF88) : const Color(0xFF181E30),
                          foregroundColor: isActive ? const Color(0xFF090B10) : const Color(0xFF00D4FF),
                          side: BorderSide(
                            color: isActive ? const Color(0xFF00FF88) : const Color(0xFF00D4FF).withOpacity(0.5),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: Icon(
                          isActive ? Icons.check_circle_rounded : Icons.flash_on_rounded,
                          size: 18,
                        ),
                        label: Text(
                          isActive ? 'PROFILE ACTIVE' : 'APPLY PROFILE',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}
