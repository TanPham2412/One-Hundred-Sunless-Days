import 'dart:math';

import 'character.dart';

// ────────────────────────────────────────────────────────────────────────────
// Hệ thống Lồng Đèn Xương (Bone Lantern System)
//
// Độ Sáng (Brightness) là chỉ số trung tâm chi phối chất lượng giấc ngủ,
// tỷ lệ sự kiện đêm và ngưỡng Hoảng Loạn khi khám phá.
// ────────────────────────────────────────────────────────────────────────────

/// Mức độ sáng của Lồng Đèn tại thời điểm nghỉ ngơi.
enum BrightnessLevel {
  bright,       // 70–100%: Giấc ngủ an bình
  dim,          // 30–69%:  Giấc ngủ chập chờn
  dark,         //  1–29%:  Bóng dè
  extinguished, //     0%:  Đêm kinh hoàng
}

/// Xác suất xảy ra mỗi NightEvent theo mức Độ Sáng.
/// Tổng các trọng số phải = 1.0 cho mỗi mức.
class _NightWeights {
  final double deepSleep;
  final double nightmare;
  final double blindWhisper;
  final double emberThief;
  final double nightRaid;
  final double sadMemory;
  final double outsidePlea;
  final double toxicFog;
  final double vaultSong;
  final double ashFlare;
  final double suddenDeathDoor;

  const _NightWeights({
    required this.deepSleep,
    required this.nightmare,
    required this.blindWhisper,
    required this.emberThief,
    required this.nightRaid,
    required this.sadMemory,
    required this.outsidePlea,
    required this.toxicFog,
    required this.vaultSong,
    required this.ashFlare,
    required this.suddenDeathDoor,
  });
}

/// Tất cả logic hệ thống Lồng Đèn Xương.
///
/// Không có trạng thái – toàn bộ phương thức là static.
class LanternSystem {
  LanternSystem._();

  // ── Hằng số tiêu hao ──────────────────────────────────────────────────────

  /// Giảm Độ Sáng mỗi lần nhấn Khám Phá.
  static const int exploreCost = 10;

  /// Giảm Độ Sáng mỗi lần Nghỉ Ngơi.
  static const int restCost = 5;

  /// Số Tro Tàn cần để tiếp nhiên liệu một lần.
  static const int refuelEmberCost = 10;

  /// Lượng Độ Sáng hồi phục mỗi lần tiếp nhiên liệu.
  static const int refuelBrightnessGain = 20;

  // ── Ngưỡng Hoảng Loạn ─────────────────────────────────────────────────────

  /// Dưới ngưỡng này trong khi Khám Phá → kích hoạt trạng thái [Hoảng Loạn].
  static const int panicThreshold = 50;

  /// Sanity bị trừ mỗi hành động khi đang Hoảng Loạn.
  static const int panicSanityLossPerAction = 5;

  // ── Bảng tra mức Độ Sáng ──────────────────────────────────────────────────

  /// Trả về [BrightnessLevel] tương ứng với giá trị [brightness] (0–100).
  static BrightnessLevel levelOf(int brightness) {
    if (brightness >= 70) return BrightnessLevel.bright;
    if (brightness >= 40) return BrightnessLevel.dim;
    if (brightness >= 10) return BrightnessLevel.dark;
    return BrightnessLevel.extinguished;
  }

  // ── Ảnh hưởng đến Tỉnh Táo khi ngủ ──────────────────────────────────────

  /// Thay đổi Sanity dựa trên Độ Sáng khi nghỉ ngơi.
  ///
  /// | Mức sáng           | Sanity  |
  /// |-------------------|----------|
  /// | Bright (70–100)   | +15      |
  /// | Dim (30–69)       | +5       |
  /// | Dark (1–29)       | 0        |
  /// | Extinguished (0)  | -15      |
  static int sleepSanityChange(int brightness) => switch (levelOf(brightness)) {
        BrightnessLevel.bright       =>  15,
        BrightnessLevel.dim          =>   5,
        BrightnessLevel.dark         =>   0,
        BrightnessLevel.extinguished => -15,
      };

  // ── Ảnh hưởng đến HP khi ngủ ──────────────────────────────────────────────

  /// % maxHp được hồi phục khi ngủ (âm = mất HP).
  ///
  /// | Mức sáng           | HP       |
  /// |-------------------|----------|
  /// | Bright (75–100)   | +20%     |
  /// | Dim (40–74)       | +10%     |
  /// | Dark (15–39)      | +5%      |
  /// | Extinguished (0–14)| -5%    |
  static double sleepHpHealPercent(int brightness) => switch (levelOf(brightness)) {
        BrightnessLevel.bright       =>  0.20,
        BrightnessLevel.dim          =>  0.10,
        BrightnessLevel.dark         =>  0.05,
        BrightnessLevel.extinguished => -0.05,
      };

  // ── Bảng xác suất NightEvent ──────────────────────────────────────────────
  //
  // bright (70–100%):  3 sự kiện, tổng = 1.00
  // dim    (40–69%):   3 sự kiện, tổng = 1.00
  // dark   (10–39%):   3 sự kiện, tổng = 1.00
  // exting ( 0– 9%):   2 sự kiện, tổng = 1.00

