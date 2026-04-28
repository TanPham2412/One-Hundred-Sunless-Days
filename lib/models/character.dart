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
    this.humanity = CharacterDefaults.humanity,
    this.sanity = CharacterDefaults.sanity,
    this.embers = CharacterDefaults.embers,
    this.realm = CharacterDefaults.realm,
  })  : maxHp = maxHp ?? CharacterDefaults.hp,
        maxStamina = maxStamina ?? CharacterDefaults.stamina,
        maxHunger = maxHunger ?? CharacterDefaults.hunger;

  // ── Trạng Thái Tính Toán ─────────────────────────────────────────────────

  /// Trả về true khi Máu về 0.
  bool get isDead => hp <= 0;

  /// Trả về true khi Độ No xuống dưới ngưỡng nguy hiểm.
  bool get isStarving =>
      hunger < CharacterDefaults.hungerDangerThreshold;

  /// Trả về true khi Độ Tỉnh Táo đủ thấp để gây debuff ảo giác.
  bool get isHallucinating =>
      sanity < CharacterDefaults.sanityHallucinationThreshold;

  /// Tổng sức tấn công, tùy chọn cộng thêm bonus từ vũ khí.
  /// Công thức: STR + weaponBonus
  int attackPower({int weaponBonus = 0}) => str + weaponBonus;

  /// Tổng phòng thủ, tùy chọn cộng thêm bonus từ giáp.
  /// Công thức: VIT + armorBonus
  int defensePower({int armorBonus = 0}) => vit + armorBonus;

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
