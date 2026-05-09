import 'dart:async';

import 'package:flutter/material.dart';
import 'package:one_hundred_sunless_days/l10n/app_strings.dart';
import 'package:one_hundred_sunless_days/models/character.dart';
import 'package:one_hundred_sunless_days/models/inventory.dart';
import 'package:one_hundred_sunless_days/models/item.dart';
import 'package:one_hundred_sunless_days/models/lantern.dart';
import 'package:one_hundred_sunless_days/widgets/game_toast.dart';

// ────────────────────────────────────────────────────────────────────────────
// Bảng Nhân Vật (overlay toàn màn hình)
// ────────────────────────────────────────────────────────────────────────────

class CharacterPanel extends StatefulWidget {
  final Character character;
  final VoidCallback onClose;

  const CharacterPanel({
    super.key,
    required this.character,
    required this.onClose,
  });

  @override
  State<CharacterPanel> createState() => _CharacterPanelState();
}

class _CharacterPanelState extends State<CharacterPanel> {
  // 0 = Trang bị, 1 = Balo, 2 = Chỉ số, 3 = Kỹ năng
  int _tab = 0;
  // Key của chỉ số đang mở chú thích (null = không có)
  String? _expandedStatKey;
  // Vật phẩm đang được chọn để xem chi tiết trong Balo
  InventoryEntry? _selectedEntry;
  // Toast thông báo kết quả sử dụng vật phẩm
  String? _toastMessage;
  Timer? _toastTimer;

