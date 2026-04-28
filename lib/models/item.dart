/// Nhóm vật phẩm theo chức năng.
enum ItemGroup {
  food,    // Lương thực – quản lý Độ No
  medical, // Y tế – phục hồi HP
  mental,  // Tinh thần – Tỉnh Táo & Thể Lực
  combat,  // Tác chiến & đặc biệt
  core,    // Lõi năng lượng – tiến trình
}

/// Chỉ số có thể bị ảnh hưởng bởi vật phẩm.
enum StatId {
  hp,
  maxHp,
  stamina,
  maxStamina,
  hunger,
  sanity,
  humanity,
  embers,
}

/// Trạng thái (debuff/buff) có thể được áp dụng hoặc xóa bỏ.
enum StatusId {
  bleeding,  // Chảy máu
  infection, // Nhiễm trùng
  poisoned,  // Nhiễm độc
  fear,      // Sợ hãi
  exhausted, // Kiệt sức
  burning,   // Thiêu đốt
}

/// Cờ hành vi đặc biệt của vật phẩm.
enum ItemFlag {
  usableInCombat, // Dùng được trong chiến đấu
  combatOnly,     // Chỉ dùng được trong chiến đấu
  noTurnCost,     // Dùng trong combat không tốn lượt
  passive,        // Bị động – tự kích hoạt theo điều kiện
  material,       // Nguyên liệu – không dùng trực tiếp
}

/// Một lần thay đổi chỉ số khi sử dụng vật phẩm.
class StatChange {
  /// Chỉ số bị ảnh hưởng.
  final StatId stat;

  /// Lượng thay đổi (dương = cộng, âm = trừ).
  final int amount;

  /// [true] = thay đổi vĩnh viễn cả giá trị tối đa (vd: -2 maxHp vĩnh viễn).
  final bool permanent;

  /// Số ngày kéo dài; 0 = tức thì.
  final int durationDays;

  /// Xác suất kích hoạt [0.0–1.0]; 1.0 = luôn xảy ra.
  final double chance;

  const StatChange({
    required this.stat,
    required this.amount,
    this.permanent = false,
    this.durationDays = 0,
    this.chance = 1.0,
  });
}

/// Áp dụng hoặc xóa bỏ một trạng thái khi sử dụng vật phẩm.
class StatusChange {
  final StatusId status;

  /// [true] = áp dụng; [false] = xóa bỏ / kháng trong [durationDays] ngày.
  final bool apply;

  /// Số ngày kéo dài; 0 = cho đến khi được chữa lành.
  final int durationDays;

  /// Xác suất kích hoạt [0.0–1.0].
  final double chance;

  const StatusChange({
    required this.status,
    required this.apply,
    this.durationDays = 0,
    this.chance = 1.0,
  });
}

/// Hiệu ứng chỉ hoạt động trong chiến đấu.
class CombatEffect {
  /// Loại hiệu ứng:
  /// - `'enemy_miss_chance'` : giảm tỉ lệ đánh trúng của địch (value = %)
  /// - `'burn_on_next_hit'`  : đòn tiếp theo gây [StatusId.burning] (value = dmg/lượt)
  /// - `'damage_weapon'`     : giảm độ bền vũ khí đang trang bị (value âm)
  final String type;

  /// Giá trị số đính kèm (vd: -50 = giảm 50% hit chance, 5 = 5 dmg/lượt).
  final int value;

  /// Số lượt kéo dài (0 = tức thì / chỉ 1 lần).
  final int durationTurns;

  const CombatEffect({
    required this.type,
    this.value = 0,
    this.durationTurns = 0,
  });
}

/// Định nghĩa đầy đủ một vật phẩm trong game.
class Item {
  /// ID nội bộ để lưu/load và tra cứu.
  final String id;

  /// Key trong AppStrings cho tên hiển thị.
  final String nameKey;

  /// Key trong AppStrings cho mô tả.
  final String descKey;

