import 'package:one_hundred_sunless_days/models/status.dart';

export 'package:one_hundred_sunless_days/models/status.dart';

/// Độ hiếm của vật phẩm – ảnh hưởng màu viền trong UI.
enum ItemRarity {
  common,    // Thường      – không viền
  uncommon,  // Ít thấy     – xanh lá  #44AA55
  rare,      // Hiếm        – xanh dương #4488CC
  epic,      // Sử thi      – tím       #9944CC
  legendary, // Huyền thoại – vàng      #D4A843
  mythic,    // Thần thoại  – đỏ        #CC3333
}

/// Nhóm vật phẩm theo chức năng.
enum ItemGroup {
  food,    // Lương thực – quản lý Độ No
  medical, // Y tế – phục hồi HP
  mental,  // Tinh thần – Tỉnh Táo & Thể Lực
  combat,  // Tác chiến & đặc biệt
  core,     // Lõi năng lượng – tiến trình
  weapon,   // Vũ khí – trang bị chiến đấu
  armor,    // Áo giáp – trang bị phòng thủ
  material, // Vật liệu thô – dùng để chế tạo vũ khí và giáp
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

  /// Độ hiếm của vật phẩm – xác định màu viền icon.
  final ItemRarity rarity;

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

  /// Tăng xác suất gặp sự kiện Tập Kích ban đêm [0.0–1.0] (Tro Kích Thích).
  final double raidChanceBonus;

  /// Khi dùng: ngăn chặn chức năng Nghỉ Ngơi đêm tiếp theo (Tủy Sống Dị Biến).
  final bool blocksRestNextDay;

  /// Mất N điểm EXP ở 1 chỉ số ngẫu nhiên (Tấn công hoặc Phòng thủ) khi sử dụng.
  final int losesRandomExpAmount;

  /// Lồng Đèn không tiêu hao nhiên liệu trong N ngày (Mảnh Thiên Thạch Rực Cháy).
  final int lanternFreeBurnDays;

  /// Vật phẩm độc nhất – không bao giờ bị xóa khỏi balo khi số lượng về 0.
  final bool isUnique;

  // ── Chỉ Số Vũ Khí ────────────────────────────────────────────────────────

  /// Bonus Tấn Công khi dùng vũ khí này (0 = không phải vũ khí).
  final int atkBonus;

  /// Vũ khí Nặng: tăng Action Value ~5%, giảm tốc độ ra đòn.
  final bool isHeavy;

  /// Tỷ lệ đòn tấn công trượt dọc, chỉ gây 50% sát thương [0.0–1.0].
  final double glancingHitChance;

  /// Tỷ lệ gây [StatusId.bleeding] khi chém trúng kẻ địch mang xác thịt sinh học [0.0–1.0].
  final double bleedOnBioHitChance;

  /// Khi dùng để "Vung Vũ Khí Khan": cộng thêm vào xác suất sự kiện Tai Nạn Vũ Khí [0.0–1.0].
  final double trainingWeaponAccidentBonus;

  // ── Chỉ Số Áo Giáp ───────────────────────────────────────────────────────

  /// Bonus Phòng Thủ khi trang bị áo giáp này.
  final int defBonus;

  /// Bonus Máu Tối Đa khi trang bị áo giáp này.
  final int maxHpBonus;

  /// [Tưa Rách]: Xác suất [0.0–1.0] đòn tấn công của quái vật bỏ qua toàn bộ bonus DEF từ áo giáp.
  final double armorPierceChance;

  /// [Ổ Vi Khuẩn]: Khi nhân vật đang bị [Nhiễm Trùng], tăng thêm HP mất/ngày từ hiệu ứng đó.
  final int infectionHpDrainBonus;

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
    this.rarity = ItemRarity.common,
    this.healsToFull = false,
    this.clearsAllDebuffs = false,
    this.drainsToZero = const [],
    this.blocksLethalHit = false,
    this.skipLowMonsters = false,
    this.preventNightRaid = false,
    this.badEventBonus = 0.0,
    this.fullStaminaDays = 0,
    this.restoresLanternFull = false,
    this.raidChanceBonus = 0.0,
    this.blocksRestNextDay = false,
    this.losesRandomExpAmount = 0,
    this.lanternFreeBurnDays = 0,
    this.isUnique = false,
    this.atkBonus = 0,
    this.isHeavy = false,
    this.glancingHitChance = 0.0,
    this.bleedOnBioHitChance = 0.0,
    this.trainingWeaponAccidentBonus = 0.0,
    this.defBonus = 0,
    this.maxHpBonus = 0,
    this.armorPierceChance = 0.0,
    this.infectionHpDrainBonus = 0,
  });

  bool hasFlag(ItemFlag f) => flags.contains(f);
}

