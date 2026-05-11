import 'dart:math';

import 'combat_formulas.dart';
import 'inventory.dart';
import 'item.dart';
import 'lantern.dart';

// ────────────────────────────────────────────────────────────────────────────
// Sự kiện đêm khuya (Night Event)
// ────────────────────────────────────────────────────────────────────────────

enum NightEvent {
  deepSleep,        // Giấc ngủ sâu
  nightmare,        // Ác mộng từ Vực Thẳm
  blindWhisper,     // Lời thì thầm của Kẻ Mù
  emberThief,       // Kẻ trộm tro tàn
  nightRaid,        // Đột kích bất ngờ
  sadMemory,        // Hồi ức u buồn
  outsidePlea,      // Lời cầu cứu ngoài cửa
  toxicFog,         // Cơn bão sương độc
  vaultSong,        // Khúc hát từ rường cột
  ashFlare,         // Sự soi rọi của Tro tàn (Hiếm)
  suddenDeathDoor,  // Ranh giới Đột Tử – thức dậy với đúng 1 HP
}

/// Loại bài tập tập luyện tại hub.
enum TrainingType {
  strength,   // Vung vũ khí khan – Sức Mạnh
  endurance,  // Khuân vác xà gồ – Bền Bỉ (VIT)
  meditation, // Ngồi thiền trước lửa – Ý Chí (WILL)
}

/// Sự kiện ngẫu nhiên khi thực hiện bài tập Vung Vũ Khí Khan.
/// Xác suất: 35 / 12 / 12 / 10 / 8 / 8 / 5 / 5 / 5 %.
enum StrengthTrainingEvent {
  normal,          // 35% – Bình thường
  physicalInjury,  // 12% – Chấn thương thể xác
  psychTrauma,     // 12% – Tổn thương tâm lý
  weaponAccident,  // 10% – Tai nạn vũ khí
  breakthrough,    //  8% – Giác ngộ (Đột phá)
  accidentalFind,  //  8% – Vô tình khám phá
  abyssCall,       //  5% – Tiếng gọi Vực thẳm
  exhaustion,      //  5% – Vắt kiệt sinh mệnh
  dangerAttracted, //  5% – Thu hút hiểm nguy
}

/// Sự kiện ngẫu nhiên khi thực hiện bài tập Khuân Vác Xà Gồ.
/// Xác suất: 25 / 12 / 10 / 10 / 15 / 12 / 7 / 5 / 4 %.
enum EnduranceTrainingEvent {
  normal,              // 25% – Bình thường
  spinalInjury,        // 12% – Chấn thương cột sống
  hiddenHazard,        // 10% – Hiểm họa ẩn giấu
  psychologicalWeight, // 10% – Sức nặng tâm lý
  ironWill,            // 15% – Ý chí sắt đá
  forgottenCave,       // 12% – Hốc đất lãng quên
  bloodInRock,         //  7% – Hòa huyết vào đá
  crushed,             //  5% – Bị nghiền nát
  collapseSound,       //  4% – Âm thanh sụp đổ
}

/// Sự kiện ngẫu nhiên khi thực hiện bài tập Ngồi Thiền Trước Lửa.
/// Xác suất: 35 / 12 / 12 / 10 / 8 / 8 / 5 / 5 / 5 %.
enum MeditationTrainingEvent {
  normal,             // 35% – Tâm trí tĩnh lặng
  psychHallucination, // 12% – Ảo ảnh trong tro tàn
  burnInjury,         // 12% – Hơi nóng phỏng da
  lanternFlicker,     // 10% – Bóng tối chực chờ
  enlightenment,      //  8% – Tâm như minh cảnh
  ancientScript,      //  8% – Cổ ngữ trong ngọn lửa
  abyssCall,          //  5% – Lời thì thầm của Cổ Thần
  soulWander,         //  5% – Lạc bước cõi âm
  shadowBetrayal,     //  5% – Cái bóng phản bội
}

/// Kết quả sau một lần Nghỉ Ngơi.
class RestResult {
  final NightEvent event;
  final int newDay;

  // Thay đổi chỉ số cơ bản
  final int hpHealed;
  final int sanityChange;
  final int hungerLost;

  // Hậu quả sinh tồn
  final bool starvationDamage;
  final int starvationHpLost;
  final int embersLost;
  final Item? foodStolen;
  final bool nightRaidHalfStamina;
  final int lanternCost;

  /// Lời thì thầm của Kẻ Mù: tăng tỷ lệ sự kiện khám phá ngày hôm sau.
  final bool blindWhisperBonus;

  /// Đột kích ban đêm: cần chuyển sang màn hình combat ngay.
  final bool navigateToCombat;

  // ── Sự kiện mới ──────────────────────────────────────────────────────────

  /// Hồi ức u buồn / Lời cầu cứu: thay đổi Nhân Tính (dương = tăng, âm = giảm).
  final int humanityChange;

  /// Hồi ức u buồn: Thể lực bị trừ thêm vào sáng hôm sau (đã áp dụng).
  final int bonusStaminaLoss;

  /// Lời cầu cứu ngoài cửa: vật phẩm nhặt được khi lục lọi xác.
  final Item? outsidePleaItem;

  /// Cơn bão sương độc: kích hoạt trạng thái [Tức Ngực] (Stamina chỉ 50%, +5 mỗi hành động hôm sau).
  final bool toxicFogActive;

  /// Khúc hát từ rường cột: HP được hồi thêm ngoài mức cơ bản (+10% maxHp).
  final int vaultSongExtraHp;

  /// Khúc hát từ rường cột: Lồng Đèn bị trừ thêm ngoài chi phí nghỉ thường.
  final int vaultSongExtraLanternCost;

  /// Sự soi rọi của Tro tàn: không mất Độ Sáng, Sanity hồi 100%, [Được Che Chở].
  final bool ashFlareActive;

  /// Kẻ trộm tro tàn: số % Độ Sáng bị đánh cắp (0 nếu bị ăn trộm đồ thay).
  final int emberThiefBrightnessLost;

  /// Ác mộng: debuff [Tim Đập Mạnh] kích hoạt – hành động tốn gấp đôi Thể Lực hôm nay.
  final bool racingHeartActive;

  /// Đột kích bất ngờ: debuff [Ngái Ngủ] kích hoạt – kẻ thù đánh lượt đầu trong trận chiến.
  final bool sleepyActive;

  /// Ranh giới đột tử: debuff [Sợ Hãi] kích hoạt – kỹ năng đặc biệt bị khóa trong chiến đấu.
  final bool fearActive;

  /// Mức Độ Sáng của lồng đèn tại thời điểm ngủ (sau khi trừ chi phí nghỉ).
  /// Dùng để hiển thị đúng thể lực hồi phục trên UI.
  final BrightnessLevel brightnessAtRest;

  /// Thể lực trước khi nghỉ – dùng để tính delta hiển thị trên UI.
  final int staminaBefore;

  const RestResult({
    required this.event,
    required this.newDay,
    required this.hpHealed,
    required this.sanityChange,
    required this.hungerLost,
    this.starvationDamage = false,
    this.starvationHpLost = 0,
    this.embersLost = 0,
    this.foodStolen,
    this.nightRaidHalfStamina = false,
    this.lanternCost = 0,
    this.blindWhisperBonus = false,
    this.navigateToCombat = false,
    this.humanityChange = 0,
    this.bonusStaminaLoss = 0,
    this.outsidePleaItem,
    this.toxicFogActive = false,
    this.vaultSongExtraHp = 0,
    this.vaultSongExtraLanternCost = 0,
    this.ashFlareActive = false,
    this.emberThiefBrightnessLost = 0,
    this.racingHeartActive = false,
    this.sleepyActive = false,
    this.fearActive = false,
    required this.brightnessAtRest,
    required this.staminaBefore,
  });
}

/// Kết quả sau một lần Tập Luyện.
class TrainingResult {
  final TrainingType type;

  /// false = không đủ Thể Lực hoặc Độ No để thực hiện.
  final bool success;

  final int staminaCost;
  final int hungerCost;

  /// Giá trị chỉ số trước khi tập.
  final int statBefore;

  /// Giá trị chỉ số sau khi tập (tăng 1 nếu [leveledUp]).
  final int statAfter;

  /// EXP trước khi nhận phần thưởng.
  final double expBefore;

  /// EXP sau khi nhận phần thưởng (phần dư nếu lên cấp, giữ nguyên nếu chưa).
  final double expAfter;

  /// EXP thực sự nhận được lần này (0 / 0.5 / 1.0 / 1.5 / 3.0 / 5.0...).
  final double expGain;

  /// EXP cần để lên cấp tiếp theo (0.0 = đã đạt tối đa).
  final double expNeeded;

  /// Chỉ số có tăng lên trong lần tập này không.
  final bool leveledUp;