  /// Nhóm phân loại.
  final ItemGroup group;

  /// Hiệu ứng chính khi sử dụng.
  final List<StatChange> effects;

  /// Tác dụng phụ khi sử dụng.
  final List<StatChange> sideEffects;

  /// Trạng thái áp dụng hoặc xóa khi sử dụng.
  final List<StatusChange> statusEffects;

  /// Hiệu ứng đặc biệt trong chiến đấu.
  final List<CombatEffect> combatEffects;

  /// Danh sách cờ hành vi.
  final List<ItemFlag> flags;

  // ── Hành vi đặc biệt ──────────────────────────────────────────────────────

  /// Path asset hình ảnh icon (null = dùng icon mặc định theo nhóm).
  final String? iconPath;

  /// Hồi đầy 100% HP thay vì lượng cố định (Nước Mắt Thánh Nữ).
  final bool healsToFull;

  /// Xóa mọi debuff đang hoạt động (Nước Mắt Thánh Nữ).
  final bool clearsAllDebuffs;

  /// Các chỉ số bị set về 0 khi dùng (Nước Mắt Thánh Nữ: drains stamina).
  final List<StatId> drainsToZero;

  /// Passive: chặn 1 đòn chí mạng, giữ lại 1 HP, vỡ sau khi kích hoạt.
  final bool blocksLethalHit;

  /// Bỏ qua chiến đấu với quái vật cấp thấp trong đêm Trăng Máu.
  final bool skipLowMonsters;

  /// Khi dùng trước khi Ngủ: xác suất bị tập kích ban đêm = 0%.
  final bool preventNightRaid;

  /// Xác suất sự kiện xấu tăng thêm vào sáng hôm sau (0.0 = không).
  final double badEventBonus;

  /// Hồi 100% Stamina ngay lập tức và duy trì trong N ngày (0 = không áp dụng).
  final int fullStaminaDays;

  /// Hồi đầy 100% ánh sáng cho Lồng Đèn Xương (Trái Tim Oán Hận).
  final bool restoresLanternFull;

  /// Vật phẩm độc nhất – không bao giờ bị xóa khỏi balo khi số lượng về 0.
  final bool isUnique;

  const Item({
    required this.id,
    required this.nameKey,
    required this.descKey,
    required this.group,
    this.effects = const [],
    this.sideEffects = const [],
    this.statusEffects = const [],
    this.combatEffects = const [],
    this.flags = const [],
    this.iconPath,
    this.healsToFull = false,
    this.clearsAllDebuffs = false,
    this.drainsToZero = const [],
    this.blocksLethalHit = false,
    this.skipLowMonsters = false,
    this.preventNightRaid = false,
    this.badEventBonus = 0.0,
    this.fullStaminaDays = 0,
    this.restoresLanternFull = false,
    this.isUnique = false,
  });

  bool hasFlag(ItemFlag f) => flags.contains(f);
}

// ── Kho dữ liệu tất cả vật phẩm ──────────────────────────────────────────────

class ItemRegistry {
  ItemRegistry._();

  // ── 1. Nhóm Lương Thực ────────────────────────────────────────────────────

  /// Thịt Dai Mục Nát – +20 Độ No, -5 HP (nhiễm độc nhẹ).
  static const Item rottenMeat = Item(
    id: 'rotten_meat',
    nameKey: 'item_rotten_meat_name',
    descKey: 'item_rotten_meat_desc',
    group: ItemGroup.food,
    effects: [
      StatChange(stat: StatId.hunger, amount: 20),
    ],
    sideEffects: [
      StatChange(stat: StatId.hp, amount: -5),
    ],
  );