// ── Kho dữ liệu tất cả vật phẩm ──────────────────────────────────────────────

class ItemRegistry {
  ItemRegistry._();

  // ── 1. Nhóm Lương Thực ────────────────────────────────────────────────────
  // (Trống – món ăn sẽ được thêm lại)

  // ── 2. Nhóm Y Tế ──────────────────────────────────────────────────────────
  // (Trống – vật phẩm y tế sẽ được thêm lại)

  // ── 3. Nhóm Tinh Thần & Cảm Giác ─────────────────────────────────────────
  // (Trống – vật phẩm tinh thần sẽ được thêm lại)

  // ── 4. Nhóm Tác Chiến & Đặc Biệt ─────────────────────────────────────────
  // (Trống – vật phẩm tác chiến sẽ được thêm lại)

  // ── 5. Nhóm Lõi Năng Lượng ────────────────────────────────────────────────
  // (Trống – lõi năng lượng sẽ được thêm lại)

  // ── 6. Nhóm Vũ Khí ────────────────────────────────────────────────────────
  // (Trống – vũ khí sẽ được thêm lại)

  // ── 7. Nhóm Áo Giáp ───────────────────────────────────────────────────────
  // (Trống – áo giáp sẽ được thêm lại)

  // ── 8. Nhóm Vật Liệu Chế Tạo ─────────────────────────────────────────────

  // ── Tier 1: Common ──────────────────────────────────────────────────────

  static const Item roughIronScrap = Item(
    id: 'rough_iron_scrap',
    nameKey: 'item_rough_iron_scrap_name',
    descKey: 'item_rough_iron_scrap_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/rough_iron_scrap.png',
    rarity: ItemRarity.common,
    flags: [ItemFlag.material],
  );

  static const Item rustyNail = Item(
    id: 'rusty_nail',
    nameKey: 'item_rusty_nail_name',
    descKey: 'item_rusty_nail_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/rusty_nail.png',
    rarity: ItemRarity.common,
    flags: [ItemFlag.material],
  );

  // ── Tier 2: Uncommon ────────────────────────────────────────────────────

  static const Item oldGrindstone = Item(
    id: 'old_grindstone',
    nameKey: 'item_old_grindstone_name',
    descKey: 'item_old_grindstone_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/old_grindstone.png',
    rarity: ItemRarity.uncommon,
    flags: [ItemFlag.material],
  );

  static const Item brokenArmorPiece = Item(
    id: 'broken_armor_piece',
    nameKey: 'item_broken_armor_piece_name',
    descKey: 'item_broken_armor_piece_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/broken_armor_piece.png',
    rarity: ItemRarity.uncommon,
    flags: [ItemFlag.material],
  );

  // ── Tier 3: Rare ────────────────────────────────────────────────────────

  static const Item ironChains = Item(
    id: 'iron_chains',
    nameKey: 'item_iron_chains_name',
    descKey: 'item_iron_chains_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/iron_chains.png',
    rarity: ItemRarity.rare,
    flags: [ItemFlag.material],
  );

  static const Item steelOre = Item(
    id: 'steel_ore',
    nameKey: 'item_steel_ore_name',
    descKey: 'item_steel_ore_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/steel_ore.png',
    rarity: ItemRarity.rare,
    flags: [ItemFlag.material],
  );

  static const Item blastPowderJar = Item(
    id: 'blast_powder_jar',
    nameKey: 'item_blast_powder_jar_name',
    descKey: 'item_blast_powder_jar_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/blast_powder_jar.png',
    rarity: ItemRarity.rare,
    flags: [ItemFlag.material],
  );

  // ── Tier 4: Epic ────────────────────────────────────────────────────────

  static const Item pureSilverOre = Item(
    id: 'pure_silver_ore',
    nameKey: 'item_pure_silver_ore_name',
    descKey: 'item_pure_silver_ore_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/pure_silver_ore.png',
    rarity: ItemRarity.epic,
    flags: [ItemFlag.material],
  );