  // ── Sự kiện Vung Vũ Khí Khan ─────────────────────────────────────────────

  /// Sự kiện ngẫu nhiên xảy ra (null với các loại tập khác).
  final StrengthTrainingEvent? strengthEvent;

  /// Thay đổi HP do sự kiện tập luyện (0 hoặc âm).
  final int hpChange;

  /// Thay đổi Độ Tỉnh Táo do sự kiện.
  final int sanityTrainChange;

  /// Thay đổi Nhân Tính do sự kiện (chỉ Tiếng gọi Vực thẳm).
  final int humanityTrainChange;

  /// Vật phẩm rơi ra khi Vô tình khám phá.
  final Item? itemDropped;

  /// Trạng thái [Chảy Máu] vừa được kích hoạt (2 HP/lượt × 3 lượt combat).
  final bool bleedActive;

  /// Thể lực vừa bị cạn về 0 (Vắt kiệt sinh mệnh).
  final bool staminaDrained;

  /// Sự kiện buộc vào combat ngay lập tức (Thu hút hiểm nguy).
  final bool navigateToCombat;

  // ── EXP Nhanh Nhẹn (chỉ strength training) ──────────────────────────────

  /// EXP nhận được cho Nhanh Nhẹn lần này.
  final double agiExpGain;

  /// AGI trước khi tập.
  final int agiStatBefore;

  /// AGI sau khi tập.
  final int agiStatAfter;

  /// agiExp trước khi nhận phần thưởng.
  final double agiExpBefore;

  /// agiExp sau khi nhận phần thưởng.
  final double agiExpAfter;

  /// EXP cần để nâng AGI tiếp theo.
  final double agiExpNeeded;

  /// AGI có tăng lên trong lần tập này không.
  final bool agiLeveledUp;

  // ── Sự kiện Khuân Vác Xà Gồ ────────────────────────────────────────────

  /// Sự kiện ngẫu nhiên của Khuân Vác Xà Gồ (null với các loại tập khác).
  final EnduranceTrainingEvent? enduranceEvent;

  /// EXP nhận được cho Phòng Thủ (nhánh DEF) lần này.
  final double defExpGain;

  /// bonusDefense trước khi tập.
  final int defStatBefore;

  /// bonusDefense sau khi tập.
  final int defStatAfter;

  /// defExp trước khi nhận phần thưởng.
  final double defExpBefore;

  /// defExp sau khi nhận phần thưởng.
  final double defExpAfter;

  /// EXP cần để nâng DEF tiếp theo.
  final double defExpNeeded;

  /// DEF có tăng lên trong lần tập này không.
  final bool defLeveledUp;

  /// Thể lực được hồi từ sự kiện (Ý chí sắt đá +15).
  final int staminaGainFromEvent;

  /// [Trật Khớp] vừa kích hoạt trong lần tập này.
  final bool dislocatedActive;

  /// [Nhiễm Trùng] vừa kích hoạt trong lần tập này.
  final bool infectionActive;

  // ── Sự kiện Ngồi Thiền Trước Lửa ─────────────────────────────────────────

  /// Sự kiện ngẫu nhiên của Ngồi Thiền (null với các loại tập khác).
  final MeditationTrainingEvent? meditationEvent;

  /// Nhánh thiền được chọn ngẫu nhiên (1 = Mở rộng, 2 = Xoa dịu, 3 = Cân Bằng).
  final int meditationBranch;

  /// Sanity hồi thêm từ Nhánh 2/3 (Xoa dịu Tâm Trí / Cân Bằng).
  final int sanityHealFromBranch;

  /// Max Sanity tăng thêm khi Ý Chí lên cấp qua Nhánh 1/3.
  final int maxSanityIncrease;

  /// [Bỏng Nhẹ] vừa kích hoạt (1 HP/lượt combat × 3 ngày).
  final bool burnActive;

  /// Lồng Đèn mất thêm do sự kiện Bóng Tối Chực Chờ.
  final int lanternLossFromEvent;

  const TrainingResult({
    required this.type,
    required this.success,
    this.staminaCost = 0,
    this.hungerCost = 0,
    this.statBefore = 0,
    this.statAfter = 0,
    this.expBefore = 0.0,
    this.expAfter = 0.0,
    this.expGain = 0.0,
    this.expNeeded = 1.0,
    this.leveledUp = false,
    this.strengthEvent,
    this.hpChange = 0,
    this.sanityTrainChange = 0,
    this.humanityTrainChange = 0,
    this.itemDropped,
    this.bleedActive = false,
    this.staminaDrained = false,
    this.navigateToCombat = false,
    this.agiExpGain = 0.0,
    this.agiStatBefore = 0,
    this.agiStatAfter = 0,
    this.agiExpBefore = 0.0,
    this.agiExpAfter = 0.0,
    this.agiExpNeeded = 1.0,
    this.agiLeveledUp = false,
    this.enduranceEvent,
    this.defExpGain = 0.0,
    this.defStatBefore = 0,
    this.defStatAfter = 0,
    this.defExpBefore = 0.0,
    this.defExpAfter = 0.0,
    this.defExpNeeded = 1.0,
    this.defLeveledUp = false,
    this.staminaGainFromEvent = 0,
    this.dislocatedActive = false,
    this.infectionActive = false,
    this.meditationEvent,
    this.meditationBranch = 0,
    this.sanityHealFromBranch = 0,
    this.maxSanityIncrease = 0,
    this.burnActive = false,
    this.lanternLossFromEvent = 0,
  });
}

/// Giá trị mặc định và ngưỡng game cho một [Character] mới.
/// Tập trung tại đây để dễ cân bằng số liệu mà không cần sửa logic.
class CharacterDefaults {
  CharacterDefaults._();

  // ── Trạng Thái Sinh Tồn ──────────────────────────────────────────────────
  static const int hp = 50;
  static const int stamina = 50;
  static const int hunger = 100;

  // ── Chỉ Số Chiến Đấu ────────────────────────────────────────────────────
  static const int str = 5;
  static const int vit = 5;
  static const int agi = 5;

  /// Ý Chí – ảnh hưởng đến Thể Lực tối đa và kháng hiệu ứng xấu.
  static const int will = 5;

  // ── Thuộc Tính Ẩn ────────────────────────────────────────────────────────
  static const int humanity = 50;
  static const int sanity = 100;
  static const int embers = 0;

  /// Cảnh Giới ban đầu (Cấp 1 – Kẻ Nhặt Rác).
  static const int realm = 1;

  // ── Giới hạn & EXP Chỉ Số Chiến Đấu ──────────────────────────────────────
  /// Cấp tối đa của mỗi chỉ số chiến đấu (str / vit / agi / will).
  static const int maxStatLevel = 100;

  // ── Ngưỡng ───────────────────────────────────────────────────────────────
  /// Độ No dưới mức này sẽ gây tụt Máu mỗi ngày.
  static const int hungerDangerThreshold = 20;

  /// Lượng Độ No mất đi mỗi ngày trong game.
  static const int hungerDailyLoss = 10;

  /// Lượng Máu mất mỗi ngày khi đang đói.
  static const int starvationDamagePerDay = 5;

  /// Độ Tỉnh Táo dưới mức này sẽ gây debuff ảo giác trong chiến đấu.
  static const int sanityHallucinationThreshold = 30;

  /// Lượng Máu tối đa tăng thêm mỗi điểm VIT khi nâng cấp Thể Chất.
  static const int hpPerVitPoint = 5;
}

/// Nhân vật người chơi trong *One Hundred Sunless Days*.
///
/// Mọi thay đổi chỉ số đều được đóng gói trong các method để phần còn lại
/// của codebase không cần tự clamp hay rẽ nhánh trực tiếp trên giá trị thô.
class Character {
  // ── Trạng Thái Sinh Tồn ──────────────────────────────────────────────────

  /// Máu hiện tại.
  int hp;

  /// Máu tối đa (tăng theo VIT).
  int maxHp;

  /// Thể lực hiện tại.
  int stamina;

  /// Thể lực tối đa.
  int maxStamina;

  /// Độ No hiện tại.
  int hunger;

  /// Độ No tối đa.
  int maxHunger;

  // ── Chỉ Số Chiến Đấu ────────────────────────────────────────────────────

  /// Sức Mạnh – quyết định sát thương vật lý.
  int str;

  /// Bền Bỉ – quyết định Máu tối đa.
  int vit;

  /// Nhanh Nhẹn – quyết định thứ tự lượt đánh và tỉ lệ né tránh.
  int agi;

  /// Ý Chí – quyết định Thể Lực tối đa và kháng hiệu ứng xấu.
  int will;

  /// Bonus Phòng Thủ tổng cộng từ trang bị + kỹ năng + cảnh giới.
  /// Không bao giờ tăng qua nâng cấp chỉ số thông thường.
  /// Tầng game-rule chịu trách nhiệm cộng/trừ khi thay trang bị hoặc lên cảnh giới.
  int bonusDefense;