  /// Bánh Mì Mốc Tím – +15 Độ No, -10 Độ Tỉnh Táo.
  static const Item moldBread = Item(
    id: 'mold_bread',
    nameKey: 'item_mold_bread_name',
    descKey: 'item_mold_bread_desc',
    group: ItemGroup.food,
    iconPath: 'assets/images/items/item_slice_mold_bread.png',
    effects: [
      StatChange(stat: StatId.hunger, amount: 15),
    ],
    sideEffects: [
      StatChange(stat: StatId.sanity, amount: -10),
    ],
  );

  /// Lương Khô Tử Trận – +30 Độ No, +20 Thể Lực. Không tác dụng phụ.
  static const Item soldierRation = Item(
    id: 'soldier_ration',
    nameKey: 'item_soldier_ration_name',
    descKey: 'item_soldier_ration_desc',
    group: ItemGroup.food,
    effects: [
      StatChange(stat: StatId.hunger, amount: 30),
      StatChange(stat: StatId.stamina, amount: 20),
    ],
  );

  /// Súp Rễ Cây U Sầu – +30 Độ No, -10 Độ Tỉnh Táo.
  static const Item sorrowSoup = Item(
    id: 'sorrow_soup',
    nameKey: 'item_sorrow_soup_name',
    descKey: 'item_sorrow_soup_desc',
    group: ItemGroup.food,
    effects: [
      StatChange(stat: StatId.hunger, amount: 30),
    ],
    sideEffects: [
      StatChange(stat: StatId.sanity, amount: -10),
    ],
  );

  /// Thịt Nướng Tế Thần – +50 Độ No, +10 HP, -15 Nhân Tính.
  static const Item sacrificialMeat = Item(
    id: 'sacrificial_meat',
    nameKey: 'item_sacrificial_meat_name',
    descKey: 'item_sacrificial_meat_desc',
    group: ItemGroup.food,
    effects: [
      StatChange(stat: StatId.hunger, amount: 50),
      StatChange(stat: StatId.hp, amount: 10),
    ],
    sideEffects: [
      StatChange(stat: StatId.humanity, amount: -15),
    ],
  );

  // ── 2. Nhóm Y Tế ──────────────────────────────────────────────────────────

  /// Băng Gạc Bẩn – +15 HP, xóa [Chảy máu], 20% gây [Nhiễm trùng] (-5 maxHP 3 ngày).
  static const Item dirtyBandage = Item(
    id: 'dirty_bandage',
    nameKey: 'item_dirty_bandage_name',
    descKey: 'item_dirty_bandage_desc',
    group: ItemGroup.medical,
    effects: [
      StatChange(stat: StatId.hp, amount: 15),
    ],
    statusEffects: [
      StatusChange(status: StatusId.bleeding, apply: false),
      StatusChange(
          status: StatusId.infection, apply: true, durationDays: 3, chance: 0.2),
    ],
    sideEffects: [
      StatChange(stat: StatId.maxHp, amount: -5, durationDays: 3, chance: 0.2),
    ],
  );

  /// Chiết Xuất Huyết Tinh – +40 HP tức thì, -15 Nhân Tính.
  static const Item emberBlood = Item(
    id: 'ember_blood',
    nameKey: 'item_ember_blood_name',
    descKey: 'item_ember_blood_desc',
    group: ItemGroup.medical,
    effects: [
      StatChange(stat: StatId.hp, amount: 40),
    ],
    sideEffects: [
      StatChange(stat: StatId.humanity, amount: -15),
    ],
  );

  /// Nhựa Cây Sầu Muộn – +10 HP/ngày trong 3 ngày. Không tác dụng phụ.
  static const Item weepingResin = Item(
    id: 'weeping_resin',
    nameKey: 'item_weeping_resin_name',
    descKey: 'item_weeping_resin_desc',
    group: ItemGroup.medical,
    effects: [
      StatChange(stat: StatId.hp, amount: 10, durationDays: 3),
    ],
  );

