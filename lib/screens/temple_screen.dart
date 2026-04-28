import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one_hundred_sunless_days/l10n/app_strings.dart';
import 'package:one_hundred_sunless_days/models/character.dart';
import 'package:one_hundred_sunless_days/screens/start_screen.dart';
import 'package:one_hundred_sunless_days/widgets/settings_panel.dart';

// ────────────────────────────────────────────────────────────────────────────
// Màn hình Hub chính – Nhà Thờ Bỏ Hoang (Safehouse)
// ────────────────────────────────────────────────────────────────────────────

class TempleScreen extends StatefulWidget {
  final Character character;

  const TempleScreen({super.key, required this.character});

  @override
  State<TempleScreen> createState() => _TempleScreenState();
}

class _TempleScreenState extends State<TempleScreen> {
  // Trạng thái hiển thị overlay
  bool _showSettings = false;
  bool _showCharacter = false;

  // Mở/đóng bảng cài đặt (đóng bảng nhân vật nếu đang mở)
  void _toggleSettings() => setState(() {
        _showSettings = !_showSettings;
        if (_showSettings) _showCharacter = false;
      });

  // Mở/đóng bảng nhân vật (đóng bảng cài đặt nếu đang mở)
  void _toggleCharacter() => setState(() {
        _showCharacter = !_showCharacter;
        if (_showCharacter) _showSettings = false;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Ảnh nền nhà thờ
          Image.asset(
            'assets/images/backgrounds/intro_scene.png',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.none,
          ),

          // ── Gradient overlay tối ở trên và dưới
          _buildGradientOverlay(),

          // ── Nội dung UI (trong SafeArea để tránh notch/status bar)
          SafeArea(child: _buildUiLayer()),

          // ── Bảng cài đặt (overlay toàn màn hình)
          if (_showSettings)
            SettingsPanel(
              onClose: _toggleSettings,
              onLocaleChanged: () => setState(() {}),
              showSaveLoad: true,
              onQuit: () {
                // Thoát về màn hình bắt đầu
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const StartScreen(),
                  ),
                  (_) => false,
                );
              },
            ),

          // ── Bảng nhân vật (overlay toàn màn hình)
          if (_showCharacter)
            _CharacterPanel(
              character: widget.character,
              onClose: _toggleCharacter,
            ),
        ],
      ),
    );
  }

  // ── Gradient tối phủ lên ảnh nền ─────────────────────────────────────────

  Widget _buildGradientOverlay() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xBB000000), Color(0x22000000), Color(0xDD000000)],
          stops: [0.0, 0.35, 1.0],
        ),
      ),
    );
  }

  // ── Toàn bộ UI (đặt trong SafeArea) ──────────────────────────────────────

  Widget _buildUiLayer() {
    return Stack(
      children: [
        // Tên địa điểm (trên, giữa)
        Positioned(
          top: 6,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              AppStrings.get('templeTitle'),
              style: const TextStyle(
                fontFamily: 'GnuUnifont',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFBFA060),
                letterSpacing: 3,
              ),
            ),
          ),
        ),

        // HUD chỉ số (trên, trái)
        Positioned(
          top: 52,
          left: 12,
          child: _buildHud(),
        ),

        // Nút bánh răng cài đặt (trên, phải)
        Positioned(
          top: 4,
          right: 12,
          child: _PixelGearButton(onTap: _toggleSettings),
        ),

        // Các nút hành động (dưới, giữa-trái)
        Positioned(
          bottom: 24,
          left: 16,
          right: 64,
          child: _buildActionButtons(),
        ),

        // Nút nhân vật (dưới, phải)
        Positioned(
          bottom: 24,
          right: 12,
          child: _PixelIconButton(icon: '☉', onTap: _toggleCharacter),
        ),
      ],
    );
  }

  // ── HUD chỉ số nhân vật ────────────────────────────────────────────────────

  Widget _buildHud() {
    final Character c = widget.character;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatBar(
          label: AppStrings.get('templeStatHp'),
          current: c.hp,
          max: c.maxHp,
          color: const Color(0xFFCC3333),
        ),
        const SizedBox(height: 5),
        _StatBar(
          label: AppStrings.get('templeStatStamina'),
          current: c.stamina,
          max: c.maxStamina,
          color: const Color(0xFF3388CC),
        ),
        const SizedBox(height: 5),
        _StatBar(
          label: AppStrings.get('templeStatHunger'),
          current: c.hunger,
          max: c.maxHunger,
          color: c.isStarving
              ? const Color(0xFFCC6633)
              : const Color(0xFF88AA44),
        ),
        const SizedBox(height: 8),
        // Tro Tàn
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '✦ ',
              style: TextStyle(
                fontFamily: 'GnuUnifont',
                fontSize: 11,
                color: Color(0xFFD4A843),
              ),
            ),
            Text(
              '${c.embers}',
              style: const TextStyle(
                fontFamily: 'GnuUnifont',
                fontSize: 11,
                color: Color(0xFFD4A843),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Các nút hành động tại hub ─────────────────────────────────────────────

  Widget _buildActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HubButton(
          label: AppStrings.get('templeActionExplore'),
          onTap: () {}, // TODO: mở màn hình khám phá
        ),
        const SizedBox(height: 8),
        _HubButton(
          label: AppStrings.get('templeActionTrain'),
          onTap: () {}, // TODO: mở màn hình tập luyện
        ),
        const SizedBox(height: 8),
        _HubButton(
          label: AppStrings.get('templeActionRest'),
          onTap: () {}, // TODO: nghỉ ngơi hồi máu/thể lực
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Widget con dùng chung
// ────────────────────────────────────────────────────────────────────────────

/// Thanh chỉ số pixel (label + bar + số).
class _StatBar extends StatelessWidget {
  final String label;
  final int current;
  final int max;
  final Color color;

  const _StatBar({
    required this.label,
    required this.current,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double ratio = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Nhãn
        SizedBox(
          width: 56,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: const TextStyle(
              fontFamily: 'GnuUnifont',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8A7A58),
            ),
          ),
        ),
        // Thanh nền + phần đã lấp đầy
        Container(
          width: 88,
          height: 11,
          color: const Color(0xFF1A1A1A),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: ratio,
              child: Container(color: color),
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Số
        Text(
          '$current',
          style: const TextStyle(
            fontFamily: 'GnuUnifont',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFFCEC8B0),
          ),
        ),
      ],
    );
  }
}

