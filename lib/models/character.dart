import 'dart:math';

import 'inventory.dart';
import 'item.dart';
import 'lantern.dart';

// ────────────────────────────────────────────────────────────────────────────
// Sự kiện đêm khuya (Night Event)
// ────────────────────────────────────────────────────────────────────────────

enum NightEvent {
  deepSleep,       // Giấc ngủ sâu
  nightmare,       // Ác mộng từ Vực Thẳm
  blindWhisper,    // Lời thì thầm của Kẻ Mù
  emberThief,      // Kẻ trộm tro tàn
  nightRaid,       // Đột kích bất ngờ
  sadMemory,       // Hồi ức u buồn
  outsidePlea,     // Lời cầu cứu ngoài cửa
  toxicFog,        // Cơn bão sương độc
  vaultSong,       // Khúc hát từ rường cột
  ashFlare,        // Sự soi rọi của Tro tàn (Hiếm)
  invisibleWatcher,// Kẻ dòm ngó vô hình
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

  /// Kẻ dòm ngó vô hình: ngày hôm sau tỷ lệ gặp quái tăng vọt 80%.
  final bool invisibleWatcherActive;

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
    this.invisibleWatcherActive = false,
  });
}

/// Giá trị mặc định và ngưỡng game cho một [Character] mới.
/// Tập trung tại đây để dễ cân bằng số liệu mà không cần sửa logic.
class CharacterDefaults {
  CharacterDefaults._();