  /// Nước Mắt Thánh Nữ – Hồi 100% HP, xóa mọi debuff, Thể Lực về 0.
  static const Item fallenTears = Item(
    id: 'fallen_tears',
    nameKey: 'item_fallen_tears_name',
    descKey: 'item_fallen_tears_desc',
    group: ItemGroup.medical,
    healsToFull: true,
    clearsAllDebuffs: true,
    drainsToZero: [StatId.stamina],
  );

  /// Ký Sinh Trùng Khâu Nhục – +50 HP (dùng được trong combat, không tốn lượt),
  /// -2 maxHP vĩnh viễn.
  static const Item fleshParasite = Item(
    id: 'flesh_parasite',
    nameKey: 'item_flesh_parasite_name',
    descKey: 'item_flesh_parasite_desc',
    group: ItemGroup.medical,
    effects: [
      StatChange(stat: StatId.hp, amount: 50),
    ],
    sideEffects: [
      StatChange(stat: StatId.maxHp, amount: -2, permanent: true),
    ],
    flags: [ItemFlag.usableInCombat, ItemFlag.noTurnCost],
  );

  // ── 3. Nhóm Tinh Thần & Cảm Giác ─────────────────────────────────────────

  /// Cỏ Khô An Thần – +20 Độ Tỉnh Táo. Không tác dụng phụ.
  static const Item soothingHerb = Item(
    id: 'soothing_herb',
    nameKey: 'item_soothing_herb_name',
    descKey: 'item_soothing_herb_desc',
    group: ItemGroup.mental,
    effects: [
      StatChange(stat: StatId.sanity, amount: 20),
    ],
  );

  /// Nước Suối Ô Nhiễm – +15 Thể Lực, -5 HP.
  static const Item pollutedWater = Item(
    id: 'polluted_water',
    nameKey: 'item_polluted_water_name',
    descKey: 'item_polluted_water_desc',
    group: ItemGroup.mental,
    effects: [
      StatChange(stat: StatId.stamina, amount: 15),
    ],
    sideEffects: [
      StatChange(stat: StatId.hp, amount: -5),
    ],
  );

  /// Rượu Đầu Lâu – 100% Stamina trong 1 ngày, miễn nhiễm [Sợ Hãi];
  /// sang ngày sau bị [Kiệt sức] (maxStamina -50% trong 1 ngày).
  static const Item skullMoonshine = Item(
    id: 'skull_moonshine',
    nameKey: 'item_skull_moonshine_name',
    descKey: 'item_skull_moonshine_desc',
    group: ItemGroup.mental,
    fullStaminaDays: 1,
    statusEffects: [
      StatusChange(status: StatusId.fear, apply: false, durationDays: 1),
      StatusChange(status: StatusId.exhausted, apply: true, durationDays: 1),
    ],
  );

  /// Tro Xông Hương – +40 Độ Tỉnh Táo; nếu dùng trước khi Ngủ: không bị
  /// tập kích ban đêm; tỉ lệ sự kiện xấu sáng hôm sau +10%.
  static const Item lostIncense = Item(
    id: 'lost_incense',
    nameKey: 'item_lost_incense_name',
    descKey: 'item_lost_incense_desc',
    group: ItemGroup.mental,
    effects: [
      StatChange(stat: StatId.sanity, amount: 40),
    ],
    preventNightRaid: true,
    badEventBonus: 0.1,
  );

  // ── 4. Nhóm Tác Chiến & Đặc Biệt ─────────────────────────────────────────

  /// Lọ Tro Mù – Combat only: địch -50% hit chance trong 2 lượt.
  static const Item ashVial = Item(
    id: 'ash_vial',
    nameKey: 'item_ash_vial_name',
    descKey: 'item_ash_vial_desc',
    group: ItemGroup.combat,
    combatEffects: [
      CombatEffect(type: 'enemy_miss_chance', value: -50, durationTurns: 2),
    ],
    flags: [ItemFlag.combatOnly],
  );