  // ── Thuộc Tính Ẩn ────────────────────────────────────────────────────────

  /// Nhân Tính (0–100). Khởi đầu ở 50.
  /// Quyết định nhánh cốt truyện cuối game.
  int humanity;

  /// Độ Tỉnh Táo (0–100). Khởi đầu ở 100.
  /// Quá thấp sẽ gây debuff ảo giác trong chiến đấu.
  int sanity;

  /// Tro Tàn – tiền tệ và kinh nghiệm duy nhất của game.
  /// Rớt ra khi chết và dùng để nâng cấp chỉ số chiến đấu.
  int embers;

  /// Cảnh Giới – phản ánh mức độ giác ngộ và sức mạnh tiềm ẩn.
  /// Cấp 1: Kẻ Nhặt Rác → tăng qua các sự kiện đặc biệt.
  int realm;

  /// Balo – quản lý toàn bộ vật phẩm mang theo.
  final Inventory inventory;

  /// Ngày hiện tại trong hành trình (bắt đầu từ 1).
  int currentDay;

  /// Độ bền Lồng Đèn (0–100). Giảm 5 mỗi lần ngủ.
  int lanternDurability;

  /// Bonus khám phá từ sự kiện "Tiếng Thì Thầm của Kẻ Mù".
  /// Tăng tỷ lệ sự kiện "Vô tình khám phá" thêm 20% cho lần khám phá tiếp theo.
  /// Tự động xóa sau khi dùng.
  bool blindWhisperBonusActive;

  /// [Tức Ngực] từ "Cơn Bão Sương Độc".
  /// Mọi hành động tốn Thể Lực hôm đó tốn thêm +5. Xóa khi bắt đầu ngày mới.
  bool toxicFogActive;

  /// [Được Che Chở] từ "Sự Soi Rọi của Tro Tàn".
  /// Miễn nhiễm sát thương tâm lý trong lần Khám Phá đầu tiên hôm đó. Xóa sau khi dùng.
  bool ashFlareProtection;

  /// Tỷ lệ gặp quái 80% từ "Kẻ Dòm Ngó Vô Hình".
  /// Kẻ đứng nhìn bạn ngủ vẫn đang rình rập quanh Nhà Thờ. Xóa khi bắt đầu ngày mới.
  bool invisibleWatcherActive;

  /// [Tim Đập Mạnh] từ "Ác Mộng Từ Vực Thẳm".
  /// Mọi hành động tiêu hao Thể Lực khi Khám Phá và Tập Luyện đều tốn gấp đôi. Xóa khi bắt đầu ngày mới.
  bool racingHeartActive;

  /// [Ngái Ngủ] từ "Đột Kích Bất Ngờ".
  /// Kẻ thù luôn đánh lượt đầu tiên trong trận chiến đó. Xóa khi bắt đầu ngày mới.
  bool sleepyActive;

  /// [Sợ Hãi] từ "Ranh Giới Đột Tử".
  /// Khóa toàn bộ kỹ năng đặc biệt trong chiến đấu. Xóa khi bắt đầu ngày mới.
  bool fearActive;

  // ── Kinh Nghiệm Chỉ Số ──────────────────────────────────────────────────

  /// EXP tích lũy cho Sức Mạnh.
  /// Dùng double vì sự kiện ngẫu nhiên có thể trao 0.5 hoặc 1.5 EXP.
  double strExp;

  /// EXP tích lũy cho Nhanh Nhẹn.
  double agiExp;

  /// EXP tích lũy cho Bền Bỉ.
  double vitExp;

  /// EXP tích lũy cho Ý Chí.
  double willExp;

  /// Số lượt trạng thái [Chảy Máu] còn lại trong combat. 0 = không chảy máu.
  int bleedTurnsRemaining;

  /// Sát thương HP/lượt khi đang [Chảy Máu].
  int bleedDamagePerTurn;

  /// EXP tích lũy cho Phòng Thủ (khuân vác xà gồ – nhánh DEF).
  double defExp;

  /// [Trật Khớp] đang hoạt động – giảm né tránh và tốc độ trong ngày.
  bool dislocatedActive;

  /// [Nhiễm Trùng] đang hoạt động – mất thêm HP mỗi ngày.
  bool infectionActive;

  /// Max Sanity – mặc định 100, có thể tăng theo Ý Chí qua Thiền Định Nhánh 1/3.
  int maxSanity;

  /// Số ngày còn lại của trạng thái [Bỏng Nhẹ] trong combat.
  int burnTurnsRemaining;

  /// Sát thương HP/lượt khi đang [Bỏng Nhẹ].
  int burnDamagePerTurn;

  /// Số lượt [Nhiễm Độc] còn lại. 0 = không nhiễm độc.
  int poisonedTurnsRemaining;

  /// Số lượt [Cuồng Huyết] còn lại. 0 = không có buff.
  int bloodlustTurnsRemaining;

  // ── Trang Bị Hiện Tại ────────────────────────────────────────────────────

  /// Vũ khí đang trang bị (null = không trang bị).
  Item? equippedWeapon;

  /// Áo giáp đang trang bị (null = không trang bị).
  Item? equippedArmor;

  // ── Hàm Khởi Tạo ────────────────────────────────────────────────────────

  Character({
    this.hp = CharacterDefaults.hp,
    int? maxHp,
    this.stamina = CharacterDefaults.stamina,
    int? maxStamina,
    this.hunger = CharacterDefaults.hunger,
    int? maxHunger,
    this.str = CharacterDefaults.str,
    this.vit = CharacterDefaults.vit,
    this.agi = CharacterDefaults.agi,
    this.will = CharacterDefaults.will,
    this.bonusDefense = 0,
    this.humanity = CharacterDefaults.humanity,
    this.sanity = CharacterDefaults.sanity,
    this.embers = CharacterDefaults.embers,
    this.realm = CharacterDefaults.realm,
    Inventory? inventory,
    this.currentDay = 1,
    this.lanternDurability = 100,
    this.blindWhisperBonusActive = false,
    this.toxicFogActive = false,
    this.ashFlareProtection = false,
    this.invisibleWatcherActive = false,
    this.racingHeartActive = false,
    this.sleepyActive = false,
    this.fearActive = false,
    this.strExp = 0.0,
    this.agiExp = 0.0,
    this.vitExp = 0.0,
    this.willExp = 0.0,
    this.bleedTurnsRemaining = 0,
    this.bleedDamagePerTurn = 0,
    this.defExp = 0.0,
    this.dislocatedActive = false,
    this.infectionActive = false,
    this.maxSanity = CharacterDefaults.sanity,
    this.burnTurnsRemaining = 0,
    this.burnDamagePerTurn = 0,
    this.poisonedTurnsRemaining = 0,
    this.bloodlustTurnsRemaining = 0,
    this.equippedWeapon,
    this.equippedArmor,
  })  : maxHp = maxHp ?? CharacterDefaults.hp,
        maxStamina = maxStamina ?? CharacterDefaults.stamina,
        maxHunger = maxHunger ?? CharacterDefaults.hunger,
        inventory = inventory ?? _defaultInventory();

  /// Balo khởi điểm: chỉ có Lồng Đèn Xương (độc nhất).
  static Inventory _defaultInventory() {
    final inv = Inventory();
    inv.add(ItemRegistry.boneLantern);
    return inv;
  }

  // ── Trạng Thái Tính Toán ─────────────────────────────────────────────────

  /// Trả về true khi Máu về 0.
  bool get isDead => hp <= 0;

  /// Trả về true khi Độ No xuống dưới ngưỡng nguy hiểm.
  bool get isStarving =>
      hunger < CharacterDefaults.hungerDangerThreshold;

  /// Trả về true khi Độ Tỉnh Táo đủ thấp để gây debuff ảo giác.
  bool get isHallucinating =>
      sanity < CharacterDefaults.sanityHallucinationThreshold;

  /// Trả về true khi Độ Sáng dưới ngưỡng Hoảng Loạn (đang khám phá).
  bool get isPanicking => LanternSystem.isPanicking(lanternDurability);

  /// Tổng sức tấn công, tùy chọn cộng thêm bonus từ vũ khí.
  /// Công thức: STR + weaponBonus
  int attackPower({int weaponBonus = 0}) => str + weaponBonus;

  /// Tổng tấn công bao gồm vũ khí đang trang bị.
  int get totalAttack => str + (equippedWeapon?.atkBonus ?? 0);

  /// Phòng Thủ hiện tại – chỉ đến từ trang bị, kỹ năng và cảnh giới cao hơn.
  /// Không thể nâng qua điểm chỉ số thông thường.
  int get defense => bonusDefense;