  // ── Trạng Thái Sinh Tồn ──────────────────────────────────────────────────
  static const int hp = 50;
  static const int stamina = 30;
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
  static const int hpPerVitPoint = 10;
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
  })  : maxHp = maxHp ?? CharacterDefaults.hp,
        maxStamina = maxStamina ?? CharacterDefaults.stamina,
        maxHunger = maxHunger ?? CharacterDefaults.hunger,
        inventory = inventory ?? _defaultInventory();

  /// Balo khởi điểm: Lồng Đèn Xương (độc nhất) + 2 Bánh Mì Mốc Tím.
  static Inventory _defaultInventory() {
    final inv = Inventory();
    inv.add(ItemRegistry.boneLantern);
    inv.add(ItemRegistry.moldBread, count: 2);
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

  /// Phòng Thủ hiện tại – chỉ đến từ trang bị, kỹ năng và cảnh giới cao hơn.
  /// Không thể nâng qua điểm chỉ số thông thường.
  int get defense => bonusDefense;

  /// Tổng phòng thủ khi tính thêm bonus tức thời từ trang bị (dùng trong combat).
  int defensePower({int armorBonus = 0}) => bonusDefense + armorBonus;

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
  /// Sát thương thực tế = rawDamage × (50 / (50 + Giáp)), làm tròn về số nguyên gần nhất.
  /// Tối thiểu 1 điểm sát thương nếu rawDamage > 0 (Giáp không thể hoàn toàn vô hiệu hóa đòn đánh).
  void takeDamageWithArmor(int rawDamage) {
    takeDamage(applyArmor(rawDamage, bonusDefense));
  }

  /// Công thức Giáp thuần túy (static – dùng được ở bất kỳ đâu).
  ///
  /// Sát thương thực tế = [rawDamage] × (50 / (50 + [armorValue])), làm tròn.
  /// Tối thiểu 1 nếu [rawDamage] > 0; trả về 0 nếu [rawDamage] ≤ 0.
  ///
  /// Ví dụ:
  ///   applyArmor(10, 0)  → 10
  ///   applyArmor(10, 50) → 5   (giảm 50%)
  ///   applyArmor(10, 200)→ 2   (giảm 80%)
  static int applyArmor(int rawDamage, int armorValue) {
    if (rawDamage <= 0) return 0;
    if (armorValue <= 0) return rawDamage;
    final double reduced = rawDamage * 50 / (50 + armorValue);
    return reduced.round().clamp(1, rawDamage);
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
    sanity = (sanity + delta).clamp(0, 100);
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
    // nightRaid và toxicFog chỉ hồi 50%; sadMemory hồi đầy nhưng trừ 15 lại.
    if (event == NightEvent.nightRaid || event == NightEvent.toxicFog) {
      stamina = (maxStamina * 0.5).round();
    } else {
      stamina = maxStamina;
    }
    // sadMemory: full restore → trừ 15 (sự day dứt buổi sáng)
    int bonusStaminaLoss = 0;
    if (event == NightEvent.sadMemory) {
      bonusStaminaLoss = 15;
      stamina = (stamina - bonusStaminaLoss).clamp(0, maxStamina);
    }

    // ── 4. Hồi Máu theo bảng Độ Sáng ─────────────────────────────────────
    // vaultSong hồi thêm +10% maxHp (ngủ quá say, ngon giấc).
    final double baseHealPct  = LanternSystem.sleepHpHealPercent(lanternDurability);
    final double vaultBonus   = (event == NightEvent.vaultSong) ? 0.10 : 0.0;
    final double totalHealPct = baseHealPct + vaultBonus;
    final int vaultSongExtraHp = (maxHp * vaultBonus).round();

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
        sanityChange = (sanityChange > 0 ? 0 : sanityChange) - 10;
      case NightEvent.nightRaid:
        sanityChange = 0;
      case NightEvent.outsidePlea:
        sanityChange -= 5; // tội lỗi cắn rứt thêm
      case NightEvent.vaultSong:
        sanityChange -= 10; // điệu hát của ác linh
      case NightEvent.invisibleWatcher:
        sanityChange -= 20; // lạnh sống lưng khi nhìn thấy dấu vết
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
    bool   invisibleWatcherResult = false;

    switch (event) {
      case NightEvent.blindWhisper:
        blindWhisperBonusActive = true;
        blindWhisperBonus = true;

      case NightEvent.emberThief:
        if (rng.nextBool()) {
          embersLost = 15.clamp(0, embers);
          embers -= embersLost;
        } else {
          final foodEntries = inventory.consumables
              .where((e) => e.item.group == ItemGroup.food)
              .toList();
          if (foodEntries.isNotEmpty) {
            foodStolen = foodEntries[rng.nextInt(foodEntries.length)].item;
            inventory.remove(foodStolen.id);
          } else {
            embersLost = 15.clamp(0, embers);
            embers -= embersLost;
          }
        }

      case NightEvent.nightRaid:
        navigateToCombat = true;

      case NightEvent.sadMemory:
        humanityChange = 15;
        changeHumanity(15);

      case NightEvent.outsidePlea:
        // Mất Nhân Tính vì đã bỏ mặc người cầu cứu
        humanityChange = -10;
        changeHumanity(-10);
        // Nhặt được 1 vật phẩm ngẫu nhiên từ xác
        const lootPool = [ItemRegistry.rottenMeat, ItemRegistry.moldBread];
        outsidePleaItem = lootPool[rng.nextInt(lootPool.length)];
        inventory.add(outsidePleaItem);

      case NightEvent.toxicFog:
        toxicFogActive = true;  // [Tức Ngực] kéo dài sang ngày hôm sau
        toxicFogResult = true;

      case NightEvent.vaultSong:
        // Đèn bị trừ thêm 15 vì quên canh lửa
        vaultSongExtraLantern = 15;
        lanternDurability = (lanternDurability - vaultSongExtraLantern).clamp(0, 100);

      case NightEvent.ashFlare:
        // Không bị trừ Độ Sáng đêm nay
        lanternDurability = (lanternDurability + LanternSystem.restCost).clamp(0, 100);
        ashFlareProtection = true; // [Được Che Chở] hôm nay
        ashFlareResult = true;

      case NightEvent.invisibleWatcher:
        this.invisibleWatcherActive = true; // 80% monster rate hôm nay
        invisibleWatcherResult = true;

      default:
        break;
    }

    // ── 8. Xóa trạng thái cũ từ ngày trước ───────────────────────────────
    // (toxicFog và invisibleWatcher mới vừa được set lại ở trên nếu cần)
    if (event != NightEvent.toxicFog) toxicFogActive = false;
    if (event != NightEvent.invisibleWatcher) this.invisibleWatcherActive = false;

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
                                   : LanternSystem.restCost + vaultSongExtraLantern,
      blindWhisperBonus:       blindWhisperBonus,
      navigateToCombat:        navigateToCombat,
      humanityChange:          humanityChange,
      bonusStaminaLoss:        bonusStaminaLoss,
      outsidePleaItem:         outsidePleaItem,
      toxicFogActive:          toxicFogResult,
      vaultSongExtraHp:        vaultSongExtraHp,
      vaultSongExtraLanternCost: vaultSongExtraLantern,
      ashFlareActive:          ashFlareResult,
      invisibleWatcherActive:  invisibleWatcherResult,
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
}
