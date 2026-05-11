// ────────────────────────────────────────────────────────────────────────────
// Trạng thái (buff / debuff)
// ────────────────────────────────────────────────────────────────────────────

/// Nhóm hoạt động của một trạng thái.
enum StatusGroup {
  /// Chỉ có hiệu lực trong quá trình Khám Phá.
  explore,

  /// Chỉ có hiệu lực trong Chiến Đấu.
  combat,

  /// Có hiệu lực trong cả Khám Phá lẫn Chiến Đấu.
  exploreAndCombat,
}

enum StatusId {
  // ── Buff: Khám Phá ────────────────────────────────────────────────────────

  /// Khám Phá Ngày Mai – tăng tỷ lệ nhặt đồ trong lần khám phá tiếp theo.
  tomorrowExploreBonus,

  // ── Buff: Khám Phá & Chiến Đấu ───────────────────────────────────────────

  /// Được Che Chở – miễn nhiễm toàn bộ debuff trong khám phá và chiến đấu.
  shielded,

  // ── Debuff: Khám Phá & Tập Luyện ─────────────────────────────────────────

  /// Tim Đập Mạnh – mọi hành động tiêu hao Thể Lực khi Khám Phá và Tập Luyện đều tốn gấp đôi.
  racingHeart,

  /// Tức Ngực – mọi hành động tiêu hao Thể Lực khi Khám Phá và Tập Luyện đều tốn thêm +5.
  tightChest,
  // ── Debuff: Chiến Đấu ────────────────────────────────────────────────────────────

  /// Ngái Ngủ – kẻ thù luôn đánh lượt đầu tiên trong trận chiến.
  sleepy,

  /// Sợ Hãi – khóa toàn bộ kỹ năng đặc biệt trong chiến đấu.
  fear,

  /// Chảy Máu – mỗi hiệp chiến đấu bị trừ một lượng HP nhất định.
  bleeding,

  /// Nhiễm Độc – mỗi hiệp chiến đấu bị trừ HP (cơ chế giống Chảy Máu, hiệu ứng khác).
  poisoned,

  /// Trật Khớp – Action Value bị đẩy lùi 20%, hành động chậm hơn rõ rệt.
  dislocated,

  /// Choáng – mất lượt hành động tiếp theo (không thể tấn công hoặc phòng thủ).
  stunned,
}

class StatusChange {
  final StatusId status;
  final bool apply;
  final int durationDays;
  final double chance;

  const StatusChange({
    required this.status,
    required this.apply,
    this.durationDays = 0,
    this.chance = 1.0,
  });
}