  static const Item mechanicalComponents = Item(
    id: 'mechanical_components',
    nameKey: 'item_mechanical_components_name',
    descKey: 'item_mechanical_components_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/mechanical_components.png',
    rarity: ItemRarity.epic,
    flags: [ItemFlag.material],
  );

  // ── Tier 5: Legendary ───────────────────────────────────────────────────

  static const Item rareSteelOre = Item(
    id: 'rare_steel_ore',
    nameKey: 'item_rare_steel_ore_name',
    descKey: 'item_rare_steel_ore_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/rare_steel_ore.png',
    rarity: ItemRarity.legendary,
    flags: [ItemFlag.material],
  );

  static const Item pureGoldBlock = Item(
    id: 'pure_gold_block',
    nameKey: 'item_pure_gold_block_name',
    descKey: 'item_pure_gold_block_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/pure_gold_block.png',
    rarity: ItemRarity.legendary,
    flags: [ItemFlag.material],
  );

  // ── Nguyên liệu hữu cơ & sinh học ────────────────────────────────────────

  // ── Tier 1: Common ───────────────────────────────────────────────────────

  static const Item rawAnimalHide = Item(
    id: 'raw_animal_hide',
    nameKey: 'item_raw_animal_hide_name',
    descKey: 'item_raw_animal_hide_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/raw_animal_hide.png',
    rarity: ItemRarity.common,
    flags: [ItemFlag.material],
  );

  static const Item thornyRopeCoil = Item(
    id: 'thorny_rope_coil',
    nameKey: 'item_thorny_rope_coil_name',
    descKey: 'item_thorny_rope_coil_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/thorny_rope_coil.png',
    rarity: ItemRarity.common,
    flags: [ItemFlag.material],
  );

  static const Item animalFat = Item(
    id: 'animal_fat',
    nameKey: 'item_animal_fat_name',
    descKey: 'item_animal_fat_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/animal_fat.png',
    rarity: ItemRarity.common,
    flags: [ItemFlag.material],
  );

  static const Item mudAndLeaves = Item(
    id: 'mud_and_leaves',
    nameKey: 'item_mud_and_leaves_name',
    descKey: 'item_mud_and_leaves_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/mud_and_leaves.png',
    rarity: ItemRarity.common,
    flags: [ItemFlag.material],
  );

  // ── Tier 2: Uncommon ─────────────────────────────────────────────────────

  static const Item thickWarmFur = Item(
    id: 'thick_warm_fur',
    nameKey: 'item_thick_warm_fur_name',
    descKey: 'item_thick_warm_fur_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/thick_warm_fur.png',
    rarity: ItemRarity.uncommon,
    flags: [ItemFlag.material],
  );

  static const Item resin = Item(
    id: 'resin',
    nameKey: 'item_resin_name',
    descKey: 'item_resin_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/resin.png',
    rarity: ItemRarity.uncommon,
    flags: [ItemFlag.material],
  );

  static const Item leatherStrap = Item(
    id: 'leather_strap',
    nameKey: 'item_leather_strap_name',
    descKey: 'item_leather_strap_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/leather_strap.png',
    rarity: ItemRarity.uncommon,
    flags: [ItemFlag.material],
  );

  static const Item hardOakWood = Item(
    id: 'hard_oak_wood',
    nameKey: 'item_hard_oak_wood_name',
    descKey: 'item_hard_oak_wood_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/hard_oak_wood.png',
    rarity: ItemRarity.uncommon,
    flags: [ItemFlag.material],
  );

  static const Item beastBloodVial = Item(
    id: 'beast_blood_vial',
    nameKey: 'item_beast_blood_vial_name',
    descKey: 'item_beast_blood_vial_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/beast_blood_vial.png',
    rarity: ItemRarity.uncommon,
    flags: [ItemFlag.material],
  );

  // ── Tier 3: Rare ─────────────────────────────────────────────────────────

  static const Item stickyTar = Item(
    id: 'sticky_tar',
    nameKey: 'item_sticky_tar_name',
    descKey: 'item_sticky_tar_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/sticky_tar.png',
    rarity: ItemRarity.rare,
    flags: [ItemFlag.material],
  );

  static const Item mutatedBeastTendon = Item(
    id: 'mutated_beast_tendon',
    nameKey: 'item_mutated_beast_tendon_name',
    descKey: 'item_mutated_beast_tendon_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/mutated_beast_tendon.png',
    rarity: ItemRarity.rare,
    flags: [ItemFlag.material],
  );

