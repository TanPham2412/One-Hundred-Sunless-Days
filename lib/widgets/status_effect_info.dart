import 'package:flutter/material.dart';
import 'package:one_hundred_sunless_days/l10n/app_strings.dart';
import 'package:one_hundred_sunless_days/models/status.dart';

// ────────────────────────────────────────────────────────────────────────────
// Dữ liệu hiển thị của các trạng thái (buff / debuff)
// ────────────────────────────────────────────────────────────────────────────

/// Dữ liệu tĩnh (màu, key chuỗi, biểu tượng, nhóm) cho một [StatusId].
class StatusEffectInfo {
  final StatusId id;
  final String nameKey;
  final String descKey;
  final Color color;
  final String icon;

  /// Nhóm hoạt động: [StatusGroup.explore], [StatusGroup.combat],
  /// hoặc [StatusGroup.exploreAndCombat].
  final StatusGroup group;

  const StatusEffectInfo({
    required this.id,
    required this.nameKey,
    required this.descKey,
    required this.color,
    required this.icon,
    required this.group,
  });

  // ── Buff: Khám Phá ────────────────────────────────────────────────────────

  static const Map<StatusId, StatusEffectInfo> all = {
    StatusId.tomorrowExploreBonus: StatusEffectInfo(
      id: StatusId.tomorrowExploreBonus,
      nameKey: 'statusTomorrowExploreBonus',
      descKey: 'statusTomorrowExploreBonusDesc',
      color: Color(0xFFD4A843),
      icon: '✦',
      group: StatusGroup.explore,
    ),

    // ── Buff: Khám Phá & Chiến Đấu ───────────────────────────────────────────

    StatusId.shielded: StatusEffectInfo(
      id: StatusId.shielded,
      nameKey: 'statusShielded',
      descKey: 'statusShieldedDesc',
      color: Color(0xFF88BBDD),
      icon: '◈',
      group: StatusGroup.exploreAndCombat,
    ),

    // ── Debuff: Khám Phá & Tập Luyện ─────────────────────────────────────────

    StatusId.racingHeart: StatusEffectInfo(
      id: StatusId.racingHeart,
      nameKey: 'statusRacingHeart',
      descKey: 'statusRacingHeartDesc',
      color: Color(0xFFCC4422),
      icon: '♥',
      group: StatusGroup.explore,
    ),

    StatusId.tightChest: StatusEffectInfo(
      id: StatusId.tightChest,
      nameKey: 'statusTightChest',
      descKey: 'statusTightChestDesc',
      color: Color(0xFF886699),
      icon: '☁',
      group: StatusGroup.explore,
    ),

    // ── Debuff: Chiến Đấu ────────────────────────────────────────────────────────

    StatusId.sleepy: StatusEffectInfo(
      id: StatusId.sleepy,
      nameKey: 'statusSleepy',
      descKey: 'statusSleepyDesc',
      color: Color(0xFF4466AA),
      icon: '⏾',
      group: StatusGroup.combat,
    ),

    StatusId.fear: StatusEffectInfo(
      id: StatusId.fear,
      nameKey: 'statusFear',
      descKey: 'statusFearDesc',
      color: Color(0xFFAA2222),
      icon: '⚠',
      group: StatusGroup.combat,
    ),

    StatusId.bleeding: StatusEffectInfo(
      id: StatusId.bleeding,
      nameKey: 'statusBleeding',
      descKey: 'statusBleedingDesc',
      color: Color(0xFF992211),
      icon: '†',
      group: StatusGroup.combat,
    ),

    StatusId.poisoned: StatusEffectInfo(
      id: StatusId.poisoned,
      nameKey: 'statusPoisoned',
      descKey: 'statusPoisonedDesc',
      color: Color(0xFF446633),
      icon: '☠',
      group: StatusGroup.combat,
    ),

    StatusId.dislocated: StatusEffectInfo(
      id: StatusId.dislocated,
      nameKey: 'statusDislocated',
      descKey: 'statusDislocatedDesc',
      color: Color(0xFF887744),
      icon: '⛓',
      group: StatusGroup.combat,
    ),

    StatusId.stunned: StatusEffectInfo(
      id: StatusId.stunned,
      nameKey: 'statusStunned',
      descKey: 'statusStunnedDesc',
      color: Color(0xFF6655AA),
      icon: '★',
      group: StatusGroup.combat,
    ),
  };

  static StatusEffectInfo? of(StatusId id) => all[id];
}

// ────────────────────────────────────────────────────────────────────────────
// Badge hiển thị một trạng thái đang hoạt động
// ────────────────────────────────────────────────────────────────────────────

/// Hiển thị một trạng thái (tên + mô tả + màu sắc theo loại).
class StatusEffectBadge extends StatelessWidget {
  final StatusId status;

  const StatusEffectBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final info = StatusEffectInfo.of(status);
    if (info == null) return const SizedBox.shrink();
    final color = info.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.40), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 14,
            child: Text(
              info.icon,
              style: TextStyle(
                fontFamily: 'GnuUnifont',
                fontSize: 11,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get(info.nameKey),
                  style: TextStyle(
                    fontFamily: 'GnuUnifont',
                    fontSize: 11,
                    color: color,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  AppStrings.get(info.descKey),
                  style: const TextStyle(
                    fontFamily: 'GnuUnifont',
                    fontSize: 9,
                    color: Color(0xFF8A8478),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