/// Nút icon nhỏ (☉ nhân vật…) với viền pixel.
class _PixelIconButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;

  const _PixelIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xCC080808),
          border: Border.all(color: const Color(0xFF4A3618), width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          icon,
          style: const TextStyle(
            fontFamily: 'GnuUnifont',
            fontSize: 22,
            color: Color(0xFFD4A843),
          ),
        ),
      ),
    );
  }
}

/// Nút bánh răng pixel art vẽ bằng CustomPainter.
class _PixelGearButton extends StatefulWidget {
  final VoidCallback onTap;
  const _PixelGearButton({required this.onTap});

  @override
  State<_PixelGearButton> createState() => _PixelGearButtonState();
}

class _PixelGearButtonState extends State<_PixelGearButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _pressed
              ? const Color(0xFF1A1206)
              : const Color(0xCC080808),
          border: Border.all(
            color: _pressed
                ? const Color(0xFFD4A843)
                : const Color(0xFF4A3618),
            width: 1,
          ),
        ),
        child: CustomPaint(
          painter: _GearPainter(
            color: _pressed
                ? const Color(0xFFFFD070)
                : const Color(0xFFD4A843),
          ),
        ),
      ),
    );
  }
}

/// Vẽ biểu tượng bánh răng pixel art bằng lưới ô vuông.
class _GearPainter extends CustomPainter {
  final Color color;
  const _GearPainter({required this.color});

