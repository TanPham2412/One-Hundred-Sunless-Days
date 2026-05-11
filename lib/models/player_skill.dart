// ────────────────────────────────────────────────────────────────────────────
// Hệ thống kỹ năng của người chơi
// ────────────────────────────────────────────────────────────────────────────

/// Kiểu hiệu ứng của kỹ năng người chơi.
enum PlayerSkillType {
  /// Tấn công nhiều lần với các hệ số sát thương khác nhau.
  multiHit,

  /// Tấn công đơn với hệ số sát thương tùy chỉnh.
  singleHit,

  /// Kỹ năng không gây sát thương (buff, debuff, v.v.).
  utility,
}

/// Một nhát đánh trong kỹ năng [multiHit] / [singleHit].
class SkillHit {
  /// Hệ số nhân sát thương (1.0 = 100% ATK cơ bản).
  final double atkMultiplier;

  /// Nếu `true`, nhát này bỏ qua Phòng Thủ.
  final bool ignoresArmor;

  const SkillHit({
    required this.atkMultiplier,
    this.ignoresArmor = false,
  });
}

/// Dữ liệu một kỹ năng của người chơi.
class PlayerSkill {
  /// Key l10n cho tên hiển thị.
  final String nameKey;

  /// Thể Lực tiêu hao khi dùng kỹ năng.
  final int staminaCost;

  /// Loại kỹ năng.
  final PlayerSkillType type;

  /// Danh sách các nhát đánh (dùng cho [multiHit] và [singleHit]).
  /// Thứ tự trong list = thứ tự ra đòn.
  final List<SkillHit> hits;

  const PlayerSkill({
    required this.nameKey,
    required this.staminaCost,
    required this.type,
    this.hits = const [],
  });
}

// ────────────────────────────────────────────────────────────────────────────
// Danh sách kỹ năng mặc định của người chơi
// ────────────────────────────────────────────────────────────────────────────

/// Tất cả kỹ năng được định nghĩa sẵn trong game.
/// Thêm kỹ năng mới vào đây.
class PlayerSkills {
  PlayerSkills._();

  /// [Chém Đôi] – Kỹ năng cơ bản ban đầu.
  ///
  /// Tấn công 2 lần liên tiếp:
  /// - Nhát 1: 100% ATK.
  /// - Nhát 2: 50% ATK.
  ///
  /// Tiêu hao: 12 Thể Lực.
  static const PlayerSkill doubleSlash = PlayerSkill(
    nameKey:      'playerSkillDoubleSlashName',
    staminaCost:  12,
    type:         PlayerSkillType.multiHit,
    hits: [
      SkillHit(atkMultiplier: 1.0),
      SkillHit(atkMultiplier: 0.5),
    ],
  );

  /// Danh sách kỹ năng mặc định người chơi bắt đầu với.
  static const List<PlayerSkill> defaultSkills = [
    doubleSlash,
  ];
}