  static const List<String> _tabKeys = [
    'charTabEquip',
    'charTabBag',
    'charTabStats',
    'charTabSkills',
  ];

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  /// Hiển thị thông báo toast trong 3 giây rồi tự ẩn.
  void _showToast(String message) {
    _toastTimer?.cancel();
    setState(() => _toastMessage = message);
    _toastTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _toastMessage = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Nền panel + nội dung ──────────────────────────────────────
        Container(
          color: const Color(0xF2060606),
          child: Column(
            children: [
              // ── Tiêu đề & nút đóng ──────────────────────────────────
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.get('charPanelTitle'),
                        style: const TextStyle(
                          fontFamily: 'GnuUnifont',
                          fontSize: 15,
                          color: Color(0xFFD4A843),
                          letterSpacing: 3,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onClose,
                        child: const Text(
                          '[ X ]',
                          style: TextStyle(
                            fontFamily: 'GnuUnifont',
                            fontSize: 13,
                            color: Color(0xFF6A5A38),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Thanh tab ────────────────────────────────────────────
              const SizedBox(height: 10),
              Row(
                children: List.generate(_tabKeys.length, (i) {
                  final bool active = i == _tab;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tab = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: active
                              ? const Color(0xFF1A1206)
                              : Colors.transparent,
                          border: Border(
                            bottom: BorderSide(
                              color: active
                                  ? const Color(0xFFD4A843)
                                  : const Color(0xFF2A2010),
                              width: active ? 2 : 1,
                            ),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          AppStrings.get(_tabKeys[i]),
                          style: TextStyle(
                            fontFamily: 'GnuUnifont',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: active
                                ? const Color(0xFFD4A843)
                                : const Color(0xFFA08050),
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              // ── Nội dung tab ─────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildTabContent(),
                ),
              ),
            ],
          ),
        ),

        // ── Toast thông báo ───────────────────────────────────────────
        if (_toastMessage != null)
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: GameToast(message: _toastMessage!),
          ),
      ],
    );
  }

  Widget _buildTabContent() {
    switch (_tab) {
      case 0:
        return _buildEquipTab();
      case 1:
        return _buildBagTab();
      case 2:
        return _buildStatsTab();
      case 3:
        return _buildSkillsTab();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Tab Trang Bị ──────────────────────────────────────────────────────────

  Widget _buildEquipTab() {
    final c = widget.character;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _EquipSlot(
            label: AppStrings.get('charEquipWeapon'),
            equipped: c.equippedWeapon,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _EquipSlot(
            label: AppStrings.get('charEquipArmor'),
            equipped: c.equippedArmor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _EquipSlot(label: AppStrings.get('charEquipAccessory')),
        ),
      ],
    );
  }

  // ── Tab Balo ──────────────────────────────────────────────────────────────

  Widget _buildBagTab() {
    final inv = widget.character.inventory;
    final consumables = inv.consumables;
    final equipment = inv.equipment;

    // Nếu đang xem chi tiết vật phẩm → hiển thị panel chi tiết
    if (_selectedEntry != null) {
      return _buildItemDetail(_selectedEntry!);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Vật phẩm tiêu hao ─────────────────────────────────────────
        _GroupHeader(AppStrings.get('bagConsumables')),
        const SizedBox(height: 8),
        if (consumables.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              AppStrings.get('bagEmpty'),
              style: const TextStyle(
                fontFamily: 'GnuUnifont',
                fontSize: 11,
                color: Color(0xFF4A3A28),
              ),
            ),
          )
        else
          ...consumables.map((e) => _buildItemRow(e)),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: Color(0xFF2A2010), height: 1),
        ),

        // ── Trang bị & vật liệu ───────────────────────────────────────
        _GroupHeader(AppStrings.get('bagEquipment')),
        const SizedBox(height: 8),
        if (equipment.isEmpty)
          Text(
            AppStrings.get('bagEmpty'),
            style: const TextStyle(
              fontFamily: 'GnuUnifont',
              fontSize: 11,
              color: Color(0xFF4A3A28),
            ),
          )
        else
          ...equipment.map((e) => _buildItemRow(e)),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Một hàng vật phẩm trong danh sách balo.
  Widget _buildItemRow(InventoryEntry entry) {
    final item = entry.item;
    final bool isUnique = item.isUnique;
    return GestureDetector(
      onTap: () => setState(() => _selectedEntry = entry),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            // Icon vật phẩm (viền vàng đôi cho vật phẩm độc nhất)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: isUnique
                    ? Border.all(color: const Color(0xFFD4A843), width: 2)
                    : Border.all(color: const Color(0xFF2A2010), width: 1),
                color: const Color(0xFF0D0D0D),
              ),
              child: Stack(
                children: [
                  if (item.iconPath != null)
                    Image.asset(
                      item.iconPath!,
                      filterQuality: FilterQuality.none,
                      fit: BoxFit.contain,
                      width: 40,
                      height: 40,
                    )
                  else
                    const Icon(Icons.inventory_2_outlined,
                        size: 20, color: Color(0xFF4A3A28)),
                  // Nhãn "✦" ở góc dưới cho vật phẩm độc nhất
                  if (isUnique)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: const Color(0xCCD4A843),
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: const Text(
                          '✦',
                          style: TextStyle(
                            fontFamily: 'GnuUnifont',
                            fontSize: 7,
                            color: Color(0xFF0A0A0A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Tên vật phẩm
            Expanded(
              child: Text(
                AppStrings.get(item.nameKey),
                style: TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 12,
                  color: item.rarity == ItemRarity.common
                      ? const Color(0xFFCEC8B0)
                      : _rarityColor(item.rarity),
                ),
              ),
            ),
            // Số lượng (không hiện ×1 cho độc nhất)
            if (!isUnique)
              Text(
                '×${entry.quantity}',
                style: const TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 12,
                  color: Color(0xFFD4A843),
                ),
              ),
            const SizedBox(width: 4),
            // Mũi tên chỉ dẫn
            const Text(
              '?',
              style: TextStyle(
                fontFamily: 'GnuUnifont',
                fontSize: 9,
                color: Color(0xFF6A5A38),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Panel chi tiết vật phẩm được chọn.
  Widget _buildItemDetail(InventoryEntry entry) {
    final item = entry.item;
    final c = widget.character;
    final bool isEquipable =
        item.group == ItemGroup.weapon || item.group == ItemGroup.armor;
    final bool isEquipped = isEquipable &&
        ((item.group == ItemGroup.weapon && c.equippedWeapon?.id == item.id) ||
            (item.group == ItemGroup.armor && c.equippedArmor?.id == item.id));
    final bool canUse = !isEquipable &&
        !item.hasFlag(ItemFlag.material) &&
        !item.hasFlag(ItemFlag.passive) &&
        !item.hasFlag(ItemFlag.combatOnly);
    final String? blockReason = canUse ? _useBlockReason(c, item) : null;
    final bool blocked = blockReason != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nút quay lại
        GestureDetector(
          onTap: () => setState(() => _selectedEntry = null),
          child: Row(
            children: [
              const Text(
                '◂',
                style: TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 11,
                  color: Color(0xFF6A5A38),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                AppStrings.get('bagBack'),
                style: const TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 11,
                  color: Color(0xFF6A5A38),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Icon lớn + tên
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                border: item.rarity == ItemRarity.common
                    ? Border.all(color: const Color(0xFF2A2010), width: 1)
                    : Border.all(color: _rarityColor(item.rarity), width: 2),
                color: const Color(0xFF0D0D0D),
              ),
              child: item.iconPath != null
                  ? Image.asset(
                      item.iconPath!,
                      filterQuality: FilterQuality.none,
                      fit: BoxFit.contain,
                    )
                  : const Icon(Icons.inventory_2_outlined,
                      size: 32, color: Color(0xFF4A3A28)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.get(item.nameKey),
                    style: const TextStyle(
                      fontFamily: 'GnuUnifont',
                      fontSize: 13,
                      color: Color(0xFFD4A843),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.isUnique
                        ? '✦ ${AppStrings.get('itemRarityUnique')}  |  ${_groupLabel(item.group)}'
                        : '${_rarityLabel(item.rarity)}  |  ${_groupLabel(item.group)}',
                    style: TextStyle(
                      fontFamily: 'GnuUnifont',
                      fontSize: 10,
                      color: item.rarity == ItemRarity.common
                          ? const Color(0xFF6A5A38)
                          : _rarityColor(item.rarity),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Mô tả
        Text(
          AppStrings.get(item.descKey),
          style: const TextStyle(
            fontFamily: 'GnuUnifont',
            fontSize: 10,
            color: Color(0xFF8A8478),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),

        // Panel tiếp nhiên liệu (chỉ cho Lồng Đèn Xương)
        if (item.id == 'bone_lantern') ...[
          _buildRefuelPanel(c),
          const SizedBox(height: 16),
        ],

        // Hiệu ứng chính
        if (item.healsToFull)
          _EffectLine('+', AppStrings.get('itemEffectHealFull')),
        // Bonus vũ khí/giáp
        if (item.atkBonus > 0)
          _EffectLine('+', '${AppStrings.get('charStatAttack')}  +${item.atkBonus}'),
        if (item.defBonus > 0)
          _EffectLine('+', '${AppStrings.get('charStatDef')}  +${item.defBonus}'),
        if (item.maxHpBonus > 0)
          _EffectLine('+', 'Max HP  +${item.maxHpBonus}'),
        // Đặc điểm vũ khí
        if (item.bleedOnBioHitChance > 0)
          _EffectLine('★',
              '${AppStrings.get('itemStatBleedOnCrit')}: ${(item.bleedOnBioHitChance * 100).round()}%',
              positive: true),
        if (item.glancingHitChance > 0)
          _EffectLine('!',
              '${AppStrings.get('itemStatGlancingHit')}: ${(item.glancingHitChance * 100).round()}% cơ hội giảm 50% sát thương',
              positive: false),
        if (item.trainingWeaponAccidentBonus > 0)
          _EffectLine('!',
              '${AppStrings.get('itemStatTrainRisk')}: +${(item.trainingWeaponAccidentBonus * 100).round()}%',
              positive: false),
        // Đặc điểm áo giáp
        if (item.infectionHpDrainBonus > 0)
          _EffectLine('!',
              '${AppStrings.get('itemStatInfectionDrain')}: +${item.infectionHpDrainBonus} HP/ngày',
              positive: false),
        if (item.armorPierceChance > 0)
          _EffectLine('!',
              'Đột giáp: ${(item.armorPierceChance * 100).round()}% bỏ qua DEF',
              positive: false),
        if (item.isHeavy)
          _EffectLine('!', 'Vũ khí Nặng – giảm tốc độ ra đòn', positive: false),
        for (final fx in item.effects)
          _EffectLine(
            fx.amount >= 0 ? '+' : '',
            _statChangeLabel(fx),
            positive: fx.amount >= 0,
          ),

        // Tác dụng phụ
        for (final fx in item.sideEffects)
          _EffectLine('', _statChangeLabel(fx), positive: fx.amount >= 0),

        // Drains to zero
        if (item.drainsToZero.isNotEmpty)
          _EffectLine('', AppStrings.get('itemEffectDrainStamina'),
              positive: false),

        // Cờ đặc biệt (ẩn passive cho vũ khí/giáp)
        if (item.hasFlag(ItemFlag.noTurnCost))
          _EffectLine('★', AppStrings.get('itemFlagNoTurnCost'), positive: true),
        if (item.hasFlag(ItemFlag.passive) && !isEquipable)
          _EffectLine('★', AppStrings.get('itemFlagPassive'), positive: true),
        if (item.hasFlag(ItemFlag.combatOnly))
          _EffectLine('★', AppStrings.get('itemFlagCombatOnly'), positive: true),
        if (item.blocksLethalHit)
          _EffectLine('★', AppStrings.get('itemFlagBlockLethal'), positive: true),
        if (item.preventNightRaid)
          _EffectLine('★', AppStrings.get('itemFlagNoNightRaid'), positive: true),

        const SizedBox(height: 24),

        // Nút Trang Bị (cho vũ khí/giáp)
        if (isEquipable)
          GestureDetector(
            onTap: () => _equipItem(entry),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isEquipped
                      ? const Color(0xFF3A5030)
                      : const Color(0xFFD4A843),
                  width: 1,
                ),
                color: isEquipped
                    ? const Color(0xFF0A1A0A)
                    : Colors.transparent,
              ),
              child: Text(
                isEquipped
                    ? AppStrings.get('itemUnequip')
                    : AppStrings.get('itemEquip'),
                style: TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 13,
                  color: isEquipped
                      ? const Color(0xFF66AA66)
                      : const Color(0xFFD4A843),
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

        // Nút Sử Dụng (cho vật phẩm tiêu hao)
        if (canUse)
          GestureDetector(
            onTap: () => _useItem(entry),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: blocked
                      ? const Color(0xFF3A3020)
                      : const Color(0xFFD4A843),
                  width: 1,
                ),
              ),
              child: Text(
                AppStrings.get('itemUse'),
                style: TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 13,
                  color: blocked
                      ? const Color(0xFF4A3A28)
                      : const Color(0xFFD4A843),
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        if (blocked && blockReason != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              blockReason,
              style: const TextStyle(
                fontFamily: 'GnuUnifont',
                fontSize: 10,
                color: Color(0xFF6A5A38),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        if (item.hasFlag(ItemFlag.combatOnly))
          Text(
            AppStrings.get('itemOnlyInCombat'),
            style: const TextStyle(
              fontFamily: 'GnuUnifont',
              fontSize: 10,
              color: Color(0xFF6A5A38),
            ),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Panel tiếp nhiên liệu cho Lồng Đèn Xương.
  Widget _buildRefuelPanel(Character c) {
    final bool canRefuel =
        LanternSystem.canRefuel(c.embers) && c.lanternDurability < 100;
    final int maxTimes = c.embers ~/ LanternSystem.refuelEmberCost;
    final int clampedTimes = maxTimes.clamp(
        0,
        (100 - c.lanternDurability) ~/ LanternSystem.refuelBrightnessGain);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF2A2010), width: 1),
        color: const Color(0xFF0D0D0D),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nhãn tiêu đề
          Text(
            AppStrings.get('lanternPanelTitle'),
            style: const TextStyle(
              fontFamily: 'GnuUnifont',
              fontSize: 11,
              color: Color(0xFFD4A843),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          // Thanh độ sáng + số
          Row(
            children: [
              Text(
                AppStrings.get('lanternBrightnessLabel'),
                style: const TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 10,
                  color: Color(0xFF8A8478),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 6,
                  child: Row(
                    children: [
                      if (c.lanternDurability > 0)
                        Flexible(
                          flex: c.lanternDurability,
                          child: Container(
                            color: c.lanternDurability >= 70
                                ? const Color(0xFFD4A843)
                                : c.lanternDurability >= 30
                                    ? const Color(0xFFCC8833)
                                    : const Color(0xFF882222),
                          ),
                        ),
                      if (c.lanternDurability < 100)
                        Flexible(
                          flex: 100 - c.lanternDurability,
                          child: Container(color: const Color(0xFF1A1A1A)),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${c.lanternDurability}%  ${AppStrings.get(LanternSystem.brightnessLabelKey(c.lanternDurability))}',
                style: const TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 10,
                  color: Color(0xFFD4A843),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Nút tiếp nhiên liệu
          GestureDetector(
            onTap: canRefuel
                ? () {
                    setState(() {
                      c.refuelLantern(times: clampedTimes.clamp(1, 99));
                    });
                  }
                : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: canRefuel
                      ? const Color(0xFFD4A843)
                      : const Color(0xFF3A3020),
                  width: 1,
                ),
              ),
              child: Text(
                '× ${LanternSystem.refuelEmberCost} ${AppStrings.get('lanternRefuelCost')}  →  +${LanternSystem.refuelBrightnessGain}% ${AppStrings.get('lanternBrightnessLabel')}',
                style: TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 11,
                  color: canRefuel
                      ? const Color(0xFFD4A843)
                      : const Color(0xFF4A3A28),
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (!canRefuel)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                c.lanternDurability >= 100
                    ? AppStrings.get('lanternFull')
                    : AppStrings.get('lanternNoEmbers'),
                style: const TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 10,
                  color: Color(0xFF6A5A38),
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  // ── Helpers: dùng vật phẩm ────────────────────────────────────────────────

  /// Trả về lý do tại sao không thể dùng vật phẩm, hoặc null nếu được dùng.
  String? _useBlockReason(Character c, Item item) {
    if (item.hasFlag(ItemFlag.combatOnly)) {
      return AppStrings.get('itemOnlyInCombat');
    }
    if (item.effects.isEmpty && !item.healsToFull) return null;

    final posEffects = item.effects.where((fx) => fx.amount > 0).toList();
    if (item.healsToFull && c.hp < c.maxHp) return null;
    if (item.healsToFull && posEffects.isEmpty && c.hp >= c.maxHp) {
      return AppStrings.get('itemStatAlreadyFull');
    }
    if (posEffects.isNotEmpty &&
        posEffects.every((fx) => _isStatFull(c, fx.stat))) {
      return AppStrings.get('itemStatAlreadyFull');
    }
    return null;
  }

  /// Kiểm tra xem stat đã đầy chưa.
  bool _isStatFull(Character c, StatId stat) {
    return switch (stat) {
      StatId.hp         => c.hp >= c.maxHp,
      StatId.stamina    => c.stamina >= c.maxStamina,
      StatId.hunger     => c.hunger >= c.maxHunger,
      StatId.sanity     => c.sanity >= 100,
      StatId.humanity   => c.humanity >= 100,
      StatId.maxHp      => false,
      StatId.maxStamina => false,
      StatId.embers     => false,
    };
  }

  /// Tạo chuỗi tóm tắt các thay đổi chỉ số sau khi dùng vật phẩm.
  String _buildItemToastText(Item item) {
    final parts = <String>[];
    if (item.healsToFull) {
      parts.add('${AppStrings.get('templeStatHp')} MAX');
    }
    for (final fx in [...item.effects, ...item.sideEffects]) {
      final name = _statShortName(fx.stat);
      final sign = fx.amount >= 0 ? '+' : '';
      parts.add('$name $sign${fx.amount}');
    }
    return parts.join('   ·   ');
  }

  /// Tên ngắn của một stat dùng trong toast.
  String _statShortName(StatId stat) {
    return switch (stat) {
      StatId.hp         => AppStrings.get('templeStatHp'),
      StatId.maxHp      => 'Max ${AppStrings.get('templeStatHp')}',
      StatId.stamina    => AppStrings.get('templeStatStamina'),
      StatId.maxStamina => 'Max ${AppStrings.get('templeStatStamina')}',
      StatId.hunger     => AppStrings.get('templeStatHunger'),
      StatId.sanity     => AppStrings.get('charStatSanity'),
      StatId.humanity   => AppStrings.get('charStatHumanity'),
      StatId.embers     => AppStrings.get('charStatEmbers'),
    };
  }

  /// Sử dụng vật phẩm và áp dụng hiệu ứng lên nhân vật.
  void _useItem(InventoryEntry entry) {
    final item = entry.item;
    final c = widget.character;
    final blockReason = _useBlockReason(c, item);
    if (blockReason != null) {
      _showToast(blockReason);
      return;
    }

    final toastText = _buildItemToastText(item);

    setState(() {
      // Hiệu ứng chính
      if (item.healsToFull) c.hp = c.maxHp;
      if (item.clearsAllDebuffs) { /* TODO: clear status effects */ }
      for (final fx in item.effects) {
        if (fx.durationDays == 0) _applyStatChange(c, fx);
      }
      // Tác dụng phụ
      for (final fx in item.sideEffects) {
        if (fx.durationDays == 0) _applyStatChange(c, fx);
      }
      // Drain
      for (final stat in item.drainsToZero) {
        if (stat == StatId.stamina) c.stamina = 0;
      }

      // Trừ số lượng; đóng panel nếu hết
      c.inventory.remove(item.id);
      if (!c.inventory.has(item.id)) {
        _selectedEntry = null;
      }
    });

    if (toastText.isNotEmpty) _showToast(toastText);
  }

  /// Trang bị hoặc tháo vũ khí/áo giáp.
  void _equipItem(InventoryEntry entry) {
    final item = entry.item;
    final c = widget.character;
    setState(() {
      if (item.group == ItemGroup.weapon) {
        if (c.equippedWeapon?.id == item.id) {
          c.equippedWeapon = null;
        } else {
          c.equippedWeapon = item;
        }
      } else if (item.group == ItemGroup.armor) {
        if (c.equippedArmor?.id == item.id) {
          c.equippedArmor = null;
        } else {
          c.equippedArmor = item;
        }
      }
    });
    final bool nowEquipped = (item.group == ItemGroup.weapon
        ? c.equippedWeapon?.id == item.id
        : c.equippedArmor?.id == item.id);
    _showToast(nowEquipped
        ? '${AppStrings.get('itemEquipped')}: ${AppStrings.get(item.nameKey)}'
        : AppStrings.get('itemUnequip'));
  }

  /// Áp dụng một StatChange tức thì lên nhân vật.
  void _applyStatChange(Character c, StatChange fx) {
    switch (fx.stat) {
      case StatId.hp:
        fx.amount >= 0 ? c.heal(fx.amount) : c.takeDamage(-fx.amount);
      case StatId.stamina:
        fx.amount >= 0
            ? c.restoreStamina(fx.amount)
            : c.consumeStamina(-fx.amount);
      case StatId.hunger:
        fx.amount >= 0
            ? c.eat(fx.amount)
            : c.hunger = (c.hunger + fx.amount).clamp(0, c.maxHunger);
      case StatId.sanity:
        c.sanity = (c.sanity + fx.amount).clamp(0, 100);
      case StatId.humanity:
        c.humanity = (c.humanity + fx.amount).clamp(0, 100);
      case StatId.maxHp:
        if (!fx.permanent) break;
        c.maxHp = (c.maxHp + fx.amount).clamp(1, 9999);
        if (c.hp > c.maxHp) c.hp = c.maxHp;
      case StatId.maxStamina:
        if (!fx.permanent) break;
        c.maxStamina = (c.maxStamina + fx.amount).clamp(1, 9999);
        if (c.stamina > c.maxStamina) c.stamina = c.maxStamina;
      case StatId.embers:
        c.embers = (c.embers + fx.amount).clamp(0, 99999);
    }
  }

  // ── Helpers: nhãn hiển thị ────────────────────────────────────────────────

  /// Nhãn hiển thị nhóm vật phẩm.
  String _groupLabel(ItemGroup g) {
    return switch (g) {
      ItemGroup.food    => AppStrings.get('groupFood'),
      ItemGroup.medical => AppStrings.get('groupMedical'),
      ItemGroup.mental  => AppStrings.get('groupMental'),
      ItemGroup.combat  => AppStrings.get('groupCombat'),
      ItemGroup.core    => AppStrings.get('groupCore'),
      ItemGroup.weapon    => AppStrings.get('groupWeapon'),
      ItemGroup.armor     => AppStrings.get('groupArmor'),
      ItemGroup.material  => AppStrings.get('groupMaterial'),
    };
  }

  /// Màu viền theo độ hiếm.
  Color _rarityColor(ItemRarity r) => switch (r) {
        ItemRarity.common    => const Color(0xFF2A2010),
        ItemRarity.uncommon  => const Color(0xFF44AA55), // xanh lá
        ItemRarity.rare      => const Color(0xFF4488CC), // xanh dương
        ItemRarity.epic      => const Color(0xFF9944CC), // tím
        ItemRarity.legendary => const Color(0xFFE87828), // cam
        ItemRarity.mythic    => const Color(0xFFCC3333), // đỏ
      };

  /// Nhãn độ hiếm để hiển thị trong panel chi tiết.
  String _rarityLabel(ItemRarity r) => switch (r) {
        ItemRarity.common    => AppStrings.get('itemRarityCommon'),
        ItemRarity.uncommon  => AppStrings.get('itemRarityUncommon'),
        ItemRarity.rare      => AppStrings.get('itemRarityRare'),
        ItemRarity.epic      => AppStrings.get('itemRarityEpic'),
        ItemRarity.legendary => AppStrings.get('itemRarityLegendary'),
        ItemRarity.mythic    => AppStrings.get('itemRarityMythic'),
      };

  /// Mô tả ngắn cho một StatChange.
  String _statChangeLabel(StatChange fx) {
    final sign = fx.amount >= 0 ? '+' : '';
    final statName = switch (fx.stat) {
      StatId.hp         => AppStrings.get('templeStatHp'),
      StatId.maxHp      => 'Max ${AppStrings.get('templeStatHp')}',
      StatId.stamina    => AppStrings.get('templeStatStamina'),
      StatId.maxStamina => 'Max ${AppStrings.get('templeStatStamina')}',
      StatId.hunger     => AppStrings.get('templeStatHunger'),
      StatId.sanity     => AppStrings.get('charStatSanity'),
      StatId.humanity   => AppStrings.get('charStatHumanity'),
      StatId.embers     => AppStrings.get('charStatEmbers'),
    };
    final suffix =
        fx.chance < 1.0 ? '  (${(fx.chance * 100).round()}%)' : '';
    final dur = fx.durationDays > 0 ? '  [${fx.durationDays}d]' : '';
    return '$statName  $sign${fx.amount}$dur$suffix';
  }

  // ── Tab Chỉ Số ────────────────────────────────────────────────────────────

  Widget _buildStatsTab() {
    final Character c = widget.character;

    void toggle(String key) =>
        setState(() => _expandedStatKey = _expandedStatKey == key ? null : key);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Nhóm: Sinh Tồn ────────────────────────────────────────────
        _GroupHeader(AppStrings.get('charGroupVitals')),
        const SizedBox(height: 8),
        _StatRow(
          label: AppStrings.get('templeStatHp'),
          value: c.hp,
          max: c.maxHp,
          color: const Color(0xFFCC3333),
          showFraction: true,
          desc: AppStrings.get('charDescHp'),
          isExpanded: _expandedStatKey == 'hp',
          onTap: () => toggle('hp'),
        ),
        _StatRow(
          label: AppStrings.get('templeStatStamina'),
          value: c.stamina,
          max: c.maxStamina,
          color: const Color(0xFF3388CC),
          showFraction: true,
          desc: AppStrings.get('charDescStamina'),
          isExpanded: _expandedStatKey == 'stamina',
          onTap: () => toggle('stamina'),
        ),
        _StatRow(
          label: AppStrings.get('templeStatHunger'),
          value: c.hunger,
          max: c.maxHunger,
          color: c.isStarving
              ? const Color(0xFFCC6633)
              : const Color(0xFF88AA44),
          showFraction: true,
          desc: AppStrings.get('charDescHunger'),
          isExpanded: _expandedStatKey == 'hunger',
          onTap: () => toggle('hunger'),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: Color(0xFF2A2010), height: 1),
        ),

        // ── Nhóm: Chỉ Số Cơ Bản ──────────────────────────────────────
        _GroupHeader(AppStrings.get('charGroupPrimary')),
        const SizedBox(height: 8),
        _StatRow(
          label: AppStrings.get('charStatStr'),
          value: c.str,
          max: 100,
          color: const Color(0xFFCC6644),
          desc: AppStrings.get('charDescStr'),
          isExpanded: _expandedStatKey == 'str',
          onTap: () => toggle('str'),
        ),
        _StatRow(
          label: AppStrings.get('charStatAgi'),
          value: c.agi,
          max: 100,
          color: const Color(0xFF4488CC),
          desc: AppStrings.get('charDescAgi'),
          isExpanded: _expandedStatKey == 'agi',
          onTap: () => toggle('agi'),
        ),
        _StatRow(
          label: AppStrings.get('charStatVit'),
          value: c.vit,
          max: 100,
          color: const Color(0xFF44AA66),
          desc: AppStrings.get('charDescVit'),
          isExpanded: _expandedStatKey == 'vit',
          onTap: () => toggle('vit'),
        ),
        _StatRow(
          label: AppStrings.get('charStatWill'),
          value: c.will,
          max: 100,
          color: const Color(0xFFCC88CC),
          desc: AppStrings.get('charDescWill'),
          isExpanded: _expandedStatKey == 'will',
          onTap: () => toggle('will'),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(color: Color(0xFF2A2010), height: 1),
        ),

        // ── Chỉ Số Tổng Hợp ──────────────────────────────────────────
        _StatRow(
          label: AppStrings.get('charStatAttack'),
          value: c.totalAttack,
          max: null,
          color: const Color(0xFFCC6644),
          desc: AppStrings.get('charDescAttack'),
          isExpanded: _expandedStatKey == 'attack',
          onTap: () => toggle('attack'),
        ),
        _StatRow(
          label: AppStrings.get('charStatDef'),
          value: c.totalDefense,
          max: null,
          color: const Color(0xFF778899),
          desc: AppStrings.get('charDescDefTotal'),
          isExpanded: _expandedStatKey == 'def',
          onTap: () => toggle('def'),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: Color(0xFF2A2010), height: 1),
        ),

        // ── Nhóm: Thuộc Tính Ẩn ──────────────────────────────────────
        _GroupHeader(AppStrings.get('charGroupHidden')),
        const SizedBox(height: 8),
        _StatRow(
          label: AppStrings.get('charStatHumanity'),
          value: c.humanity,
          max: 100,
          color: const Color(0xFF8888CC),
          desc: AppStrings.get('charDescHumanity'),
          isExpanded: _expandedStatKey == 'humanity',
          onTap: () => toggle('humanity'),
        ),
        _StatRow(
          label: AppStrings.get('charStatSanity'),
          value: c.sanity,
          max: 100,
          color: const Color(0xFF88AACC),
          desc: AppStrings.get('charDescSanity'),
          isExpanded: _expandedStatKey == 'sanity',
          onTap: () => toggle('sanity'),
        ),

        // Cảnh Giới – tappable text row
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => toggle('realm'),
          behavior: HitTestBehavior.opaque,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        AppStrings.get('charStatRealm'),
                        style: const TextStyle(
                          fontFamily: 'GnuUnifont',
                          fontSize: 13,
                          color: Color(0xFFCEC8B0),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _expandedStatKey == 'realm' ? '▾' : '▸',
                        style: const TextStyle(
                          fontFamily: 'GnuUnifont',
                          fontSize: 9,
                          color: Color(0xFF6A5A38),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _realmName(c.realm),
                    style: const TextStyle(
                      fontFamily: 'GnuUnifont',
                      fontSize: 11,
                      color: Color(0xFFD4A843),
                    ),
                  ),
                ],
              ),
              if (_expandedStatKey == 'realm') ...[
                const SizedBox(height: 6),
                Text(
                  AppStrings.get('charDescRealm'),
                  style: const TextStyle(
                    fontFamily: 'GnuUnifont',
                    fontSize: 10,
                    color: Color(0xFF8A8478),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: Color(0xFF2A2010), height: 1),
        ),

        // ── Tro Tàn ───────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.get('charStatEmbers'),
              style: const TextStyle(
                fontFamily: 'GnuUnifont',
                fontSize: 13,
                color: Color(0xFFCEC8B0),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/items/ash_currency.png',
                  width: 16,
                  height: 16,
                  filterQuality: FilterQuality.none,
                ),
                const SizedBox(width: 4),
                Text(
                  '${c.embers}',
                  style: const TextStyle(
                    fontFamily: 'GnuUnifont',
                    fontSize: 13,
                    color: Color(0xFFD4A843),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Chuyển cấp Cảnh Giới sang chuỗi tên.
  String _realmName(int realm) {
    return switch (realm) {
      1 => AppStrings.get('charRealmRank1'),
      2 => AppStrings.get('charRealmRank2'),
      3 => AppStrings.get('charRealmRank3'),
      _ => AppStrings.get('charRealmRank1'),
    };
  }

  // ── Tab Kỹ Năng ───────────────────────────────────────────────────────────

  Widget _buildSkillsTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Text(
          AppStrings.get('charSkillsEmpty'),
          style: const TextStyle(
            fontFamily: 'GnuUnifont',
            fontSize: 13,
            color: Color(0xFF4A3A28),
            height: 1.9,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Ô trang bị (vũ khí / giáp / phụ kiện)
// ────────────────────────────────────────────────────────────────────────────

class _EquipSlot extends StatelessWidget {
  final String label;
  final Item? equipped;

  const _EquipSlot({required this.label, this.equipped});

  @override
  Widget build(BuildContext context) {
    final bool hasItem = equipped != null;
    return Column(
      children: [
        Container(
          height: 68,
          decoration: BoxDecoration(
            border: Border.all(
              color: hasItem ? const Color(0xFFD4A843) : const Color(0xFF2A2010),
              width: hasItem ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: hasItem
              ? (equipped!.iconPath != null
                  ? Image.asset(
                      equipped!.iconPath!,
                      width: 40,
                      height: 40,
                      filterQuality: FilterQuality.none,
                      fit: BoxFit.contain,
                    )
                  : const Icon(Icons.shield_outlined,
                      size: 28, color: Color(0xFFD4A843)))
              : Text(
                  AppStrings.get('charEquipEmpty'),
                  style: const TextStyle(
                    fontFamily: 'GnuUnifont',
                    fontSize: 10,
                    color: Color(0xFF4A3A28),
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          hasItem ? AppStrings.get(equipped!.nameKey) : label,
          style: TextStyle(
            fontFamily: 'GnuUnifont',
            fontSize: 9,
            color: hasItem ? const Color(0xFFD4A843) : const Color(0xFF6A5A38),
            letterSpacing: 1,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Hàng chỉ số trong bảng Stats
// ────────────────────────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  final String label;
  final int value;
  /// null = không có thanh tiến trình (chỉ số không giới hạn bởi cap).
  final int? max;
  final Color color;
  final bool showFraction;
  /// Chú thích – hiện khi isExpanded = true.
  final String? desc;
  final bool isExpanded;
  final VoidCallback? onTap;

  const _StatRow({
    required this.label,
    required this.value,
    required this.max,
    this.color = const Color(0xFFD4A843),
    this.showFraction = false,
    this.desc,
    this.isExpanded = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double ratio = (max != null && max! > 0)
        ? (value / max!).clamp(0.0, 1.0)
        : 0.0;
    final String valueText =
        (showFraction && max != null) ? '$value/$max' : '$value';

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Nhãn + mũi tên chỉ báo
                SizedBox(
                  width: 96,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontFamily: 'GnuUnifont',
                            fontSize: 12,
                            color: Color(0xFFCEC8B0),
                          ),
                        ),
                      ),
                      if (desc != null)
                        Text(
                          isExpanded ? '▾' : '▸',
                          style: const TextStyle(
                            fontFamily: 'GnuUnifont',
                            fontSize: 9,
                            color: Color(0xFF6A5A38),
                          ),
                        ),
                    ],
                  ),
                ),
                // Thanh tiến trình (ẩn nếu max == null)
                Expanded(
                  child: max == null
                      ? const SizedBox()
                      : Container(
                          height: 7,
                          color: const Color(0xFF1A1A1A),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: ratio,
                              child: Container(color: color),
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                // Giá trị
                SizedBox(
                  width: 44,
                  child: Text(
                    valueText,
                    style: const TextStyle(
                      fontFamily: 'GnuUnifont',
                      fontSize: 11,
                      color: Color(0xFFCEC8B0),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            // Chú thích – chỉ hiển thị khi isExpanded
            if (isExpanded && desc != null) ...[
              const SizedBox(height: 6),
              Text(
                desc!,
                style: const TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 10,
                  color: Color(0xFF8A8478),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 4),
            ],
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Widget tiêu đề nhóm chỉ số
// ────────────────────────────────────────────────────────────────────────────

class _GroupHeader extends StatelessWidget {
  final String title;
  const _GroupHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'GnuUnifont',
        fontSize: 10,
        color: Color(0xFFD4A843),
        letterSpacing: 1.5,
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Dòng hiệu ứng trong chi tiết vật phẩm
// ────────────────────────────────────────────────────────────────────────────

class _EffectLine extends StatelessWidget {
  final String prefix;
  final String text;
  final bool positive;

  const _EffectLine(this.prefix, this.text, {this.positive = true});

  @override
  Widget build(BuildContext context) {
    final color =
        positive ? const Color(0xFF88AA66) : const Color(0xFFCC5544);
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 14,
            child: Text(
              prefix,
              style: TextStyle(
                fontFamily: 'GnuUnifont',
                fontSize: 11,
                color: color,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'GnuUnifont',
                fontSize: 11,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
