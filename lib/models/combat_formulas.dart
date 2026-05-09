// ────────────────────────────────────────────────────────────────────────────
// Công thức chiến đấu dùng chung (nhân vật & quái vật)
// ────────────────────────────────────────────────────────────────────────────

/// Tập hợp các công thức tính toán dùng chung cho cả nhân vật lẫn quái vật.
/// Tất cả các phương thức đều là `static` – không cần khởi tạo đối tượng.
abstract final class CombatFormulas {
  // ── Giáp / Phòng Thủ ─────────────────────────────────────────────────────

  /// Tính sát thương thực tế sau khi áp dụng giáp.
  ///
  /// Công thức: `actualDamage = rawDamage × (50 / (50 + armorValue))`
  ///
  /// - Tối thiểu **1** nếu `rawDamage > 0` (giáp không thể hoàn toàn vô hiệu hóa đòn đánh).
  /// - Trả về **0** nếu `rawDamage ≤ 0`.
  ///
  /// Ví dụ:
  /// ```
  /// applyArmor(10, 0)   → 10   (không có giáp)
  /// applyArmor(10, 50)  → 5    (giảm 50%)
  /// applyArmor(10, 200) → 2    (giảm 80%)
  /// ```
  static int applyArmor(int rawDamage, int armorValue) {
    if (rawDamage <= 0) return 0;
    if (armorValue <= 0) return rawDamage;
    final double reduced = rawDamage * 50 / (50 + armorValue);
    return reduced.round().clamp(1, rawDamage);
  }

  // ── Nhanh Nhẹn / Né Tránh & Tốc Độ Ra Đòn ──────────────────────────────

  /// Tính tỉ lệ né tránh dựa theo chỉ số Nhanh Nhẹn [agi].
  ///
  /// Công thức: `Base + clamp(AGI, 0, 100) / 100 × Max_Bonus`
  /// - Tuyến tính – mỗi điểm AGI đóng góp đều nhau (+0.45% né/điểm).
  /// - **Base** = 5%  – né tối thiểu khi AGI = 0.
  /// - **Max_Bonus** = 45% – cộng thêm tối đa; tổng trần = 50% ở AGI 100.
  ///
  /// Ví dụ:
  /// ```
  /// evasionRate(0)   → 0.050  ( 5.0%)
  /// evasionRate(5)   → 0.073  ( 7.25%)
  /// evasionRate(20)  → 0.140  (14.0%)
  /// evasionRate(50)  → 0.275  (27.5%)
  /// evasionRate(100) → 0.500  (50.0%)
  /// ```
  static double evasionRate(int agi) {
    const double base = 0.05;
    const double maxBonus = 0.45;
    return base + agi.clamp(0, 100) / 100.0 * maxBonus;
  }

  /// Trả về `true` nếu đòn tấn công bị né.
  ///
  /// [roll] phải là số ngẫu nhiên trong `[0.0, 1.0)` do lớp game-rule cung cấp.
  /// Giữ nguyên tính thuần túy (pure) – không gọi `Random` trực tiếp ở đây.
  static bool isEvaded(int agi, double roll) => roll < evasionRate(agi);

  // ── Tốc Độ Ra Đòn (Action Value – kiểu Honkai: Star Rail) ────────────────
  //
  // Cơ chế:
  //   1. Khởi chiến: mỗi entity nhận currentAV = actionValue(agi).
  //   2. Vòng lặp:
  //        a. Tìm entity có currentAV nhỏ nhất → entity đó hành động kế tiếp.
  //        b. Trừ đi delta = currentAV[actor] khỏi TẤT CẢ entity
  //           (dịch chuyển "đồng hồ" đến khi actor vừa tới lượt, AV = 0).
  //        c. Xử lý lượt của actor.
  //        d. currentAV[actor] += actionValue(actor.agi)  (nạp lại gauge).
  //        e. Quay lại bước a.
  //
  // Ý nghĩa: AGI 100 → AV = 100; AGI 5 → AV = 2000.
  // Nhân vật AGI 100 ra đòn nhiều gấp 20× so với AGI 5 trong cùng thời gian.

  /// Action Value cơ bản cho một entity có [agi] điểm Nhanh Nhẹn.
  ///
  /// Công thức: `10 000 / AGI`
  ///
  /// Ví dụ:
  /// ```
  /// actionValue(5)   → 2000.0
  /// actionValue(10)  → 1000.0
  /// actionValue(20)  →  500.0
  /// actionValue(50)  →  200.0
  /// actionValue(100) →  100.0
  /// ```
  static double actionValue(int agi) {
    assert(agi > 0, 'actionValue: AGI phải > 0');
    return 10000.0 / agi;
  }

  /// Trả về index của entity sẽ hành động tiếp theo trong [currentAVs].
  ///
  /// Entity có **AV thấp nhất** đánh trước.
  /// Nếu hòa điểm, ưu tiên index nhỏ hơn (người chơi thường ở index 0).
  ///
  /// Ví dụ:
  /// ```dart
  /// final avs = [200.0, 150.0, 300.0]; // player, enemy1, enemy2
  /// nextToAct(avs); // → 1  (enemy1 AV thấp nhất)
  /// ```
  static int nextToAct(List<double> currentAVs) {
    assert(currentAVs.isNotEmpty, 'nextToAct: danh sách AV không được rỗng');
    int best = 0;
    for (int i = 1; i < currentAVs.length; i++) {
      if (currentAVs[i] < currentAVs[best]) best = i;
    }
    return best;
  }

  /// Dịch chuyển toàn bộ đồng hồ AV đến khi entity tại [actorIndex] tới lượt.
  ///
  /// Trừ `currentAVs[actorIndex]` khỏi mọi phần tử trong [currentAVs].
  /// Sau khi gọi, `currentAVs[actorIndex]` = 0.0 (sẵn sàng hành động).
  ///
  /// [currentAVs] được cập nhật **in-place**.
  static void advanceTime(List<double> currentAVs, int actorIndex) {
    final double delta = currentAVs[actorIndex];
    for (int i = 0; i < currentAVs.length; i++) {
      currentAVs[i] -= delta;
    }
  }
}