  /// Dầu Hắc Ín Rỉ Máu – Combat only: đòn tiếp theo gây [Thiêu Đốt]
  /// (5 HP/lượt × 3 lượt), trừ 1 độ bền vũ khí.
  static const Item bleedingPitch = Item(
    id: 'bleeding_pitch',
    nameKey: 'item_bleeding_pitch_name',
    descKey: 'item_bleeding_pitch_desc',
    group: ItemGroup.combat,
    combatEffects: [
      CombatEffect(type: 'burn_on_next_hit', value: 5, durationTurns: 3),
      CombatEffect(type: 'damage_weapon', value: -1),
    ],
    flags: [ItemFlag.combatOnly],
  );

  /// Máu Loãng Kẻ Điên – Bỏ qua quái vật cấp thấp trong đêm Trăng Máu,
  /// -20 Độ Tỉnh Táo ngay khi dùng.
  static const Item madmanBlood = Item(
    id: 'madman_blood',
    nameKey: 'item_madman_blood_name',
    descKey: 'item_madman_blood_desc',
    group: ItemGroup.combat,
    skipLowMonsters: true,
    sideEffects: [
      StatChange(stat: StatId.sanity, amount: -20),
    ],
  );

  /// Bùa Hộ Mệnh Vỡ Nát – Passive: chặn 1 đòn chí mạng, giữ lại 1 HP,
  /// vỡ vụn sau khi kích hoạt.
  static const Item shatteredAmulet = Item(
    id: 'shattered_amulet',
    nameKey: 'item_shattered_amulet_name',
    descKey: 'item_shattered_amulet_desc',
    group: ItemGroup.combat,
    blocksLethalHit: true,
    flags: [ItemFlag.passive],
  );

  // ── 5. Nhóm Lõi Năng Lượng ────────────────────────────────────────────────

  /// Lõi Lửa Cơ Bản – Nguyên liệu bắt buộc để Đột phá giới hạn Cấp độ.
  static const Item emberCore = Item(
    id: 'ember_core',
    nameKey: 'item_ember_core_name',
    descKey: 'item_ember_core_desc',
    group: ItemGroup.core,
    flags: [ItemFlag.material],
  );

  /// Trái Tim Oán Hận – Hồi 100% ánh sáng Lồng Đèn, -10 Nhân Tính.
  static const Item wrathfulHeart = Item(
    id: 'wrathful_heart',
    nameKey: 'item_wrathful_heart_name',
    descKey: 'item_wrathful_heart_desc',
    group: ItemGroup.core,
    restoresLanternFull: true,
    sideEffects: [
      StatChange(stat: StatId.humanity, amount: -10),
    ],
  );

  /// Lồng Đèn Xương – Vật phẩm độc nhất, không bao giờ biến mất.
  /// Độ Sáng được quản lý qua Character.lanternDurability.
  static const Item boneLantern = Item(
    id: 'bone_lantern',
    nameKey: 'item_bone_lantern_name',
    descKey: 'item_bone_lantern_desc',
    group: ItemGroup.core,
    iconPath: 'assets/images/items/icon_bone_lantern.png',
    flags: [ItemFlag.passive],
    isUnique: true,
  );

  // ── Danh sách tổng hợp ────────────────────────────────────────────────────

  static const List<Item> all = [
    rottenMeat,
    moldBread,
    soldierRation,
    sorrowSoup,
    sacrificialMeat,
    dirtyBandage,
    emberBlood,
    weepingResin,
    fallenTears,
    fleshParasite,
    soothingHerb,
    pollutedWater,
    skullMoonshine,
    lostIncense,
    ashVial,
    bleedingPitch,
    madmanBlood,
    shatteredAmulet,
    emberCore,
    wrathfulHeart,
    boneLantern,
  ];

  /// Tra cứu vật phẩm theo [id]. Trả về null nếu không tìm thấy.
  static Item? byId(String id) {
    for (final item in all) {
      if (item.id == id) return item;
    }
    return null;
  }
}