  /// Tổng phòng thủ khi tính thêm bonus tức thời từ trang bị (dùng trong combat).
  int defensePower({int armorBonus = 0}) => bonusDefense + armorBonus;

  /// Tổng phòng thủ bao gồm áo giáp đang trang bị.
  int get totalDefense => bonusDefense + (equippedArmor?.defBonus ?? 0);

  /// Trả về true nếu nhân vật này đánh trước so với [enemyAgi] trong lượt này.
  /// Ngang điểm thì người chơi được ưu tiên.
  bool goesFirst(int enemyAgi) => agi >= enemyAgi;

  /// Xác suất bỏ chạy thành công trong khoảng [0.0, 1.0].
  /// Công thức: AGI / (AGI + AGI_địch)
  double fleeChance(int enemyAgi) {
    final int total = agi + enemyAgi;
    return total == 0 ? 0.5 : agi / total;
  }

  // ── Thay Đổi Trạng Thái Sinh Tồn ─────────────────────────────────────────

  /// Giảm Máu đi [amount]. Giới hạn trong [0, maxHp].
  void takeDamage(int amount) {
    assert(amount >= 0, 'takeDamage: amount phải không âm');
    hp = (hp - amount).clamp(0, maxHp);
  }

  /// Áp dụng công thức Giáp lên [rawDamage] rồi trừ Máu.
  /// Xem [CombatFormulas.applyArmor] để biết chi tiết công thức.
  void takeDamageWithArmor(int rawDamage) {
    takeDamage(CombatFormulas.applyArmor(rawDamage, bonusDefense));
  }

  /// Hồi Máu thêm [amount]. Giới hạn trong [0, maxHp].
  void heal(int amount) {
    assert(amount >= 0, 'heal: amount phải không âm');
    hp = (hp + amount).clamp(0, maxHp);
  }

  /// Tiêu tốn [amount] Thể Lực cho một hành động. Giới hạn trong [0, maxStamina].
  void consumeStamina(int amount) {
    assert(amount >= 0, 'consumeStamina: amount phải không âm');
    stamina = (stamina - amount).clamp(0, maxStamina);
  }

  /// Hồi [amount] Thể Lực (ví dụ: sau khi nghỉ ngơi). Giới hạn trong [0, maxStamina].
  void restoreStamina(int amount) {
    assert(amount >= 0, 'restoreStamina: amount phải không âm');
    stamina = (stamina + amount).clamp(0, maxStamina);
  }

  /// Tăng Độ No thêm [amount] (ăn uống). Giới hạn trong [0, maxHunger].
  void eat(int amount) {
    assert(amount >= 0, 'eat: amount phải không âm');
    hunger = (hunger + amount).clamp(0, maxHunger);
  }

  // ── Tiến Trình Thời Gian ──────────────────────────────────────────────────

  /// Cho thế giới qua đi một ngày:
  /// - Độ No giảm theo [CharacterDefaults.hungerDailyLoss].
  /// - Nếu đang đói, Máu giảm theo [CharacterDefaults.starvationDamagePerDay].
  void passDay() {
    hunger =
        (hunger - CharacterDefaults.hungerDailyLoss).clamp(0, maxHunger);
    if (isStarving) {
      takeDamage(CharacterDefaults.starvationDamagePerDay);
    }
  }

  // ── Thay Đổi Thuộc Tính Ẩn ───────────────────────────────────────────────

  /// Thay đổi Nhân Tính theo [delta] (dương = thiện, âm = ác).
  /// Giới hạn trong [0, 100].
  void changeHumanity(int delta) {
    humanity = (humanity + delta).clamp(0, 100);
  }

  /// Thay đổi Độ Tỉnh Táo theo [delta] (dương = hồi phục, âm = suy giảm).
  /// Giới hạn trong [0, 100].
  void changeSanity(int delta) {
    sanity = (sanity + delta).clamp(0, maxSanity);
  }

  // ── Tro Tàn (Tiền Tệ / Kinh Nghiệm) ─────────────────────────────────────

  /// Thêm [amount] Tro Tàn vào túi (ví dụ: sau khi giết quái).
  void gainEmbers(int amount) {
    assert(amount >= 0, 'gainEmbers: amount phải không âm');
    embers += amount;
  }

  /// Tiêu [amount] Tro Tàn.
  /// Trả về `true` nếu thành công, `false` nếu không đủ Tro Tàn.
  bool spendEmbers(int amount) {
    assert(amount >= 0, 'spendEmbers: amount phải không âm');
    if (embers < amount) return false;
    embers -= amount;
    return true;
  }

  // ── Nâng Cấp Chỉ Số ──────────────────────────────────────────────────────
  // Gọi [spendEmbers] riêng trước khi gọi các method này; logic chi phí nâng cấp
  // thuộc về tầng game-rule, không nằm ở đây.

  /// Tăng Sức Mạnh thêm 1.
  void upgradeStr() => str++;

  /// Tăng Thể Chất thêm 1 và mở rộng Máu tối đa tương ứng.
  void upgradeVit() {
    vit++;
    maxHp += CharacterDefaults.hpPerVitPoint;
    hp += CharacterDefaults.hpPerVitPoint; // Máu tối đa mới có hiệu lực ngay lập tức
  }

  /// Tăng Nhanh Nhẹn thêm 1.
  void upgradeAgi() => agi++;

  /// Tăng Ý Chí thêm 1 và mở rộng Thể Lực tối đa tương ứng.
  void upgradeWill() {
    will++;
    maxStamina += 5;
    stamina += 5;
  }

  // ── Nghỉ Ngơi ────────────────────────────────────────────────────────────

