import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/character.dart';

// ────────────────────────────────────────────────────────────────────────────
// Màn Hình Chiến Đấu (placeholder – chưa triển khai đầy đủ)
// ────────────────────────────────────────────────────────────────────────────

/// Màn hình combat – hiện tại chỉ là placeholder.
/// Hiển thị thông báo [Ngái ngủ] nếu người chơi bị đột kích ban đêm.
class CombatScreen extends StatelessWidget {
  final Character character;

  /// true nếu vào từ sự kiện Đột Kích Ban Đêm:
  /// → Người chơi bắt đầu với trạng thái [Ngái ngủ], mất lượt đánh đầu tiên.
  final bool startGroggy;

  const CombatScreen({
    super.key,
    required this.character,
    this.startGroggy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.get('combatTitle'),
                  style: const TextStyle(
                    fontFamily: 'GnuUnifont',
                    fontSize: 18,
                    color: Color(0xFFCC4433),
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 24),
                if (startGroggy)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color(0xFFCC8833).withValues(alpha: 0.5)),
                      color: const Color(0xFFCC8833).withValues(alpha: 0.08),
                    ),
                    child: Text(
                      AppStrings.get('combatGroggyWarning'),
                      style: const TextStyle(
                        fontFamily: 'GnuUnifont',
                        fontSize: 11,
                        color: Color(0xFFCC8833),
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 32),
                // TODO: Triển khai hệ thống chiến đấu
                Text(
                  AppStrings.get('combatComingSoon'),
                  style: const TextStyle(
                    fontFamily: 'GnuUnifont',
                    fontSize: 11,
                    color: Color(0xFF4A3A28),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF2A2010)),
                    ),
                    child: Text(
                      AppStrings.get('combatFlee'),
                      style: const TextStyle(
                        fontFamily: 'GnuUnifont',
                        fontSize: 11,
                        color: Color(0xFF8A8478),
                        letterSpacing: 1,
                      ),
                    ),
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