  // Ma trận 11×11 – 1 = ô tô màu, 0 = trong suốt
  static const List<List<int>> _grid = [
    [0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0],
    [0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1],
    [1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1],
    [1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1],
    [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
    [0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0],
    [0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    final double cellW = size.width / _grid[0].length;
    final double cellH = size.height / _grid.length;
    // Padding nhỏ để bánh răng không sát viền
    final double padX = size.width * 0.12;
    final double padY = size.height * 0.12;
    final double drawW = size.width - padX * 2;
    final double drawH = size.height - padY * 2;
    final double cw = drawW / _grid[0].length;
    final double ch = drawH / _grid.length;

    for (int row = 0; row < _grid.length; row++) {
      for (int col = 0; col < _grid[row].length; col++) {
        if (_grid[row][col] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(
              padX + col * cw,
              padY + row * ch,
              cw,
              ch,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_GearPainter old) => old.color != color;
}

/// Nút hành động tại hub (Khám Phá, Tập Luyện, Nghỉ Ngơi).
class _HubButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _HubButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xCC080808),
          border: Border.all(color: const Color(0xFF4A3618), width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'GnuUnifont',
            fontSize: 12,
            color: Color(0xFFD4A843),
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Bảng Nhân Vật
// ────────────────────────────────────────────────────────────────────────────

class _CharacterPanel extends StatefulWidget {
  final Character character;
  final VoidCallback onClose;

  const _CharacterPanel({
    required this.character,
    required this.onClose,
  });

  @override
  State<_CharacterPanel> createState() => _CharacterPanelState();
}

class _CharacterPanelState extends State<_CharacterPanel> {
  // 0 = Trang bị, 1 = Balo, 2 = Chỉ số, 3 = Kỹ năng
  int _tab = 0;
  // Key của chỉ số đang mở chú thích (null = không có)
  String? _expandedStatKey;

  static const List<String> _tabKeys = [
    'charTabEquip',
    'charTabBag',
    'charTabStats',
    'charTabSkills',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xF2060606),
      child: Column(
        children: [
          // ── Tiêu đề & nút đóng ──────────────────────────────────────
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

          // ── Thanh tab ──────────────────────────────────────────────
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

          // ── Nội dung tab ───────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildTabContent(),
            ),
          ),
        ],
      ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _EquipSlot(label: AppStrings.get('charEquipWeapon')),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _EquipSlot(label: AppStrings.get('charEquipArmor')),
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
    // 16 ô trống (4 cột × 4 hàng)
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: List.generate(
        16,
        (_) => Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF2A2010), width: 1),
          ),
        ),
      ),
    );
  }

  // ── Tab Chỉ Số ────────────────────────────────────────────────────────────

  Widget _buildStatsTab() {
    final Character c = widget.character;

    // Helper: bật/tắt chú thích của một chỉ số
    void toggle(String key) =>
        setState(() => _expandedStatKey = _expandedStatKey == key ? null : key);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Nhóm: Sinh Tồn ──────────────────────────────────────────────
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

        // ── Nhóm: Chỉ Số Cơ Bản ─────────────────────────────────────────
        _GroupHeader(AppStrings.get('charGroupPrimary')),
        const SizedBox(height: 8),
        _StatRow(
          label: AppStrings.get('charStatStr'),
          value: c.str,
          max: 20,
          color: const Color(0xFFCC6644),
          desc: AppStrings.get('charDescStr'),
          isExpanded: _expandedStatKey == 'str',
          onTap: () => toggle('str'),
        ),
        _StatRow(
          label: AppStrings.get('charStatAgi'),
          value: c.agi,
          max: 20,
          color: const Color(0xFF4488CC),
          desc: AppStrings.get('charDescAgi'),
          isExpanded: _expandedStatKey == 'agi',
          onTap: () => toggle('agi'),
        ),
        _StatRow(
          label: AppStrings.get('charStatVit'),
          value: c.vit,
          max: 20,
          color: const Color(0xFF44AA66),
          desc: AppStrings.get('charDescVit'),
          isExpanded: _expandedStatKey == 'vit',
          onTap: () => toggle('vit'),
        ),
        _StatRow(
          label: AppStrings.get('charStatWill'),
          value: c.will,
          max: 20,
          color: const Color(0xFFCC88CC),
          desc: AppStrings.get('charDescWill'),
          isExpanded: _expandedStatKey == 'will',
          onTap: () => toggle('will'),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: Color(0xFF2A2010), height: 1),
        ),

        // ── Nhóm: Thuộc Tính Ẩn ─────────────────────────────────────────
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

        // ── Tro Tàn ──────────────────────────────────────────────────────
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
            Text(
              '✦ ${c.embers}',
              style: const TextStyle(
                fontFamily: 'GnuUnifont',
                fontSize: 13,
                color: Color(0xFFD4A843),
              ),
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

// ── Ô trang bị (vũ khí / giáp / phụ kiện) ────────────────────────────────

class _EquipSlot extends StatelessWidget {
  final String label;

  const _EquipSlot({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 68,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF2A2010), width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
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
          label,
          style: const TextStyle(
            fontFamily: 'GnuUnifont',
            fontSize: 9,
            color: Color(0xFF6A5A38),
            letterSpacing: 1,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Hàng chỉ số trong bảng Stats ──────────────────────────────────────────

class _StatRow extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Color color;
  final bool showFraction;
  // Chú thích – hiện khi isExpanded = true
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
    final double ratio = max > 0 ? (value / max).clamp(0.0, 1.0) : 0.0;
    final String valueText = showFraction ? '$value/$max' : '$value';

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
                // Thanh tiến trình
                Expanded(
                  child: Container(
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

// ── Widget tiêu đề nhóm chỉ số ───────────────────────────────────────────────

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