  static const Item beastHorn = Item(
    id: 'beast_horn',
    nameKey: 'item_beast_horn_name',
    descKey: 'item_beast_horn_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/beast_horn.png',
    rarity: ItemRarity.rare,
    flags: [ItemFlag.material],
  );

  static const Item beastBoneRemnant = Item(
    id: 'beast_bone_remnant',
    nameKey: 'item_beast_bone_remnant_name',
    descKey: 'item_beast_bone_remnant_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/beast_bone_remnant.png',
    rarity: ItemRarity.rare,
    flags: [ItemFlag.material],
  );

  // ── Tier 4: Epic ─────────────────────────────────────────────────────────

  static const Item eliteMonsterHide = Item(
    id: 'elite_monster_hide',
    nameKey: 'item_elite_monster_hide_name',
    descKey: 'item_elite_monster_hide_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/elite_monster_hide.png',
    rarity: ItemRarity.epic,
    flags: [ItemFlag.material],
  );

  static const Item bloodCrystal = Item(
    id: 'blood_crystal',
    nameKey: 'item_blood_crystal_name',
    descKey: 'item_blood_crystal_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/blood_crystal.png',
    rarity: ItemRarity.epic,
    flags: [ItemFlag.material],
  );

  static const Item wraithHair = Item(
    id: 'wraith_hair',
    nameKey: 'item_wraith_hair_name',
    descKey: 'item_wraith_hair_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/wraith_hair.png',
    rarity: ItemRarity.epic,
    flags: [ItemFlag.material],
  );

  static const Item brokenHolyRelic = Item(
    id: 'broken_holy_relic',
    nameKey: 'item_broken_holy_relic_name',
    descKey: 'item_broken_holy_relic_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/broken_holy_relic.png',
    rarity: ItemRarity.epic,
    flags: [ItemFlag.material],
  );

  static const Item brokenSilverChalice = Item(
    id: 'broken_silver_chalice',
    nameKey: 'item_broken_silver_chalice_name',
    descKey: 'item_broken_silver_chalice_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/broken_silver_chalice.png',
    rarity: ItemRarity.epic,
    flags: [ItemFlag.material],
  );

  static const Item dreamIncensePowder = Item(
    id: 'dream_incense_powder',
    nameKey: 'item_dream_incense_powder_name',
    descKey: 'item_dream_incense_powder_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/dream_incense_powder.png',
    rarity: ItemRarity.epic,
    flags: [ItemFlag.material],
  );

  // ── Tier 5: Legendary ──────────────────────────────────────────────────

  static const Item nightmareFruit = Item(
    id: 'nightmare_fruit',
    nameKey: 'item_nightmare_fruit_name',
    descKey: 'item_nightmare_fruit_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/nightmare_fruit.png',
    rarity: ItemRarity.legendary,
    flags: [ItemFlag.material],
  );

  static const Item cleansingTear = Item(
    id: 'cleansing_tear',
    nameKey: 'item_cleansing_tear_name',
    descKey: 'item_cleansing_tear_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/cleansing_tear.png',
    rarity: ItemRarity.legendary,
    flags: [ItemFlag.material],
  );

  static const Item quartzClockworkParts = Item(
    id: 'quartz_clockwork_parts',
    nameKey: 'item_quartz_clockwork_parts_name',
    descKey: 'item_quartz_clockwork_parts_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/quartz_clockwork_parts.png',
    rarity: ItemRarity.legendary,
    flags: [ItemFlag.material],
  );

  static const Item boneLanternFire = Item(
    id: 'bone_lantern_fire',
    nameKey: 'item_bone_lantern_fire_name',
    descKey: 'item_bone_lantern_fire_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/bone_lantern_fire.png',
    rarity: ItemRarity.legendary,
    flags: [ItemFlag.material],
  );

  static const Item brokenRoyalSword = Item(
    id: 'broken_royal_sword',
    nameKey: 'item_broken_royal_sword_name',
    descKey: 'item_broken_royal_sword_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/broken_royal_sword.png',
    rarity: ItemRarity.legendary,
    flags: [ItemFlag.material],
  );

  static const Item rustedKingArmor = Item(
    id: 'rusted_king_armor',
    nameKey: 'item_rusted_king_armor_name',
    descKey: 'item_rusted_king_armor_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/rusted_king_armor.png',
    rarity: ItemRarity.legendary,
    flags: [ItemFlag.material],
  );

