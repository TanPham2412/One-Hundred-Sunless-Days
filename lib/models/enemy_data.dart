import 'dart:math';

// ────────────────────────────────────────────────────────────────────────────
// Hệ thống dữ liệu chiến đấu của kẻ địch
// ────────────────────────────────────────────────────────────────────────────

/// Hiệu ứng [Chảy Máu] mà một kỹ năng kẻ địch có thể gây ra.
class EnemyBleedOnHit {
  /// Xác suất kích hoạt debuff (0.0 – 1.0).
  final double chance;

  /// Số hiệp debuff kéo dài.
  final int turns;

  /// Lượng HP bị trừ mỗi hiệp.
  final int dmgPerTurn;

  const EnemyBleedOnHit({
    required this.chance,
    required this.turns,
    required this.dmgPerTurn,
  });
}

// ────────────────────────────────────────────────────────────────────────────
// Kỹ năng đặc biệt
// ────────────────────────────────────────────────────────────────────────────

/// Một kỹ năng đặc biệt của kẻ địch.
class EnemySkill {
  /// Key l10n cho tên hiển thị của kỹ năng.
  final String nameKey;

  /// Thể Lực kẻ địch tiêu hao khi dùng kỹ năng này.
  final int staminaCost;

  /// Sát thương tối thiểu (0 = kỹ năng không gây sát thương HP).
  final int dmgMin;

  /// Sát thương tối đa (0 = kỹ năng không gây sát thương HP).
  final int dmgMax;

  /// Nếu `true`, đòn này bỏ qua toàn bộ Phòng Thủ của người chơi.
  final bool ignoresArmor;

  /// HP kẻ địch tự hồi sau khi đòn đánh trúng (0 = không hồi).
  final int lifestealHp;

  /// Hiệu ứng [Chảy Máu] đi kèm; `null` = kỹ năng này không gây chảy máu.
  final EnemyBleedOnHit? bleed;

  /// Hiệu ứng [Nhiễm Độc] đi kèm (cấu trúc giống bleed); `null` = không gây nhiễm độc.
  final EnemyBleedOnHit? poison;

  /// Số hiệp [Sợ Hãi] áp lên người chơi khi đánh trúng (0 = không gây).
  final int inflictsFearTurns;

  /// Nếu true, áp [Trật Khớp] lên người chơi khi đánh trúng.
  final bool inflictsDislocated;

  /// Nếu true, người chơi bị [Choáng] 1 hiệp (mất lượt tiếp theo).
  final bool inflictsStun;

  /// Trừ thẳng Thể Lực (Stamina) của người chơi, không trừ HP (0 = không dùng).
  final int playerStaminaDrain;

  const EnemySkill({
    required this.nameKey,
    required this.staminaCost,
    this.dmgMin             = 0,
    this.dmgMax             = 0,
    this.ignoresArmor       = false,
    this.lifestealHp        = 0,
    this.bleed,
    this.poison,
    this.inflictsFearTurns  = 0,
    this.inflictsDislocated = false,
    this.inflictsStun       = false,
    this.playerStaminaDrain = 0,
  });
}

// ────────────────────────────────────────────────────────────────────────────
// Chỉ số chiến đấu của kẻ địch
// ────────────────────────────────────────────────────────────────────────────

/// Toàn bộ thông số chiến đấu của một loại kẻ địch.
class EnemyData {
  /// HP tối đa.
  final int maxHp;

  /// Phòng Thủ – giảm sát thương nhận vào từ đòn thường.
  /// Không áp dụng cho đòn có [EnemySkill.ignoresArmor] = true.
  final int defense;

  /// Nhanh Nhẹn – ảnh hưởng thứ tự hành động và tỷ lệ né.
  final int agility;

  /// Thể Lực tối đa.
  final int maxStamina;

  /// Sát thương tấn công thường – tối thiểu.
  final int atkMin;

  /// Sát thương tấn công thường – tối đa.
  final int atkMax;

  /// Danh sách kỹ năng đặc biệt (rỗng = chỉ đánh thường).
  final List<EnemySkill> skills;

  const EnemyData({
    required this.maxHp,
    required this.defense,
    required this.agility,
    required this.maxStamina,
    required this.atkMin,
    required this.atkMax,
    this.skills = const [],
  });

