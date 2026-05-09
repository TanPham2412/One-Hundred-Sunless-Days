import 'dart:math';

import 'package:flutter/material.dart';
import 'package:one_hundred_sunless_days/l10n/app_strings.dart';
import 'package:one_hundred_sunless_days/models/character.dart';
import 'package:one_hundred_sunless_days/models/item.dart';
import 'package:one_hundred_sunless_days/models/travel_event.dart';
import 'package:one_hundred_sunless_days/widgets/character_panel.dart';

// ────────────────────────────────────────────────────────────────────────────
// Màn hình Khám Phá (Explore Screen)
// ────────────────────────────────────────────────────────────────────────────

enum _ExploreStep { categorySelect, areaSelect, traveling, eventDisplay, eventOutcome, arrived }

/// Danh mục vật phẩm người chơi muốn tìm kiếm.
enum ExploreCategory { food, medical, mental, combat, equipment }

class ExploreScreen extends StatefulWidget {
  final Character character;
  final VoidCallback onReturnToSafehouse;
  final VoidCallback? onTriggerCombat;

  const ExploreScreen({
    super.key,
    required this.character,
    required this.onReturnToSafehouse,
    this.onTriggerCombat,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  _ExploreStep _step = _ExploreStep.categorySelect;
  ExploreCategory? _selectedCategory;
  String? _selectedArea;
  int _travelSteps = 0;            // số lượt đã di chuyển
  TravelEventType? _pendingEvent;   // sự kiện chờ xử lý
  bool _arrivedAfterEvent = false;  // có đến nơi sau khi xử lý sự kiện
  EventOutcome? _resolvedOutcome;   // kết quả lựa chọn đã roll
  bool _combatTriggered = false;    // kết quả trigger combat

  // ── Animation cho outcome screen (giống rest/training) ──────────────────
  // 0 = chưa có gì; 1 = desc hiện; 2+ = effect[i-2] hiện
  int _outcomeVisibleParts = 0;
  bool _outcomeShowButton = false;

  // ── Bảng chỉ số nhân vật ────────────────────────────────────────────────
  bool _showCharPanel = false;

  // ── Vật phẩm ngẫu nhiên đã nhận (để hiển thị trong outcome) ────────────
  List<Item> _grantedMaterials = [];
  Item? _grantedEpic;

  // ── Animation cho event display screen ──────────────────────────────────
  // 0 = chưa gì; 1 = title+desc; 2+ = choice[i-2]
  int _eventVisibleParts = 0;

  static const int _staminaCostPerStep  = 5;
  static const int _lanternCostPerStep  = 5;

  void _selectCategory(ExploreCategory cat) {
    setState(() {
      _selectedCategory = cat;
      _step = _ExploreStep.areaSelect;
    });
  }

  void _goBack() {
    setState(() {
      switch (_step) {
        case _ExploreStep.areaSelect:
          _step = _ExploreStep.categorySelect;
          _selectedCategory = null;
        case _ExploreStep.traveling:
          // quay về safehouse vì đã tiêu tài nguyên
          widget.onReturnToSafehouse();
        default:
          break;
      }
    });
  }

  void _selectArea(String areaKey) {
    setState(() {
      _selectedArea = areaKey;
      _travelSteps  = 0;
      _step         = _ExploreStep.traveling;
    });
  }

  /// Mỗi lượt: trừ Thể Lực + Độ Sáng, rồi roll xem có đến nơi chưa.
  /// Bước 1 = 10%, bước 2 = 15%, bước 3 = 20%, ... cộng dồn 5% mỗi bước, tối đa 100%.
  void _advanceTravel() {
    final c = widget.character;
    if (c.stamina < _staminaCostPerStep) return;

    final rng = Random();
    setState(() {
      c.stamina            = (c.stamina - _staminaCostPerStep).clamp(0, c.maxStamina);
      c.lanternDurability  = (c.lanternDurability - _lanternCostPerStep).clamp(0, 100);
      _travelSteps++;

      final chance         = ((5 + _travelSteps * 5) / 100).clamp(0.0, 1.0);
      final roll           = rng.nextDouble();
      _arrivedAfterEvent   = roll < chance;
      _pendingEvent        = TravelEventSystem.rollEvent(rng);
      _step                = _ExploreStep.eventDisplay;
    });
    _startEventSequence();
  }

  void _acknowledgeEvent() {
    setState(() {
      _pendingEvent = null;
      _eventVisibleParts = 0;
      _step = _arrivedAfterEvent ? _ExploreStep.arrived : _ExploreStep.traveling;
    });
  }

  /// Animate từng phần của event display screen theo trình tự.
  void _startEventSequence() async {
    final event = TravelEventSystem.forType(_pendingEvent!);
    final choiceCount = event.choices?.length ?? 0;
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    setState(() => _eventVisibleParts = 1);
    for (int i = 0; i < choiceCount; i++) {
      await Future.delayed(const Duration(milliseconds: 170));
      if (!mounted) return;
      setState(() => _eventVisibleParts = i + 2);
    }
  }

  void _selectChoice(EventChoice choice) {
    if (choice.isContinue) {
      _acknowledgeEvent();
      return;
    }
    if (choice.outcomes == null) return; // placeholder, disabled

    final outcome = choice.rollOutcome(Random());
    if (outcome == null) return;

    final c = widget.character;
    bool combat = false;
    List<Item> grantedMats = [];
    Item? grantedEpic;
    for (final e in outcome.effects) {
      switch (e.type) {
        case OutcomeEffectType.gainLantern:
          c.lanternDurability = (c.lanternDurability + e.value).clamp(0, 100);
        case OutcomeEffectType.gainStamina:
          c.stamina = (c.stamina + e.value).clamp(0, c.maxStamina);
        case OutcomeEffectType.loseSanity:
          c.sanity = (c.sanity - e.value).clamp(0, c.maxSanity);
        case OutcomeEffectType.loseStamina:
          c.stamina = (c.stamina - e.value).clamp(0, c.maxStamina);
        case OutcomeEffectType.triggerCombat:
          combat = true;
        case OutcomeEffectType.gainSanity:
          c.sanity = (c.sanity + e.value).clamp(0, c.maxSanity);
        case OutcomeEffectType.gainFullSanity:
          c.sanity = c.maxSanity;
        case OutcomeEffectType.loseHp:
          c.hp = (c.hp - e.value).clamp(0, c.maxHp);
        case OutcomeEffectType.loseMaxHp:
          c.maxHp = (c.maxHp - e.value).clamp(1, 999);
          c.hp = c.hp.clamp(0, c.maxHp);
        case OutcomeEffectType.applyPoison:
          c.poisonedTurnsRemaining = e.value > 0 ? e.value : 3;
        case OutcomeEffectType.applyBleeding:
          if (c.bleedTurnsRemaining == 0) {
            c.bleedTurnsRemaining = 3;
            c.bleedDamagePerTurn = 2;
          }
        case OutcomeEffectType.applyBloodlust:
          c.bloodlustTurnsRemaining = e.value > 0 ? e.value : 3;
        case OutcomeEffectType.gainRandomMaterials:
          grantedMats = _grantRandomMaterials(c, e.value);
        case OutcomeEffectType.gainRandomEpicMaterial:
          grantedEpic = _grantRandomEpicMaterial(c);
      }
    }
    // Đếm số hàng hiệu ứng sau khi mở rộng vat phẩm
    int totalRows = 0;
    for (final e in outcome.effects) {
      totalRows += e.type == OutcomeEffectType.gainRandomMaterials
          ? grantedMats.length
          : 1;
    }
    setState(() {
      _resolvedOutcome      = outcome;
      _combatTriggered      = combat;
      _grantedMaterials     = grantedMats;
      _grantedEpic          = grantedEpic;
      _outcomeVisibleParts  = 0;
      _outcomeShowButton    = false;
      _step                 = _ExploreStep.eventOutcome;
    });
    _startOutcomeSequence(totalRows);
  }

  /// Hiện từng phần của outcome screen theo trình tự (giống rest/training).
  void _startOutcomeSequence(int totalRows) async {
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    // Hiện mô tả
    setState(() => _outcomeVisibleParts = 1);
    // Hiện từng effect row
    for (int i = 0; i < totalRows; i++) {
      await Future.delayed(const Duration(milliseconds: 320));
      if (!mounted) return;
      setState(() => _outcomeVisibleParts = i + 2);
    }
    // Hiện nút Continue
    await Future.delayed(const Duration(milliseconds: 420));
    if (!mounted) return;
    setState(() => _outcomeShowButton = true);
  }

  void _acknowledgeOutcome() {
    if (_combatTriggered) {
      widget.onTriggerCombat?.call();
      return;
    }
    setState(() {
      _resolvedOutcome      = null;
      _combatTriggered      = false;
      _pendingEvent         = null;
      _outcomeVisibleParts  = 0;
      _outcomeShowButton    = false;
      _step = _arrivedAfterEvent ? _ExploreStep.arrived : _ExploreStep.traveling;
    });
  }

  /// Trao [count] nguyên liệu ngẫu nhiên cho nhân vật.
  /// Trọng số theo rarity: common 50%, uncommon 35%, rare 15%.
  List<Item> _grantRandomMaterials(Character c, int count) {
    final rng = Random();
    final commons   = ItemRegistry.all.where((i) => i.hasFlag(ItemFlag.material) && i.rarity == ItemRarity.common).toList();
    final uncommons = ItemRegistry.all.where((i) => i.hasFlag(ItemFlag.material) && i.rarity == ItemRarity.uncommon).toList();
    final rares     = ItemRegistry.all.where((i) => i.hasFlag(ItemFlag.material) && i.rarity == ItemRarity.rare).toList();
    final granted   = <Item>[];

    for (int i = 0; i < count; i++) {
      final roll = rng.nextDouble();
      List<Item> pool;
      if (roll < 0.50 && commons.isNotEmpty) {
        pool = commons;
      } else if (roll < 0.85 && uncommons.isNotEmpty) {
        pool = uncommons;
      } else if (rares.isNotEmpty) {
        pool = rares;
      } else {
        pool = commons.isNotEmpty ? commons : uncommons;
      }
      if (pool.isEmpty) continue;
      final item = pool[rng.nextInt(pool.length)];
      c.inventory.add(item);
      granted.add(item);
    }
    return granted;
  }

  /// Trao 1 nguyên liệu Epic ngẫu nhiên cho nhân vật.
  Item? _grantRandomEpicMaterial(Character c) {
    final epics = ItemRegistry.all.where((i) => i.hasFlag(ItemFlag.material) && i.rarity == ItemRarity.epic).toList();
    if (epics.isEmpty) return null;
    final item = epics[Random().nextInt(epics.length)];
    c.inventory.add(item);
    return item;
  }

  Color _rarityColor(ItemRarity rarity) => switch (rarity) {
    ItemRarity.common    => const Color(0xFFAAB8CC),
    ItemRarity.uncommon  => const Color(0xFF44AA55),
    ItemRarity.rare      => const Color(0xFF4488CC),
    ItemRarity.epic      => const Color(0xFF9944CC),
    ItemRarity.legendary => const Color(0xFFD4A843),
    ItemRarity.mythic    => const Color(0xFFCC3333),
  };

  (String, Color) _resolveEffect(OutcomeEffect e) => switch (e.type) {
    OutcomeEffectType.gainLantern            => ('+${e.value}% ${AppStrings.get('effectLabelLantern')}',   const Color(0xFFD4A843)),
    OutcomeEffectType.gainStamina            => ('+${e.value} ${AppStrings.get('effectLabelStamina')}',    const Color(0xFF5AAA55)),
    OutcomeEffectType.loseSanity             => ('−${e.value} ${AppStrings.get('effectLabelSanity')}',     const Color(0xFFCC4433)),
    OutcomeEffectType.loseStamina            => ('−${e.value} ${AppStrings.get('effectLabelStamina')}',    const Color(0xFFCC4433)),
    OutcomeEffectType.triggerCombat          => (AppStrings.get('effectLabelCombat'),                      const Color(0xFFCC2222)),
    OutcomeEffectType.gainSanity             => ('+${e.value} ${AppStrings.get('effectLabelSanity')}',     const Color(0xFF5AAA55)),
    OutcomeEffectType.gainFullSanity         => (AppStrings.get('effectLabelSanityFull'),                  const Color(0xFF5AAA55)),
    OutcomeEffectType.loseHp                 => ('−${e.value} ${AppStrings.get('effectLabelHp')}',         const Color(0xFFCC4433)),
    OutcomeEffectType.loseMaxHp              => ('−${e.value} ${AppStrings.get('effectLabelMaxHp')}',      const Color(0xFFCC2222)),
    OutcomeEffectType.applyPoison            => ('${AppStrings.get('effectLabelPoison')} (${e.value > 0 ? e.value : 3} ${AppStrings.get('effectLabelTurns')})', const Color(0xFF88CC44)),
    OutcomeEffectType.applyBleeding          => (AppStrings.get('effectLabelBleeding'),                   const Color(0xFFCC4444)),
    OutcomeEffectType.applyBloodlust         => ('${AppStrings.get('effectLabelBloodlust')} (${e.value > 0 ? e.value : 3} ${AppStrings.get('effectLabelTurns')})', const Color(0xFFBB3333)),
    OutcomeEffectType.gainRandomMaterials    => ('+${e.value} ${AppStrings.get('effectLabelMaterial')}',  const Color(0xFFAAB8CC)),
    OutcomeEffectType.gainRandomEpicMaterial => (AppStrings.get('effectLabelEpicMaterial'),               const Color(0xFFCC8844)),
  };

  /// Trả về danh sách (label, color) sau khi mở rộng gainRandomMaterials
  /// thành từng vật phẩm cụ thể.
  List<(String, Color)> _expandedEffectRows(EventOutcome outcome) {
    final rows = <(String, Color)>[];
    for (final e in outcome.effects) {
      if (e.type == OutcomeEffectType.gainRandomMaterials) {
        for (final item in _grantedMaterials) {
          rows.add(('+1 ${AppStrings.get(item.nameKey)}', _rarityColor(item.rarity)));
        }
      } else if (e.type == OutcomeEffectType.gainRandomEpicMaterial) {
        final epic = _grantedEpic;
        if (epic != null) {
          rows.add(('✦ ${AppStrings.get(epic.nameKey)}', const Color(0xFFCC8844)));
        } else {
          rows.add(_resolveEffect(e));
        }
      } else {
        rows.add(_resolveEffect(e));
      }
    }
    return rows;
  }

  String _areaNameKey(String areaKey) => switch (areaKey) {
    'quarry'      => 'exploreAreaQuarry',
    'forest'      => 'exploreAreaForest',
    'battlefield' => 'exploreAreaBattlefield',
    _             => 'exploreAreaQuarry',
  };

  String _areaImagePath(String areaKey) => switch (areaKey) {
    'quarry'      => 'assets/images/backgrounds/the_excavation_cleft.png',
    'forest'      => 'assets/images/backgrounds/the_feral_thicket.png',
    'battlefield' => 'assets/images/backgrounds/the_buried_battleground.png',
    _             => 'assets/images/backgrounds/the_excavation_cleft.png',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0A0A),
      child: SafeArea(
        child: Stack(
          children: [
            // ── Nội dung chính ───────────────────────────────────────
            switch (_step) {
              _ExploreStep.categorySelect => _buildCategorySelect(),
              _ExploreStep.areaSelect     => _buildAreaSelect(),
              _ExploreStep.traveling      => _buildTraveling(),
              _ExploreStep.eventDisplay   => _buildEventDisplay(),
              _ExploreStep.eventOutcome   => _buildEventOutcome(),
              _ExploreStep.arrived        => _buildArrived(),
            },

            // ── Nút xem chỉ số nhân vật (góc trên phải) ─────────────
            if (!_showCharPanel)
              Positioned(
                top: 10,
                right: 12,
                child: GestureDetector(
                  onTap: () => setState(() => _showCharPanel = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0D0D),
                      border: Border.all(color: const Color(0xFF4A3618), width: 1),
                    ),
                    child: Text(
                      AppStrings.get('charPanelTitle'),
                      style: const TextStyle(
                        fontFamily: 'GnuUnifont',
                        fontSize: 10,
                        color: Color(0xFFD4A843),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),

            // ── Overlay bảng nhân vật ─────────────────────────────────
            if (_showCharPanel)
              CharacterPanel(
                character: widget.character,
                onClose: () => setState(() => _showCharPanel = false),
              ),
          ],
        ),
      ),
    );
  }

  // ── Bước 1: Chọn danh mục ─────────────────────────────────────────────────

  Widget _buildCategorySelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(AppStrings.get('exploreSearchQuestion')),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ExploreButton(
                  label: AppStrings.get('exploreCatFood'),
                  onTap: () => _selectCategory(ExploreCategory.food),
                ),
                const SizedBox(height: 10),
                _ExploreButton(
                  label: AppStrings.get('exploreCatMedical'),
                  onTap: () => _selectCategory(ExploreCategory.medical),
                ),
                const SizedBox(height: 10),
                _ExploreButton(
                  label: AppStrings.get('exploreCatMental'),
                  onTap: () => _selectCategory(ExploreCategory.mental),
                ),
                const SizedBox(height: 10),
                _ExploreButton(
                  label: AppStrings.get('exploreCatCombat'),
                  onTap: () => _selectCategory(ExploreCategory.combat),
                ),
                const SizedBox(height: 10),
                _ImageExploreButton(
                  label: AppStrings.get('exploreCatEquipment'),
                  imagePath: 'assets/images/backgrounds/weapon_armor.png',
                  onTap: () => _selectCategory(ExploreCategory.equipment),
                ),
              ],
            ),
          ),
        ),
        _buildBackRow(widget.onReturnToSafehouse),
      ],
    );
  }

  // ── Bước 2: Chọn khu vực ──────────────────────────────────────────────────

  Widget _buildAreaSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(AppStrings.get('exploreAreaQuestion')),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ImageExploreButton(
                  label: AppStrings.get('exploreAreaQuarry'),
                  imagePath: 'assets/images/backgrounds/the_excavation_cleft.png',
                  onTap: () => _selectArea('quarry'),
                ),
                const SizedBox(height: 10),
                _ImageExploreButton(
                  label: AppStrings.get('exploreAreaForest'),
                  imagePath: 'assets/images/backgrounds/the_feral_thicket.png',
                  onTap: () => _selectArea('forest'),
                ),
                const SizedBox(height: 10),
                _ImageExploreButton(
                  label: AppStrings.get('exploreAreaBattlefield'),
                  imagePath: 'assets/images/backgrounds/the_buried_battleground.png',
                  onTap: () => _selectArea('battlefield'),
                ),
              ],
            ),
          ),
        ),
        _buildBackRow(_goBack),
      ],
    );
  }

  // ── Bước 3: Di chuyển ────────────────────────────────────────────────────

  Widget _buildTraveling() {
    final c           = widget.character;
    final canAdvance  = c.stamina >= _staminaCostPerStep;
    final areaKey     = _selectedArea ?? 'quarry';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(AppStrings.get(_areaNameKey(areaKey))),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Ảnh khu vực ─────────────────────────────────────────
                ClipRect(
                  child: Image.asset(
                    _areaImagePath(areaKey),
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.none,
                  ),
                ),
                const SizedBox(height: 14),
                _infoPanel([
                  _infoRow(
                    AppStrings.get('exploreTravelCostPer'),
                    '',
                    labelColor: const Color(0xFF8A8478),
                  ),
                  _infoRow(
                    '  ${AppStrings.get('exploreTravelCostStamina')}',
                    '−$_staminaCostPerStep',
                    valueColor: const Color(0xFFCC4433),
                  ),
                  _infoRow(
                    '  ${AppStrings.get('exploreTravelCostLantern')}',
                    '−$_lanternCostPerStep',
                    valueColor: const Color(0xFFCC8833),
                  ),
                ]),
                const SizedBox(height: 10),
                _infoPanel([
                  _infoRow(
                    AppStrings.get('exploreTravelCurrentStamina'),
                    '${c.stamina} / ${c.maxStamina}',
                    valueColor: canAdvance
                        ? const Color(0xFFCEC8B0)
                        : const Color(0xFFCC2222),
                  ),
                  _infoRow(
                    AppStrings.get('exploreTravelCurrentLantern'),
                    '${c.lanternDurability}%',
                    valueColor: c.lanternDurability >= 50
                        ? const Color(0xFFD4A843)
                        : const Color(0xFFCC4433),
                  ),
                ]),
                if (!canAdvance) ...
                  [
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.get('exploreTravelNoStamina'),
                      style: const TextStyle(
                        fontFamily: 'GnuUnifont',
                        fontSize: 11,
                        color: Color(0xFFCC2222),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                const SizedBox(height: 16),
                _ExploreButton(
                  label: AppStrings.get('exploreTravelAdvance'),
                  onTap: canAdvance ? _advanceTravel : null,
                  isDisabled: !canAdvance,
                ),
              ],
            ),
          ),
        ),
        _buildBackRow(widget.onReturnToSafehouse, labelKey: 'exploreTravelReturnHub'),
      ],
    );
  }

  // ── Bước 4: Đã đến nơi ───────────────────────────────────────────────────

  Widget _buildArrived() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(AppStrings.get('exploreTravelArrived')),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _infoPanel([
                  _infoRow(
                    AppStrings.get(_areaNameKey(_selectedArea ?? 'quarry')),
                    '',
                    labelColor: const Color(0xFFD4A843),
                  ),
                  _infoRow(
                    AppStrings.get('exploreTravelStep'),
                    '$_travelSteps',
                  ),
                ]),
                const SizedBox(height: 16),
                // TODO: logic khám phá khu vực
                _ExploreButton(
                  label: AppStrings.get('exploreTravelExplore'),
                  onTap: null,
                  isDisabled: true,
                ),
              ],
            ),
          ),
        ),
        _buildBackRow(widget.onReturnToSafehouse, labelKey: 'exploreTravelReturnHub'),
      ],
    );
  }
  // ── Màn hình sự kiện ──────────────────────────────────────────────────────

  Widget _buildEventDisplay() {
    final event = TravelEventSystem.forType(_pendingEvent!);
    final hasChoices = event.choices != null && event.choices!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ─ Hình ảnh minh họa
        if (event.imagePath != null)
          SizedBox(
            height: 180,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  event.imagePath!,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.none,
                  errorBuilder: (_, __, ___) =>
                      Container(color: const Color(0xFF080808)),
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x000A0A0A), Color(0xFF0A0A0A)],
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            height: 80,
            color: const Color(0xFF080808),
            alignment: Alignment.center,
            child: const Text(
              '~ ~ ~',
              style: TextStyle(
                fontFamily: 'GnuUnifont',
                fontSize: 14,
                color: Color(0xFF2A2010),
                letterSpacing: 6,
              ),
            ),
          ),
        // ─ Nội dung + lựa chọn
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Tiêu đề + mô tả (animate cùng nhau) ───────────────────
                AnimatedOpacity(
                  opacity: _eventVisibleParts >= 1 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedSlide(
                    offset: _eventVisibleParts >= 1
                        ? Offset.zero
                        : const Offset(0, 0.05),
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppStrings.get(event.titleKey),
                          style: const TextStyle(
                            fontFamily: 'GnuUnifont',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD4A843),
                            letterSpacing: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Container(height: 1, color: const Color(0xFF2A2010)),
                        const SizedBox(height: 14),
                        Text(
                          AppStrings.get(event.descKey),
                          style: const TextStyle(
                            fontFamily: 'GnuUnifont',
                            fontSize: 12,
                            color: Color(0xFFCEC8B0),
                            height: 1.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ── Các lựa chọn (mỗi nút animate riêng) ──────────────────
                if (hasChoices) ...[
                  const SizedBox(height: 20),
                  AnimatedOpacity(
                    opacity: _eventVisibleParts >= 2 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(height: 1, color: const Color(0xFF2A2010)),
                  ),
                  const SizedBox(height: 14),
                  for (int ci = 0; ci < event.choices!.length; ci++) ...[
                    AnimatedOpacity(
                      opacity: _eventVisibleParts >= ci + 2 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: AnimatedSlide(
                        offset: _eventVisibleParts >= ci + 2
                            ? Offset.zero
                            : const Offset(0, 0.04),
                        duration: const Duration(milliseconds: 200),
                        child: _ChoiceButton(
                          label: AppStrings.get(event.choices![ci].labelKey),
                          costLabel: event.choices![ci].costLabelKey != null
                              ? AppStrings.get(event.choices![ci].costLabelKey!)
                              : null,
                          isDisabled: !event.choices![ci].isContinue &&
                              event.choices![ci].outcomes == null,
                          onTap: () => _selectChoice(event.choices![ci]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ),
        // ─ Nút tiếp tục (chỉ hiển thị khi không có choices)
        if (!hasChoices)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: _ExploreButton(
              label: AppStrings.get('travelEventContinue'),
              onTap: _acknowledgeEvent,
            ),
          ),
      ],
    );
  }

  // ── Kết quả lựa chọn ─────────────────────────────────────────────────────

  Widget _buildEventOutcome() {
    final outcome = _resolvedOutcome!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ─ Ảnh kết quả (hiện ngay lập tức)
        if (outcome.imagePath != null)
          SizedBox(
            height: 180,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  outcome.imagePath!,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.none,
                  errorBuilder: (_, __, ___) =>
                      Container(color: const Color(0xFF080808)),
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x000A0A0A), Color(0xFF0A0A0A)],
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            height: 80,
            color: const Color(0xFF080808),
            alignment: Alignment.center,
            child: const Text(
              '~ ~ ~',
              style: TextStyle(
                fontFamily: 'GnuUnifont',
                fontSize: 14,
                color: Color(0xFF2A2010),
                letterSpacing: 6,
              ),
            ),
          ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Tiêu đề (hiện ngay) ────────────────────────────────────
                Text(
                  AppStrings.get(outcome.titleKey),
                  style: const TextStyle(
                    fontFamily: 'GnuUnifont',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4A843),
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Container(height: 1, color: const Color(0xFF2A2010)),
                const SizedBox(height: 14),

                // ── Mô tả (phần 0 – animate đầu tiên) ─────────────────────
                AnimatedOpacity(
                  opacity: _outcomeVisibleParts >= 1 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedSlide(
                    offset: _outcomeVisibleParts >= 1
                        ? Offset.zero
                        : const Offset(0, 0.06),
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      AppStrings.get(outcome.descKey),
                      style: const TextStyle(
                        fontFamily: 'GnuUnifont',
                        fontSize: 12,
                        color: Color(0xFFCEC8B0),
                        height: 1.8,
                      ),
                    ),
                  ),
                ),

                // ── Các effect row (mỗi row animate riêng) ────────────────
                Builder(builder: (context) {
                  final rows = _expandedEffectRows(outcome);
                  if (rows.isEmpty) return const SizedBox.shrink();
                  return Column(
                    children: [
                      const SizedBox(height: 16),
                      Container(height: 1, color: const Color(0xFF2A2010)),
                      const SizedBox(height: 10),
                      for (int i = 0; i < rows.length; i++)
                        AnimatedOpacity(
                          opacity: _outcomeVisibleParts >= i + 2 ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: AnimatedSlide(
                            offset: _outcomeVisibleParts >= i + 2
                                ? Offset.zero
                                : const Offset(-0.08, 0),
                            duration: const Duration(milliseconds: 200),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Text(
                                rows[i].$1,
                                style: TextStyle(
                                  fontFamily: 'GnuUnifont',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: rows[i].$2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),

        // ── Nút Continue (hiện cuối cùng) ─────────────────────────────────
        AnimatedOpacity(
          opacity: _outcomeShowButton ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: _ExploreButton(
              label: AppStrings.get('travelEventContinue'),
              onTap: _outcomeShowButton ? _acknowledgeOutcome : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _effectRow(OutcomeEffect e) {
    String label;
    Color color;
    switch (e.type) {
      case OutcomeEffectType.gainLantern:
        label = '+${e.value}% ${AppStrings.get('effectLabelLantern')}';
        color = const Color(0xFFD4A843);
      case OutcomeEffectType.gainStamina:
        label = '+${e.value} ${AppStrings.get('effectLabelStamina')}';
        color = const Color(0xFF5AAA55);
      case OutcomeEffectType.loseSanity:
        label = '−${e.value} ${AppStrings.get('effectLabelSanity')}';
        color = const Color(0xFFCC4433);
      case OutcomeEffectType.loseStamina:
        label = '−${e.value} ${AppStrings.get('effectLabelStamina')}';
        color = const Color(0xFFCC4433);
      case OutcomeEffectType.triggerCombat:
        label = AppStrings.get('effectLabelCombat');
        color = const Color(0xFFCC2222);
      case OutcomeEffectType.gainSanity:
        label = '+${e.value} ${AppStrings.get('effectLabelSanity')}';
        color = const Color(0xFF5AAA55);
      case OutcomeEffectType.gainFullSanity:
        label = AppStrings.get('effectLabelSanityFull');
        color = const Color(0xFF5AAA55);
      case OutcomeEffectType.loseHp:
        label = '−${e.value} ${AppStrings.get('effectLabelHp')}';
        color = const Color(0xFFCC4433);
      case OutcomeEffectType.loseMaxHp:
        label = '−${e.value} ${AppStrings.get('effectLabelMaxHp')}';
        color = const Color(0xFFCC2222);
      case OutcomeEffectType.applyPoison:
        label = '${AppStrings.get('effectLabelPoison')} (${e.value > 0 ? e.value : 3} ${AppStrings.get('effectLabelTurns')})';
        color = const Color(0xFF88CC44);
      case OutcomeEffectType.applyBleeding:
        label = AppStrings.get('effectLabelBleeding');
        color = const Color(0xFFCC4444);
      case OutcomeEffectType.applyBloodlust:
        label = '${AppStrings.get('effectLabelBloodlust')} (${e.value > 0 ? e.value : 3} ${AppStrings.get('effectLabelTurns')})';
        color = const Color(0xFFBB3333);
      case OutcomeEffectType.gainRandomMaterials:
        label = '+${e.value} ${AppStrings.get('effectLabelMaterial')}';
        color = const Color(0xFFAAB8CC);
      case OutcomeEffectType.gainRandomEpicMaterial:
        label = AppStrings.get('effectLabelEpicMaterial');
        color = const Color(0xFFCC8844);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'GnuUnifont',
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 80, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF2A2010), width: 1)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'GnuUnifont',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFFD4A843),
          letterSpacing: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBackRow(VoidCallback onBack, {String labelKey = 'exploreBack'}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: _ExploreButton(
        label: AppStrings.get(labelKey),
        onTap: onBack,
        isBack: true,
      ),
    );
  }

  Widget _infoPanel(List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border.all(color: const Color(0xFF2A2010), width: 1),
      ),
      child: Column(children: rows),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    Color labelColor = const Color(0xFF8A8478),
    Color valueColor = const Color(0xFFCEC8B0),
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'GnuUnifont',
                fontSize: 11,
                color: labelColor,
              ),
            ),
          ),
          if (value.isNotEmpty)
            Text(
              value,
              style: TextStyle(
                fontFamily: 'GnuUnifont',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Nút bấm Explore
// ────────────────────────────────────────────────────────────────────────────

class _ExploreButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isBack;
  final bool isDisabled;

  const _ExploreButton({
    required this.label,
    this.onTap,
    this.isBack = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color fill      = isDisabled
        ? const Color(0xFF0A0A0A)
        : isBack
            ? const Color(0xFF0E0E0E)
            : const Color(0xFF140E04);
    final Color border    = isDisabled
        ? const Color(0xFF2A2A2A)
        : isBack
            ? const Color(0xFF3A3A3A)
            : const Color(0xFF4A3618);
    final Color textColor = isDisabled
        ? const Color(0xFF3A3A3A)
        : isBack
            ? const Color(0xFF6A6A5A)
            : const Color(0xFFD4A843);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill,
          border: Border.all(color: border, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'GnuUnifont',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Nút bấm có hình ảnh nền
// ────────────────────────────────────────────────────────────────────────────

class _ImageExploreButton extends StatelessWidget {
  final String label;
  final String imagePath;
  final VoidCallback? onTap;

  const _ImageExploreButton({
    required this.label,
    required this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF4A3618), width: 1),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF140E04)),
            ),
            Container(color: const Color(0xAA0A0A0A)),
            Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4A843),
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      color: Color(0xFF000000),
                      offset: Offset(1, 1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Nút lựa chọn sự kiện
// ────────────────────────────────────────────────────────────────────────────

class _ChoiceButton extends StatelessWidget {
  final String label;
  final String? costLabel;
  final VoidCallback? onTap;
  final bool isDisabled;

  const _ChoiceButton({
    required this.label,
    this.costLabel,
    this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color fill      = isDisabled ? const Color(0xFF0A0A0A) : const Color(0xFF0F0C06);
    final Color border    = isDisabled ? const Color(0xFF252520) : const Color(0xFF3A2E14);
    final Color textColor = isDisabled ? const Color(0xFF3A3A36) : const Color(0xFFCEC8B0);
    final Color costColor = isDisabled ? const Color(0xFF3A3A36) : const Color(0xFF8A8478);

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: fill,
          border: Border.all(color: border, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 12,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            if (costLabel != null) ...[
              const SizedBox(width: 8),
              Text(
                costLabel!,
                style: TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 11,
                  color: costColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