  static const Item petrifiedRoot = Item(
    id: 'petrified_root',
    nameKey: 'item_petrified_root_name',
    descKey: 'item_petrified_root_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/petrified_root.png',
    rarity: ItemRarity.legendary,
    flags: [ItemFlag.material],
  );

  static const Item weepingBowFrame = Item(
    id: 'weeping_bow_frame',
    nameKey: 'item_weeping_bow_frame_name',
    descKey: 'item_weeping_bow_frame_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/weeping_bow_frame.png',
    rarity: ItemRarity.legendary,
    flags: [ItemFlag.material],
  );

  static const Item goliathRuinedArmor = Item(
    id: 'goliath_ruined_armor',
    nameKey: 'item_goliath_ruined_armor_name',
    descKey: 'item_goliath_ruined_armor_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/goliath_ruined_armor.png',
    rarity: ItemRarity.legendary,
    flags: [ItemFlag.material],
  );

  static const Item goldDustedShieldFragment = Item(
    id: 'gold_dusted_shield_fragment',
    nameKey: 'item_gold_dusted_shield_fragment_name',
    descKey: 'item_gold_dusted_shield_fragment_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/gold_dusted_shield_fragment.png',
    rarity: ItemRarity.legendary,
    flags: [ItemFlag.material],
  );

  // ── Tier 6: Mythic ─────────────────────────────────────────────────────

  static const Item evilGodChain = Item(
    id: 'evil_god_chain',
    nameKey: 'item_evil_god_chain_name',
    descKey: 'item_evil_god_chain_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/evil_god_chain.png',
    rarity: ItemRarity.mythic,
    flags: [ItemFlag.material],
  );

  static const Item abyssalShroudFragment = Item(
    id: 'abyssal_shroud_fragment',
    nameKey: 'item_abyssal_shroud_fragment_name',
    descKey: 'item_abyssal_shroud_fragment_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/abyssal_shroud_fragment.png',
    rarity: ItemRarity.mythic,
    flags: [ItemFlag.material],
  );

  static const Item playersOwnBlood = Item(
    id: 'players_own_blood',
    nameKey: 'item_players_own_blood_name',
    descKey: 'item_players_own_blood_desc',
    group: ItemGroup.material,
    iconPath: 'assets/images/items/material/players_own_blood.png',
    rarity: ItemRarity.mythic,
    flags: [ItemFlag.material],
  );

  /// Lồng Đèn Xương – Vật phẩm độc nhất, không bao giờ biến mất.
  /// Độ Sáng được quản lý qua Character.lanternDurability.
  static const Item boneLantern = Item(
    id: 'bone_lantern',
    nameKey: 'item_bone_lantern_name',
    descKey: 'item_bone_lantern_desc',
    group: ItemGroup.core,
    iconPath: 'assets/images/items/icon_bone_lantern.png',
    rarity: ItemRarity.mythic,
    flags: [ItemFlag.passive],
    isUnique: true,
  );

  // ── Danh sách tổng hợp ────────────────────────────────────────────────────

  static const List<Item> all = [
    boneLantern,
    // ── Vật liệu chế tạo ──
    roughIronScrap,
    rustyNail,
    oldGrindstone,
    brokenArmorPiece,
    ironChains,
    steelOre,
    blastPowderJar,
    pureSilverOre,
    mechanicalComponents,
    rareSteelOre,
    pureGoldBlock,
    // ── Nguyên liệu hữu cơ & sinh học ──
    rawAnimalHide,
    thornyRopeCoil,
    animalFat,
    mudAndLeaves,
    thickWarmFur,
    resin,
    leatherStrap,
    hardOakWood,
    beastBloodVial,
    stickyTar,
    mutatedBeastTendon,
    beastHorn,
    beastBoneRemnant,
    eliteMonsterHide,
    bloodCrystal,
    wraithHair,
    brokenHolyRelic,
    brokenSilverChalice,
    dreamIncensePowder,
    nightmareFruit,
    cleansingTear,
    quartzClockworkParts,
    boneLanternFire,
    brokenRoyalSword,
    rustedKingArmor,
    petrifiedRoot,
    weepingBowFrame,
    goliathRuinedArmor,
    goldDustedShieldFragment,
    evilGodChain,
    abyssalShroudFragment,
    playersOwnBlood,
  ];

  /// Tra cứu vật phẩm theo [id]. Trả về null nếu không tìm thấy.
  static Item? byId(String id) {
    for (final item in all) {
      if (item.id == id) return item;
    }
    return null;
  }
}