  static const Map<BrightnessLevel, _NightWeights> _weights = {
    // 🟢 Bright – Giấc ngủ an bình
    // [60%] Giấc Ngủ Sâu  | [30%] Tiếng Thì Thầm Kẻ Mù  | [10%] Sự Soi Rọi Tro Tàn
    BrightnessLevel.bright: _NightWeights(
      deepSleep: 0.60, nightmare: 0.00, blindWhisper: 0.30, emberThief: 0.00,
      nightRaid: 0.00, sadMemory: 0.00, outsidePlea: 0.00, toxicFog: 0.00,
      vaultSong: 0.00, ashFlare: 0.10, suddenDeathDoor: 0.00,
    ),
    // 🟡 Dim – Giấc ngủ chập chờn
    // [50%] Hồi Ức U Buồn  | [30%] Lời Cầu Cứu Ngoài Cửa  | [20%] Kẻ Trộm Tro Tàn
    BrightnessLevel.dim: _NightWeights(
      deepSleep: 0.00, nightmare: 0.00, blindWhisper: 0.00, emberThief: 0.20,
      nightRaid: 0.00, sadMemory: 0.50, outsidePlea: 0.30, toxicFog: 0.00,
      vaultSong: 0.00, ashFlare: 0.00, suddenDeathDoor: 0.00,
    ),
    // 🟠 Dark – Bóng đè
    // [40%] Ác Mộng Từ Vực Thẳm  | [35%] Cơn Bão Sương Độc  | [25%] Khúc Hát Từ Rường Cột
    BrightnessLevel.dark: _NightWeights(
      deepSleep: 0.00, nightmare: 0.40, blindWhisper: 0.00, emberThief: 0.00,
      nightRaid: 0.00, sadMemory: 0.00, outsidePlea: 0.00, toxicFog: 0.35,
      vaultSong: 0.25, ashFlare: 0.00, suddenDeathDoor: 0.00,
    ),
    // 🔴 Extinguished – Đêm kinh hoàng
    // [70%] Đột Kích Bất Ngờ  | [30%] Ranh Giới Đột Tử
    BrightnessLevel.extinguished: _NightWeights(
      deepSleep: 0.00, nightmare: 0.00, blindWhisper: 0.00, emberThief: 0.00,
      nightRaid: 0.70, sadMemory: 0.00, outsidePlea: 0.00, toxicFog: 0.00,
      vaultSong: 0.00, ashFlare: 0.00, suddenDeathDoor: 0.30,
    ),
  };

  /// Roll NightEvent dựa trên Độ Sáng hiện tại.
  static NightEvent rollNightEvent(int brightness, Random rng) {
    final w = _weights[levelOf(brightness)]!;
    final roll = rng.nextDouble();
    double c = 0;

    c += w.deepSleep;        if (roll < c) return NightEvent.deepSleep;
    c += w.nightmare;        if (roll < c) return NightEvent.nightmare;
    c += w.blindWhisper;     if (roll < c) return NightEvent.blindWhisper;
    c += w.emberThief;       if (roll < c) return NightEvent.emberThief;
    c += w.nightRaid;        if (roll < c) return NightEvent.nightRaid;
    c += w.sadMemory;        if (roll < c) return NightEvent.sadMemory;
    c += w.outsidePlea;      if (roll < c) return NightEvent.outsidePlea;
    c += w.toxicFog;         if (roll < c) return NightEvent.toxicFog;
    c += w.vaultSong;        if (roll < c) return NightEvent.vaultSong;
    c += w.ashFlare;         if (roll < c) return NightEvent.ashFlare;
    c += w.suddenDeathDoor;  if (roll < c) return NightEvent.suddenDeathDoor;
    return NightEvent.deepSleep; // fallback (không xảy ra nếu tổng xác suất = 1.0)
  }

  // ── Tiếp nhiên liệu ───────────────────────────────────────────────────────

  /// Kiểm tra đủ Tro Tàn để tiếp một lần.
  static bool canRefuel(int embers) => embers >= refuelEmberCost;

  /// Tính Độ Sáng sau khi tiếp nhiên liệu [times] lần.
  static int brightnessAfterRefuel(int current, {int times = 1}) =>
      (current + refuelBrightnessGain * times).clamp(0, 100);

  // ── Hoảng Loạn ────────────────────────────────────────────────────────────

  /// Trả về true nếu Độ Sáng đủ thấp để kích hoạt trạng thái Hoảng Loạn.
  static bool isPanicking(int brightness) => brightness < panicThreshold;

  // ── Nhãn mức sáng (dùng cho UI) ──────────────────────────────────────────

  /// Key AppStrings cho nhãn mức Độ Sáng.
  static String brightnessLabelKey(int brightness) =>
      switch (levelOf(brightness)) {
        BrightnessLevel.bright       => 'lanternBright',
        BrightnessLevel.dim          => 'lanternDim',
        BrightnessLevel.dark         => 'lanternDark',
        BrightnessLevel.extinguished => 'lanternOut',
      };
}