  /// Nhân vật ngủ qua đêm.
  /// Sử dụng [LanternSystem] để xác định chất lượng giấc ngủ.
  /// Áp dụng toàn bộ hiệu ứng nghỉ ngơi và trả về [RestResult].
  RestResult rest() {
    final rng = Random();

    // ── 1. Đèn tiêu thụ khi ngủ ──────────────────────────────────────────
    lanternDurability =
        (lanternDurability - LanternSystem.restCost).clamp(0, 100);

    // ── 2. Xác định sự kiện đêm theo Độ Sáng ─────────────────────────────
    final NightEvent event =
        LanternSystem.rollNightEvent(lanternDurability, rng);

    // ── 3. Hồi Thể Lực ───────────────────────────────────────────────────
    // Tỷ lệ hồi cơ bản theo Độ Sáng: bright=100%, dim=75%, dark=50%.
    // Extinguished: không hồi theo tỷ lệ, chỉ +10 Thể Lực.
    final BrightnessLevel brightnessLevel = LanternSystem.levelOf(lanternDurability);
    final int staminaBefore = stamina; // lưu trước khi hồi
    if (brightnessLevel == BrightnessLevel.extinguished) {
      stamina = (stamina + 10).clamp(0, maxStamina);
    } else {
      final double baseStaminaPct = switch (brightnessLevel) {
        BrightnessLevel.bright       => 1.00,
        BrightnessLevel.dim          => 0.75,
        BrightnessLevel.dark         => 0.50,
        BrightnessLevel.extinguished => 1.00, // unreachable
      };
      // nightRaid và toxicFog chỉ hồi 50%, bất kể Độ Sáng.
      if (event == NightEvent.nightRaid || event == NightEvent.toxicFog) {
        stamina = (maxStamina * 0.5).round();
      } else {
        // Hồi lên đến mức baseStaminaPct, nhưng không bao giờ trừ stamina hiện có.
        final int target = (maxStamina * baseStaminaPct).round();
        stamina = stamina > target ? stamina : target;
      }
    }
    const int bonusStaminaLoss = 0;

    // ── 4. Hồi Máu theo bảng Độ Sáng ─────────────────────────────────────
    // vaultSong (bright/dim): hồi thêm +10% maxHp (ngủ quá say, ngon giấc).
    // vaultSong (dark): hút cạn sức sống → mất 15% HP thay vì hồi.
    final bool vaultSongDarkDrain =
        event == NightEvent.vaultSong && brightnessLevel == BrightnessLevel.dark;
    final double baseHealPct = LanternSystem.sleepHpHealPercent(lanternDurability);
    final double vaultBonus =
        (event == NightEvent.vaultSong && !vaultSongDarkDrain) ? 0.10 : 0.0;
    final double totalHealPct =
        vaultSongDarkDrain ? -0.15 : (baseHealPct + vaultBonus);
    final int vaultSongExtraHp = vaultSongDarkDrain
        ? -(maxHp * 0.15).round()
        : (maxHp * vaultBonus).round();

    final int hpHealed;
    if (totalHealPct >= 0) {
      hpHealed = (maxHp * totalHealPct).round();
      heal(hpHealed);
    } else {
      hpHealed = (maxHp * totalHealPct).round(); // số âm
      takeDamage(-hpHealed);
    }

    // ── 5. Sanity theo bảng Độ Sáng + hiệu chỉnh sự kiện ─────────────────
    final int sanityBefore = sanity;
    int sanityChange = LanternSystem.sleepSanityChange(lanternDurability);
    switch (event) {
      case NightEvent.nightmare:
        sanityChange -= 15;
      case NightEvent.nightRaid:
        sanityChange = 0;
      case NightEvent.sadMemory:
        sanityChange -= 10; // nỗi đau dằn vặt khi nhớ lại thế giới cũ
      default:
        break;
    }
    changeSanity(sanityChange);

    // ashFlare: khôi phục Sanity về 100% (sau khi đã apply base change)
    if (event == NightEvent.ashFlare) {
      sanity = 100;
      sanityChange = sanity - sanityBefore; // delta thực tế cho UI
    }

    // ── 6. Độ No giảm ────────────────────────────────────────────────────
    const int hungerLost = 20;
    hunger = (hunger - hungerLost).clamp(0, maxHunger);
    bool starvationDamage = false;
    int starvationHpLost = 0;
    if (hunger <= 0) {
      starvationHpLost = (maxHp * 0.20).round().clamp(1, maxHp);
      takeDamage(starvationHpLost);
      starvationDamage = true;
    }

    // ── 7. Hiệu ứng sự kiện đêm ──────────────────────────────────────────
    int    embersLost            = 0;
    Item?  foodStolen;
    bool   blindWhisperBonus     = false;
    bool   navigateToCombat      = false;
    int    humanityChange        = 0;
    Item?  outsidePleaItem;
    bool   toxicFogResult        = false;
    int    vaultSongExtraLantern = 0;
    bool   ashFlareResult        = false;
    int    emberThiefBrightnessLost = 0;
    bool   racingHeartResult      = false;
    bool   sleepyResult           = false;
    bool   fearResult             = false;

    switch (event) {
      case NightEvent.blindWhisper:
        // Buff [Khám Phá Ngày Mai]: tăng tỷ lệ nhặt nguyên liệu tốt hôm sau.
        blindWhisperBonusActive = true;
        blindWhisperBonus = true;

      case NightEvent.emberThief:
        // 50% ăn trộm 1 vật phẩm tiêu hao (Lương Thực hoặc Y Tế)
        // 50% đánh cắp 10% Độ Sáng Lồng Đèn
        if (rng.nextBool()) {
          final stealableEntries = inventory.consumables
              .where((e) => e.item.group == ItemGroup.food || e.item.group == ItemGroup.medical)
              .toList();
          if (stealableEntries.isNotEmpty) {
            foodStolen = stealableEntries[rng.nextInt(stealableEntries.length)].item;
            inventory.remove(foodStolen!.id);
          } else {
            // Không có đồ → đánh cắp Độ Sáng thay
            emberThiefBrightnessLost = (lanternDurability * 0.10).round();
            lanternDurability = (lanternDurability - emberThiefBrightnessLost).clamp(0, 100);
          }
        } else {
          emberThiefBrightnessLost = (lanternDurability * 0.10).round();
          lanternDurability = (lanternDurability - emberThiefBrightnessLost).clamp(0, 100);
        }

      case NightEvent.nightmare:
        // Debuff [Tim Đập Mạnh]: Khám Phá và Tập Luyện tốn gấp đôi Thể Lực.
        racingHeartActive = true;
        racingHeartResult = true;

      case NightEvent.nightRaid:
        navigateToCombat = true;
        // Extinguished: debuff [Ngái Ngủ] – kẻ thù luôn đánh lượt đầu trong trận chiến.
        if (brightnessLevel == BrightnessLevel.extinguished) {
          sleepyActive = true;
          sleepyResult = true;
        }

      case NightEvent.suddenDeathDoor:
        // HP về đúng 1. Áp dụng trực tiếp thay vì qua heal/takeDamage.
        hp = 1;
        // Debuff [Sợ Hãi]: khóa toàn bộ kỹ năng đặc biệt trong chiến đấu.
        fearActive = true;
        fearResult = true;

      case NightEvent.sadMemory:
        // +2 Nhân Tính (hồi ức ấm áp) nhưng -10 Tỉnh Táo (nỗi đau dằn vặt).
        humanityChange = 2;
        changeHumanity(2);

      case NightEvent.outsidePlea:
        // Sub-roll: 50% không mở cửa | 25% mở → bị trộm đồ ăn | 25% mở → bị tấn công
        final double pleaRoll = rng.nextDouble();
        if (pleaRoll < 0.50) {
          // Không mở cửa → mất 5 Nhân Tính vì tội lỗi cắn rứt
          humanityChange = -5;
          changeHumanity(-5);
        } else if (pleaRoll < 0.75) {
          // Mở cửa → bị trộm mất 1 Lương Thực
          final foodEntries = inventory.consumables
              .where((e) => e.item.group == ItemGroup.food)
              .toList();
          if (foodEntries.isNotEmpty) {
            outsidePleaItem = foodEntries[rng.nextInt(foodEntries.length)].item;
            inventory.remove(outsidePleaItem!.id);
          }
        } else {
          // Mở cửa → bị tấn công → chuyển sang combat
          navigateToCombat = true;
        }

      case NightEvent.toxicFog:
        toxicFogActive = true;  // [Tức Ngực] kéo dài sang ngày hôm sau
        toxicFogResult = true;

      case NightEvent.vaultSong:
        if (brightnessLevel == BrightnessLevel.dark) {
          // Hút cạn sức sống: đèn tụt về 0 hoàn toàn.
          vaultSongExtraLantern = lanternDurability;
          lanternDurability = 0;
        } else {
          // Quên canh lửa: đèn bị trừ thêm 15.
          vaultSongExtraLantern = 15;
          lanternDurability = (lanternDurability - vaultSongExtraLantern).clamp(0, 100);
        }

      case NightEvent.ashFlare:
        // Không bị trừ Độ Sáng đêm nay.
        lanternDurability = (lanternDurability + LanternSystem.restCost).clamp(0, 100);
        // Hồi ĐầY Độ Tỉnh Táo + buff [Được Che Chở] miễn nhiễm debuff cả ngày.
        ashFlareProtection = true;
        ashFlareResult = true;

      default:
        break;
    }

    // ── 8. Xóa trạng thái cũ từ ngày trước ───────────────────────────────
    // (toxicFog mới vừa được set lại ở trên nếu cần)
    if (event != NightEvent.toxicFog) toxicFogActive = false;
    if (event != NightEvent.nightmare) racingHeartActive = false;
    if (event != NightEvent.nightRaid) sleepyActive = false;
    if (event != NightEvent.suddenDeathDoor) fearActive = false;

    // ── 9. Qua ngày mới ───────────────────────────────────────────────────
    currentDay++;

    return RestResult(
      event:                   event,
      newDay:                  currentDay,
      hpHealed:                hpHealed,
      sanityChange:            sanityChange,
      hungerLost:              hungerLost,
      starvationDamage:        starvationDamage,
      starvationHpLost:        starvationHpLost,
      embersLost:              embersLost,
      foodStolen:              foodStolen,
      nightRaidHalfStamina:    event == NightEvent.nightRaid,
      lanternCost:             ashFlareResult
                                   ? 0
                                   : LanternSystem.restCost,
      blindWhisperBonus:       blindWhisperBonus,
      navigateToCombat:        navigateToCombat,
      humanityChange:          humanityChange,
      bonusStaminaLoss:        bonusStaminaLoss,
      outsidePleaItem:         outsidePleaItem,
      toxicFogActive:          toxicFogResult,
      vaultSongExtraHp:        vaultSongExtraHp,
      vaultSongExtraLanternCost: vaultSongExtraLantern,
      ashFlareActive:          ashFlareResult,
      emberThiefBrightnessLost: emberThiefBrightnessLost,
      racingHeartActive:        racingHeartResult,
      sleepyActive:             sleepyResult,
      fearActive:               fearResult,
      brightnessAtRest:         brightnessLevel,
      staminaBefore:            staminaBefore,
    );
  }

  // ── Tiếp Nhiên Liệu Lồng Đèn ─────────────────────────────────────────────

  /// Tiếp nhiên liệu Lồng Đèn [times] lần.
  ///
  /// Mỗi lần tốn [LanternSystem.refuelEmberCost] Tro Tàn
  /// và hồi [LanternSystem.refuelBrightnessGain] Độ Sáng.
  ///
  /// Trả về số lần tiếp thực sự thực hiện được (bị giới hạn bởi Tro Tàn).
  int refuelLantern({int times = 1}) {
    int count = 0;
    for (int i = 0; i < times; i++) {
      if (!LanternSystem.canRefuel(embers)) break;
      embers -= LanternSystem.refuelEmberCost;
      lanternDurability =
          (lanternDurability + LanternSystem.refuelBrightnessGain).clamp(0, 100);
      count++;
    }
    return count;
  }