  // ── Logic lựa chọn hành động ─────────────────────────────────────────────

  /// Quyết định hành động của kẻ địch trong lượt này.
  ///
  /// Trả về `null`  → đánh thường.
  /// Trả về `int` ≥ 0 → dùng kỹ năng tại index đó trong [skills].
  ///
  /// Quy tắc:
  /// - Lọc ra các kỹ năng đủ [currentStamina] để kích hoạt.
  /// - Nếu **không có** kỹ năng nào khả dụng → **100% đánh thường**.
  /// - Nếu có ít nhất 1 kỹ năng khả dụng → random đều giữa tất cả kỹ năng
  ///   đó **cộng thêm 1 slot đánh thường** (xác suất bằng nhau mỗi slot).
  int? rollActionIndex(int currentStamina, Random rng) {
    final available = <int>[
      for (int i = 0; i < skills.length; i++)
        if (currentStamina >= skills[i].staminaCost) i,
    ];
    if (available.isEmpty) return null; // không đủ thể lực → chắc chắn đánh thường
    final roll = rng.nextInt(available.length + 1); // +1 slot cho đánh thường
    return roll < available.length ? available[roll] : null;
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Registry kẻ địch
// ────────────────────────────────────────────────────────────────────────────

abstract class EnemyRegistry {
  EnemyRegistry._();

  // ── THI THỂ NHẠI TIẾNG ───────────────────────────────────────────────────
  // Xuất hiện từ sự kiện [Lời Cầu Cứu Ngoài Cửa] – nhánh tấn công (25%).
  // Kẻ địch cấp thấp nhưng nguy hiểm nếu người chơi không kiểm soát chảy máu.
  static const EnemyData mimickingCorpse = EnemyData(
    maxHp:      45,
    defense:    2,
    agility:    8,
    maxStamina: 30,
    atkMin:     4,
    atkMax:     7,
    skills: [
      // ── Kỹ năng 1: Vồ Vập Xé Xác ────────────────────────────────────────
      // Tiêu hao: −15 Thể Lực
      // Sát thương: 7–9
      // Hiệu ứng phụ: 40% gây [Chảy Máu] 3 hiệp, mỗi hiệp −3 HP
      EnemySkill(
        nameKey:     'enemySkillLungingTearName',
        staminaCost: 15,
        dmgMin:      7,
        dmgMax:      9,
        bleed: EnemyBleedOnHit(chance: 0.40, turns: 3, dmgPerTurn: 3),
      ),

      // ── Kỹ năng 2: Rễ Ký Sinh Hút Máu ───────────────────────────────────
      // Tiêu hao: −15 Thể Lực
      // Sát thương: 6 cố định, bỏ qua Phòng Thủ người chơi
      // Hiệu ứng phụ: kẻ địch hồi +6 HP
      EnemySkill(
        nameKey:      'enemySkillParasiticRootName',
        staminaCost:  15,
        dmgMin:       6,
        dmgMax:       6,
        ignoresArmor: true,
        lifestealHp:  6,
      ),
    ],
  );

  // ── DÃ KHUYỂN KHÂU MẮT ───────────────────────────────────────────────────
  // Xuất hiện ngẫu nhiên trong sự kiện ban đêm (outsidePlea / nightRaid).
  static const EnemyData stitchedEyeHound = EnemyData(
    maxHp:      50,
    defense:    2,
    agility:    10,
    maxStamina: 25,
    atkMin:     5,
    atkMax:     7,
    skills: [
      // ── Kỹ năng 1: Cắn Xé Động Mạch ─────────────────────────────────────
      // Tiêu hao: −15 Thể Lực  |  Sát thương: 8–10
      // Hiệu ứng phụ: 60% gây [Chảy Máu] 3 hiệp, mỗi hiệp −5 HP
      EnemySkill(
        nameKey:     'enemySkillJugularBiteName',
        staminaCost: 15,
        dmgMin:      8,
        dmgMax:      10,
        bleed: EnemyBleedOnHit(chance: 0.60, turns: 3, dmgPerTurn: 5),
      ),

      // ── Kỹ năng 2: Tiếng Hú Báo Tử ──────────────────────────────────────
      // Tiêu hao: −10 Thể Lực  |  Không gây sát thương
      // Hiệu ứng phụ: ép người chơi dính [Sợ Hãi] 2 hiệp
      EnemySkill(
        nameKey:           'enemySkillDeathHowlName',
        staminaCost:       10,
        inflictsFearTurns: 2,
      ),
    ],
  );

  // ── GIÁO SĨ ĐỌA ĐÀY ──────────────────────────────────────────────────────
  // Xuất hiện ngẫu nhiên trong sự kiện ban đêm (outsidePlea / nightRaid).
  static const EnemyData corruptedCleric = EnemyData(
    maxHp:      75,
    defense:    5,
    agility:    3,
    maxStamina: 40,
    atkMin:     8,
    atkMax:     10,
    skills: [
      // ── Kỹ năng 1: Phán Xét Tội Lỗi ─────────────────────────────────────
      // Tiêu hao: −20 Thể Lực  |  Sát thương: 12–16
      // Hiệu ứng phụ: áp [Trật Khớp] lên người chơi
      EnemySkill(
        nameKey:             'enemySkillSinfulJudgmentName',
        staminaCost:         20,
        dmgMin:              12,
        dmgMax:              16,
        inflictsDislocated:  true,
      ),

      // ── Kỹ năng 2: Tụng Niệm Tà Ác ──────────────────────────────────────
      // Tiêu hao: −20 Thể Lực  |  Không gây sát thương
      // Hiệu ứng phụ: người chơi bị [Choáng] 1 hiệp + kẻ địch tự hồi +10 HP
      EnemySkill(
        nameKey:      'enemySkillEvilChantName',
        staminaCost:  20,
        lifestealHp:  10,
        inflictsStun: true,
      ),
    ],
  );

  // ── KHỐI NHẦY NUỐT SÁNG ──────────────────────────────────────────────────
  // Xuất hiện ngẫu nhiên trong sự kiện ban đêm (outsidePlea / nightRaid).
  static const EnemyData lightDevouringSludge = EnemyData(
    maxHp:      45,
    defense:    1,
    agility:    5,
    maxStamina: 30,
    atkMin:     3,
    atkMax:     5,
    skills: [
      // ── Kỹ năng 1: Rút Cạn Dưỡng Khí ────────────────────────────────────
      // Tiêu hao: −15 Thể Lực  |  Không gây sát thương HP
      // Hiệu ứng phụ: trừ thẳng −15 Thể Lực (Stamina) của người chơi
      EnemySkill(
        nameKey:            'enemySkillOxygenDeprivationName',
        staminaCost:        15,
        playerStaminaDrain: 15,
      ),

      // ── Kỹ năng 2: Phun Axit Sương Đục ──────────────────────────────────
      // Tiêu hao: −15 Thể Lực  |  Sát thương: 6
      // Hiệu ứng phụ: gây [Nhiễm Độc] −2 HP/hiệp suốt trận chiến
      EnemySkill(
        nameKey:     'enemySkillAcidMistName',
        staminaCost: 15,
        dmgMin:      6,
        dmgMax:      6,
        // turns: 99 = bền vững suốt trận (thực tế là đến khi chiến đấu kết thúc)
        poison: EnemyBleedOnHit(chance: 1.0, turns: 99, dmgPerTurn: 2),
      ),
    ],
  );

  // ── VỎ BỌC CỦA KẺ MÙ ────────────────────────────────────────────────────
  // Kẻ địch cấp thấp với kỹ năng xuyên giáp, sử dụng bóng tối để tấn công.
  static const EnemyData watcherGuise = EnemyData(
    maxHp:      20,
    defense:    0,
    agility:    3,
    maxStamina: 10,
    atkMin:     2,
    atkMax:     3,
    skills: [
      // ── Kỹ năng 1: Trảo Bóng Đêm ─────────────────────────────────────────
      // Tiêu hao: −5 Thể Lực  |  Sát thương: 4 cố định
      // Cái bóng dưới chân lão đột ngột vươn dài,
      // cào một vệt buốt giá qua lồng ngực bạn.
      EnemySkill(
        nameKey:     'enemySkillShadowClawName',
        staminaCost: 5,
        dmgMin:      4,
        dmgMax:      4,
      ),
    ],
  );
}