  // ── Chết & Hồi Sinh ──────────────────────────────────────────────────────

  /// Gọi khi [isDead] là true.
  ///
  /// - Hồi Máu và Thể Lực về tối đa (hồi sinh tại Điểm Kiểm Tra).
  /// - Xóa toàn bộ Tro Tàn (bị "rớt" tại vị trí chết).
  ///
  /// Trả về số Tro Tàn đã mất để caller tạo loot node tại vị trí cuối cùng.
  int onDeath() {
    final int droppedEmbers = embers;
    embers = 0;
    hp = maxHp;
    stamina = maxStamina;
    return droppedEmbers;
  }

  // ── Tập Luyện ────────────────────────────────────────────────────────────

  /// Số EXP cần để tăng từ [currentLevel] lên [currentLevel]+1.
  /// Level 1→2: 1.0 · Level 2→3: 1.1 · Level 3→4: 1.2 · … (mỗi cấp +0.1)
  static double expNeededToLevel(int currentLevel) {
    if (currentLevel >= CharacterDefaults.maxStatLevel) return 0;
    final double v = 1.0 + (currentLevel - 1) * 0.1;
    return double.parse(v.toStringAsFixed(1));
  }

  /// Thực hiện một buổi Tập Luyện theo [type].
  ///
  /// Tiêu hao Thể Lực và Độ No; nếu không đủ trả về [TrainingResult.success] = false.
  /// Với [TrainingType.strength], kết quả thực tế được quyết định bởi một sự kiện ngẫu nhiên.
  TrainingResult train(TrainingType type) {
    final int staminaCost = switch (type) {
      TrainingType.strength   => 15,
      TrainingType.endurance  => 20,
      TrainingType.meditation => 5,
    };
    final int hungerCost = switch (type) {
      TrainingType.strength   => 5,
      TrainingType.endurance  => 10,
      TrainingType.meditation => 5,
    };

    if (stamina < staminaCost || hunger < hungerCost) {
      return TrainingResult(type: type, success: false);
    }

    stamina = (stamina - staminaCost).clamp(0, maxStamina);
    hunger  = (hunger  - hungerCost ).clamp(0, maxHunger);

    // Meditation: sự kiện sẽ xử lý thay đổi Sanity

    // ── Sự kiện ngẫu nhiên khi Vung Vũ Khí Khan ──────────────────────────
    StrengthTrainingEvent? strengthEvent;
    double expGain            = 1.0; // Dùng cho endurance/meditation
    double strExpGain         = 0.0; // STR EXP (strength training)
    double agiExpGain         = 0.0; // AGI EXP (strength training)
    int    hpChange           = 0;
    int    sanityTrainChange  = 0;
    int    humanityTrainChange = 0;
    Item?  itemDropped;
    bool   bleedActive        = false;
    bool   staminaDrained     = false;
    bool   navigateToCombat   = false;

    if (type == TrainingType.strength) {
      // [Hiểm họa Tập luyện]: cộng bonus tai nạn từ vũ khí trong balo.
      final double weaponAccBonus = inventory.entries
          .map((e) => e.item.trainingWeaponAccidentBonus)
          .fold(0.0, (a, b) => a + b);
      final double t0 = (0.25 - weaponAccBonus).clamp(0.0, 1.0); // normal (25%)
      final double t1 = t0 + 0.12; // physicalInjury
      final double t2 = t1 + 0.12; // psychTrauma
      final double t3 = t2 + 0.10 + weaponAccBonus; // weaponAccident (luôn = 0.59)

      final rng  = Random();
      final roll = rng.nextDouble();

      // Phân bổ EXP ngẫu nhiên: 0=chỉ STR, 1=chỉ AGI, 2=cả hai

      if (roll < t0) {
        // 25% – Bình thường
        strengthEvent = StrengthTrainingEvent.normal;
        final int s = rng.nextInt(3);
        if (s == 0)      strExpGain = (rng.nextInt(2) + 1).toDouble(); // 1–2
        else if (s == 1) agiExpGain = (rng.nextInt(2) + 1).toDouble(); // 1–2
        else { strExpGain = 1.0; agiExpGain = 1.0; }
      } else if (roll < t1) {
        // 12% – Chấn thương thể xác
        strengthEvent = StrengthTrainingEvent.physicalInjury;
        hpChange  = -10;
        takeDamage(10);
        final int s = rng.nextInt(3);
        if (s == 0)      strExpGain = rng.nextBool() ? 0.5 : 1.0;
        else if (s == 1) agiExpGain = rng.nextBool() ? 0.5 : 1.0;
        else { strExpGain = 0.5; agiExpGain = 0.5; }
      } else if (roll < t2) {
        // 12% – Tổn thương tâm lý – không nhận EXP
        strengthEvent     = StrengthTrainingEvent.psychTrauma;
        sanityTrainChange = -15;
        changeSanity(-15);
      } else if (roll < t3) {
        // 10% – Tai nạn vũ khí
        strengthEvent       = StrengthTrainingEvent.weaponAccident;
        bleedActive         = true;
        bleedTurnsRemaining = 3;
        bleedDamagePerTurn  = 2;
        final int s = rng.nextInt(3);
        if (s == 0)      strExpGain = rng.nextBool() ? 0.5 : 1.0;
        else if (s == 1) agiExpGain = rng.nextBool() ? 0.5 : 1.0;
        else { strExpGain = 0.5; agiExpGain = 0.5; }
      } else if (roll < 0.74) {
        // 15% – Giác ngộ (Đột phá)
        strengthEvent = StrengthTrainingEvent.breakthrough;
        stamina       = (stamina + 10).clamp(0, maxStamina);
        final int s = rng.nextInt(3);
        if (s == 0)      strExpGain = (rng.nextInt(3) + 3).toDouble(); // 3–5
        else if (s == 1) agiExpGain = (rng.nextInt(3) + 3).toDouble(); // 3–5
        else { strExpGain = 3.0; agiExpGain = 3.0; }
      } else if (roll < 0.86) {
        // 12% – Vô tình khám phá
        strengthEvent = StrengthTrainingEvent.accidentalFind;
        final int s = rng.nextInt(3);
        if (s == 0)      strExpGain = (rng.nextInt(2) + 1).toDouble(); // 1–2
        else if (s == 1) agiExpGain = (rng.nextInt(2) + 1).toDouble(); // 1–2
        else { strExpGain = 1.0; agiExpGain = 1.0; }
      } else if (roll < 0.93) {
        // 7% – Tiếng gọi Vực thẳm
        strengthEvent       = StrengthTrainingEvent.abyssCall;
        sanityTrainChange   = -10;
        humanityTrainChange = -5;
        changeSanity(-10);
        changeHumanity(-5);
        final int s = rng.nextInt(3);
        if (s == 0)      strExpGain = 5.0;
        else if (s == 1) agiExpGain = 5.0;
        else { strExpGain = 3.0; agiExpGain = 3.0; }
      } else if (roll < 0.97) {
        // 4% – Vắt kiệt sinh mệnh
        strengthEvent  = StrengthTrainingEvent.exhaustion;
        staminaDrained = true;
        stamina        = 0;
        final int s = rng.nextInt(3);
        if (s == 0)      strExpGain = 1.5 + rng.nextInt(4) * 0.5; // 1.5–3.0
        else if (s == 1) agiExpGain = 1.5 + rng.nextInt(4) * 0.5; // 1.5–3.0
        else { strExpGain = 1.5; agiExpGain = 1.5; }
      } else {
        // 3% – Thu hút hiểm nguy – không nhận EXP
        strengthEvent    = StrengthTrainingEvent.dangerAttracted;
        navigateToCombat = true;
      }
    }

    // ── Thông tin chỉ số ──────────────────────────────────────────────────

    if (type == TrainingType.strength) {
      // ── STR ──────────────────────────────────────────────────────────────
      final int    strStatBefore = str;
      final double strExpBefore  = strExp;
      int    strStatAfter  = str;
      double strExpAfterV  = strExp;
      bool   strLeveledUp  = false;
      final double effectiveStrGain =
          str >= CharacterDefaults.maxStatLevel ? 0.0 : strExpGain;
      if (effectiveStrGain > 0) {
        double pool = strExp + effectiveStrGain;
        while (str < CharacterDefaults.maxStatLevel) {
          final double needed = expNeededToLevel(str);
          if (pool >= needed) {
            pool -= needed;
            str++;
            strLeveledUp = true;
          } else {
            break;
          }
        }
        strExp = str >= CharacterDefaults.maxStatLevel ? 0.0 : pool;
      }
      strStatAfter = str;
      strExpAfterV = strExp;

      // ── AGI ──────────────────────────────────────────────────────────────
      final int    agiStatBefore = agi;
      final double agiExpBefore  = agiExp;
      int    agiStatAfterV = agi;
      double agiExpAfterV  = agiExp;
      bool   agiLeveledUpV = false;
      final double effectiveAgiGain =
          agi >= CharacterDefaults.maxStatLevel ? 0.0 : agiExpGain;
      if (effectiveAgiGain > 0) {
        double pool = agiExp + effectiveAgiGain;
        while (agi < CharacterDefaults.maxStatLevel) {
          final double needed = expNeededToLevel(agi);
          if (pool >= needed) {
            pool -= needed;
            agi++;
            agiLeveledUpV = true;
          } else {
            break;
          }
        }
        agiExp = agi >= CharacterDefaults.maxStatLevel ? 0.0 : pool;
      }
      agiStatAfterV = agi;
      agiExpAfterV  = agiExp;

      return TrainingResult(
        type:                type,
        success:             true,
        staminaCost:         staminaCost,
        hungerCost:          hungerCost,
        statBefore:          strStatBefore,
        statAfter:           strStatAfter,
        expBefore:           strExpBefore,
        expAfter:            strExpAfterV,
        expGain:             effectiveStrGain,
        expNeeded:           expNeededToLevel(str),
        leveledUp:           strLeveledUp,
        agiExpGain:          effectiveAgiGain,
        agiStatBefore:       agiStatBefore,
        agiStatAfter:        agiStatAfterV,
        agiExpBefore:        agiExpBefore,
        agiExpAfter:         agiExpAfterV,
        agiExpNeeded:        expNeededToLevel(agi),
        agiLeveledUp:        agiLeveledUpV,
        strengthEvent:       strengthEvent,
        hpChange:            hpChange,
        sanityTrainChange:   sanityTrainChange,
        humanityTrainChange: humanityTrainChange,
        itemDropped:         itemDropped,
        bleedActive:         bleedActive,
        staminaDrained:      staminaDrained,
        navigateToCombat:    navigateToCombat,
      );
    }

    // ── Khuân Vác Xà Gồ (Endurance) ──────────────────────────────────────
    if (type == TrainingType.endurance) {
      final rng  = Random();
      final roll = rng.nextDouble();

      EnduranceTrainingEvent enduranceEvt;
      double vitExpGainE       = 0.0;
      double defExpGainE       = 0.0;
      int    hpChangeE         = 0;
      int    sanityChangeE     = 0;
      int    humanityChangeE   = 0;
      Item?  itemDroppedE;
      bool   staminaDrainedE   = false;
      bool   navigateToCombatE = false;
      int    staminaGainE      = 0;
      bool   dislocated        = false;
      bool   infected          = false;

      // Xác suất: normal 25%, spinalInjury 12%, hiddenHazard 10%,
      // psychWeight 10%, ironWill 15%, forgottenCave 12%,
      // bloodInRock 7%, crushed 5%, collapseSound 4%
      if (roll < 0.25) {
        // 25% – Bình thường
        enduranceEvt = EnduranceTrainingEvent.normal;
        final int s = rng.nextInt(3);
        if (s == 0)      defExpGainE = 1.5 + rng.nextInt(3) * 0.5; // 1.5–2.5
        else if (s == 1) vitExpGainE = 1.5 + rng.nextInt(3) * 0.5;
        else {
          defExpGainE = (rng.nextInt(2) + 1).toDouble(); // 1–2
          vitExpGainE = (rng.nextInt(2) + 1).toDouble();
        }
      } else if (roll < 0.37) {
        // 12% – Chấn thương cột sống
        enduranceEvt     = EnduranceTrainingEvent.spinalInjury;
        dislocated       = true;
        dislocatedActive = true;
        final int s = rng.nextInt(3);
        if (s == 0)      defExpGainE = rng.nextBool() ? 0.5 : 1.0;
        else if (s == 1) vitExpGainE = rng.nextBool() ? 0.5 : 1.0;
        else {
          defExpGainE = rng.nextInt(3) * 0.5; // 0.0, 0.5, 1.0
          vitExpGainE = rng.nextInt(3) * 0.5;
        }
      } else if (roll < 0.47) {
        // 10% – Hiểm họa ẩn giấu
        enduranceEvt    = EnduranceTrainingEvent.hiddenHazard;
        hpChangeE       = -5;
        takeDamage(5);
        infected        = true;
        infectionActive = true;
        final int s = rng.nextInt(3);
        if (s == 0)      defExpGainE = rng.nextBool() ? 0.5 : 1.0;
        else if (s == 1) vitExpGainE = rng.nextBool() ? 0.5 : 1.0;
        else {
          defExpGainE = rng.nextInt(3) * 0.5;
          vitExpGainE = rng.nextInt(3) * 0.5;
        }
      } else if (roll < 0.57) {
        // 10% – Sức nặng tâm lý
        enduranceEvt  = EnduranceTrainingEvent.psychologicalWeight;
        sanityChangeE = -15;
        changeSanity(-15);
      } else if (roll < 0.72) {
        // 15% – Ý chí sắt đá
        enduranceEvt = EnduranceTrainingEvent.ironWill;
        staminaGainE = 15;
        stamina      = (stamina + 15).clamp(0, maxStamina);
        final int s = rng.nextInt(3);
        if (s == 0)      defExpGainE = 3.0 + rng.nextInt(3); // 3, 4, 5
        else if (s == 1) vitExpGainE = 3.0 + rng.nextInt(3);
        else {
          defExpGainE = 2.0 + rng.nextInt(3); // 2, 3, 4
          vitExpGainE = 2.0 + rng.nextInt(3);
        }
      } else if (roll < 0.84) {
        // 12% – Hốc đất lãng quên
        enduranceEvt = EnduranceTrainingEvent.forgottenCave;
        final int s = rng.nextInt(3);
        if (s == 0)      defExpGainE = 1.5 + rng.nextInt(3) * 0.5;
        else if (s == 1) vitExpGainE = 1.5 + rng.nextInt(3) * 0.5;
        else {
          defExpGainE = (rng.nextInt(2) + 1).toDouble();
          vitExpGainE = (rng.nextInt(2) + 1).toDouble();
        }
      } else if (roll < 0.91) {
        // 7% – Hòa huyết vào đá
        enduranceEvt      = EnduranceTrainingEvent.bloodInRock;
        sanityChangeE     = -10;
        humanityChangeE   = -5;
        changeSanity(-10);
        changeHumanity(-5);
        final int s = rng.nextInt(3);
        if (s == 0)      defExpGainE = 7.0;
        else if (s == 1) vitExpGainE = 7.0;
        else {
          defExpGainE = 3.0 + rng.nextInt(2); // 3 hoặc 4
          vitExpGainE = 3.0 + rng.nextInt(2);
        }
      } else if (roll < 0.96) {
        // 5% – Bị nghiền nát
        enduranceEvt    = EnduranceTrainingEvent.crushed;
        hpChangeE       = -10;
        takeDamage(10);
        staminaDrainedE = true;
        stamina         = 0;
        final int s = rng.nextInt(3);
        if (s == 0)      defExpGainE = 2.0 + rng.nextInt(4) * 0.5; // 2.0–3.5
        else if (s == 1) vitExpGainE = 2.0 + rng.nextInt(4) * 0.5;
        else {
          defExpGainE = 1.5 + rng.nextInt(3) * 0.5; // 1.5–2.5
          vitExpGainE = 1.5 + rng.nextInt(3) * 0.5;
        }
      } else {
        // 4% – Âm thanh sụp đổ
        enduranceEvt      = EnduranceTrainingEvent.collapseSound;
        navigateToCombatE = true;
      }

      // ── VIT leveling ────────────────────────────────────────────────────
      final int    vitStatBefore = vit;
      final double vitExpBefore  = vitExp;
      final double effectiveVitGain =
          vit >= CharacterDefaults.maxStatLevel ? 0.0 : vitExpGainE;
      bool vitLeveledUp = false;
      if (effectiveVitGain > 0) {
        double pool = vitExp + effectiveVitGain;
        while (vit < CharacterDefaults.maxStatLevel) {
          final double needed = expNeededToLevel(vit);
          if (pool >= needed) {
            pool -= needed;
            vit++;
            maxHp += CharacterDefaults.hpPerVitPoint;
            hp = (hp + CharacterDefaults.hpPerVitPoint).clamp(0, maxHp);
            vitLeveledUp = true;
          } else break;
        }
        vitExp = vit >= CharacterDefaults.maxStatLevel ? 0.0 : pool;
      }

      // ── DEF leveling ────────────────────────────────────────────────────
      final int    defStatBefore = bonusDefense;
      final double defExpBefore  = defExp;
      final double effectiveDefGain =
          bonusDefense >= CharacterDefaults.maxStatLevel ? 0.0 : defExpGainE;
      bool defLeveledUp = false;
      if (effectiveDefGain > 0) {
        double pool = defExp + effectiveDefGain;
        while (bonusDefense < CharacterDefaults.maxStatLevel) {
          final double needed = expNeededToLevel(bonusDefense);
          if (pool >= needed) {
            pool -= needed;
            bonusDefense++;
            defLeveledUp = true;
          } else break;
        }
        defExp = bonusDefense >= CharacterDefaults.maxStatLevel ? 0.0 : pool;
      }

      return TrainingResult(
        type:                 type,
        success:              true,
        staminaCost:          staminaCost,
        hungerCost:           hungerCost,
        statBefore:           vitStatBefore,
        statAfter:            vit,
        expBefore:            vitExpBefore,
        expAfter:             vitExp,
        expGain:              effectiveVitGain,
        expNeeded:            expNeededToLevel(vit),
        leveledUp:            vitLeveledUp,
        enduranceEvent:       enduranceEvt,
        defExpGain:           effectiveDefGain,
        defStatBefore:        defStatBefore,
        defStatAfter:         bonusDefense,
        defExpBefore:         defExpBefore,
        defExpAfter:          defExp,
        defExpNeeded:         expNeededToLevel(bonusDefense),
        defLeveledUp:         defLeveledUp,
        hpChange:             hpChangeE,
        sanityTrainChange:    sanityChangeE,
        humanityTrainChange:  humanityChangeE,
        itemDropped:          itemDroppedE,
        staminaDrained:       staminaDrainedE,
        navigateToCombat:     navigateToCombatE,
        staminaGainFromEvent: staminaGainE,
        dislocatedActive:     dislocated,
        infectionActive:      infected,
      );
    }

    // ── Ngồi Thiền Trước Lửa (Meditation) ───────────────────────────────────
    {
      final rng    = Random();
      final roll   = rng.nextDouble();
      final branch = rng.nextInt(3) + 1; // 1 = Mở rộng Tâm Trí, 2 = Xoa dịu, 3 = Cân Bằng

      MeditationTrainingEvent meditationEvt;
      double willExpGainM    = 0.0;
      int    sanityHealM     = 0;
      int    sanityChangeM   = 0;
      int    humanityChangeM = 0;
      int    hpChangeM       = 0;
      Item?  itemDroppedM;
      bool   staminaDrainedM   = false;
      bool   navigateToCombatM = false;
      bool   burnActiveM       = false;
      int    lanternLossM      = 0;

      // ── Xác định sự kiện ───────────────────────────────────────────────
      if (roll < 0.35) {
        // 35% – Tâm trí tĩnh lặng (Bình thường)
        meditationEvt = MeditationTrainingEvent.normal;
        switch (branch) {
          case 1:  willExpGainM = 1.5 + rng.nextDouble();       // 1.5–2.5
          case 2:  sanityHealM  = 15;
          default: willExpGainM = 1.5; sanityHealM = 5;
        }
      } else if (roll < 0.47) {
        // 12% – Ảo ảnh trong tro tàn
        meditationEvt = MeditationTrainingEvent.psychHallucination;
        sanityChangeM = -15;
        changeSanity(-15);
        switch (branch) {
          case 1:  willExpGainM = 0.5 + rng.nextDouble() * 0.5; // 0.5–1.0
          case 2:  sanityHealM  = 5;
          default: willExpGainM = 0.5; sanityHealM = 2;
        }
      } else if (roll < 0.59) {
        // 12% – Hơi nóng phỏng da
        meditationEvt    = MeditationTrainingEvent.burnInjury;
        hpChangeM        = -10;
        takeDamage(10);
        burnActiveM          = true;
        burnTurnsRemaining   = 3;
        burnDamagePerTurn    = 1;
        switch (branch) {
          case 1:  willExpGainM = 0.5 + rng.nextDouble() * 0.5; // 0.5–1.0
          case 2:  sanityHealM  = 5;
          default: willExpGainM = 0.5; sanityHealM = 2;
        }
      } else if (roll < 0.69) {
        // 10% – Bóng tối chực chờ
        meditationEvt = MeditationTrainingEvent.lanternFlicker;
        lanternLossM  = (lanternDurability * 0.10).round().clamp(1, 100);
        lanternDurability = (lanternDurability - lanternLossM).clamp(0, 100);
        sanityChangeM = -5;
        changeSanity(-5);
        switch (branch) {
          case 1:  willExpGainM = 0.5 + rng.nextDouble() * 0.5; // 0.5–1.0
          case 2:  sanityHealM  = 5;
          default: willExpGainM = 0.5; sanityHealM = 2;
        }
      } else if (roll < 0.77) {
        // 8% – Tâm như minh cảnh (Giác ngộ)
        meditationEvt = MeditationTrainingEvent.enlightenment;
        switch (branch) {
          case 1:  willExpGainM = 4.0 + rng.nextDouble() * 2.0;  // 4.0–6.0
          case 2:  sanityHealM  = 40;
          default: willExpGainM = 4.0; sanityHealM = 20;
        }
      } else if (roll < 0.85) {
        // 8% – Cổ ngữ trong ngọn lửa (Vô tình khám phá)
        meditationEvt = MeditationTrainingEvent.ancientScript;
        // (Chưa có vật phẩm thưởng – sẽ được thêm lại)
        switch (branch) {
          case 1:  willExpGainM = 1.5 + rng.nextDouble();       // 1.5–2.5
          case 2:  sanityHealM  = 15;
          default: willExpGainM = 1.5; sanityHealM = 5;
        }
      } else if (roll < 0.90) {
        // 5% – Lời thì thầm của Cổ Thần
        meditationEvt   = MeditationTrainingEvent.abyssCall;
        humanityChangeM = -10;
        sanityChangeM   = -15;
        changeHumanity(-10);
        changeSanity(-15);
        switch (branch) {
          case 1:  willExpGainM = 7.0;
          case 2:  sanityHealM  = 50;
          default: willExpGainM = 5.0; sanityHealM = 25;
        }
      } else if (roll < 0.95) {
        // 5% – Lạc bước cõi âm
        meditationEvt  = MeditationTrainingEvent.soulWander;
        staminaDrainedM = true;
        stamina         = 0;
        switch (branch) {
          case 1:  willExpGainM = 2.0 + rng.nextDouble() * 1.5; // 2.0–3.5
          case 2:  sanityHealM  = 10;
          default: willExpGainM = 2.0; sanityHealM = 5;
        }
      } else {
        // 5% – Cái bóng phản bội
        meditationEvt    = MeditationTrainingEvent.shadowBetrayal;
        navigateToCombatM = true;
      }

      // Áp dụng sanity heal từ nhánh
      if (sanityHealM > 0) changeSanity(sanityHealM);

      // ── Will leveling ──────────────────────────────────────────────────
      final int    willStatBefore  = will;
      final double willExpBefore   = willExp;
      final double effectiveWillGain =
          will >= CharacterDefaults.maxStatLevel ? 0.0 : willExpGainM;
      bool willLeveledUp      = false;
      int  maxSanityIncreaseM = 0;

      if (effectiveWillGain > 0) {
        double pool = willExp + effectiveWillGain;
        while (will < CharacterDefaults.maxStatLevel) {
          final double needed = expNeededToLevel(will);
          if (pool >= needed) {
            pool -= needed;
            will++;
            maxStamina += 5;
            stamina = (stamina + 5).clamp(0, maxStamina);
            // Nhánh 1 và 3 tăng Max Sanity khi lên cấp Ý Chí
            if (branch == 1 || branch == 3) {
              maxSanity += 2;
              maxSanityIncreaseM += 2;
            }
            willLeveledUp = true;
          } else break;
        }
        willExp = will >= CharacterDefaults.maxStatLevel ? 0.0 : pool;
      }

      return TrainingResult(
        type:               type,
        success:            true,
        staminaCost:        staminaCost,
        hungerCost:         hungerCost,
        statBefore:         willStatBefore,
        statAfter:          will,
        expBefore:          willExpBefore,
        expAfter:           willExp,
        expGain:            effectiveWillGain,
        expNeeded:          expNeededToLevel(will),
        leveledUp:          willLeveledUp,
        meditationEvent:    meditationEvt,
        meditationBranch:   branch,
        sanityHealFromBranch: sanityHealM,
        maxSanityIncrease:  maxSanityIncreaseM,
        sanityTrainChange:  sanityChangeM,
        humanityTrainChange: humanityChangeM,
        hpChange:           hpChangeM,
        itemDropped:        itemDroppedM,
        staminaDrained:     staminaDrainedM,
        navigateToCombat:   navigateToCombatM,
        burnActive:         burnActiveM,
        lanternLossFromEvent: lanternLossM,
      );
    }
  }
}
