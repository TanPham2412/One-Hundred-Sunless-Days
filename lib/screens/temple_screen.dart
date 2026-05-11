import 'dart:math';

import 'package:flutter/material.dart';
import 'package:one_hundred_sunless_days/l10n/app_strings.dart';
import 'package:one_hundred_sunless_days/models/character.dart';
import 'package:one_hundred_sunless_days/models/enemy_data.dart';
import 'package:one_hundred_sunless_days/models/lantern.dart';
import 'package:one_hundred_sunless_days/models/monster.dart';
import 'package:one_hundred_sunless_days/screens/combat_prep_screen.dart';
import 'package:one_hundred_sunless_days/screens/combat_screen.dart';
import 'package:one_hundred_sunless_days/screens/explore_screen.dart';
import 'package:one_hundred_sunless_days/screens/start_screen.dart';
import 'package:one_hundred_sunless_days/screens/training_overlay.dart';
import 'package:one_hundred_sunless_days/widgets/character_panel.dart';
import 'package:one_hundred_sunless_days/widgets/rest_result_overlay.dart';
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
  bool _showTraining = false;
  bool _showExplore  = false;

  // Kết quả nghỉ ngơi đang chờ hiển thị (null = không hiện)
  RestResult? _restResult;

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

  // Thực hiện nghỉ ngơi → áp dụng hiệu ứng → hiện kết quả
  void _doRest() {
    setState(() {
      _restResult = widget.character.rest();
      _showCharacter = false;
      _showSettings = false;
    });
  }

  // Xử lý sau khi người chơi bấm tiếp tục trên màn hình kết quả nghỉ ngơi
  void _onRestContinue() {
    final result = _restResult;
    setState(() => _restResult = null);
    if (result == null || !result.navigateToCombat) return;

    // outsidePlea (mở cửa → bị tấn công) → luôn gặp Thi Thể Nhại Tiếng
    if (result.event == NightEvent.outsidePlea) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CombatPrepScreen(
          character:   widget.character,
          monster:     MonsterRegistry.mimickingCorpse,
          enemyData:   EnemyRegistry.mimickingCorpse,
          startGroggy: false,
        ),
      ));
      return;
    }

    // nightRaid (đột kích ban đêm) → ngẫu nhiên 1 trong 3 kẻ thù
    final pool = [
      (monster: MonsterRegistry.stitchedEyeHound,     data: EnemyRegistry.stitchedEyeHound),
      (monster: MonsterRegistry.corruptedCleric,      data: EnemyRegistry.corruptedCleric),
      (monster: MonsterRegistry.lightDevouringSludge, data: EnemyRegistry.lightDevouringSludge),
    ];
    final pick = pool[Random().nextInt(pool.length)];
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CombatScreen(
        character:   widget.character,
        enemies:     [(monster: pick.monster, data: pick.data)],
        startGroggy: true,
      ),
    ));
  }

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

          // ── Overlay Tập Luyện
          if (_showTraining)
            TrainingOverlay(
              character: widget.character,
              onClose: () => setState(() => _showTraining = false),
            ),

          // ── Overlay Khám Phá
          if (_showExplore)
            ExploreScreen(
              character: widget.character,
              onReturnToSafehouse: () => setState(() => _showExplore = false),
            ),

          // ── Bảng cài đặt (overlay toàn màn hình)
          if (_showSettings)
            SettingsPanel(
              onClose: _toggleSettings,
              onLocaleChanged: () => setState(() {}),
              showSaveLoad: true,
              onQuit: () {
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
            CharacterPanel(
              character: widget.character,
              onClose: _toggleCharacter,
            ),

          // ── Màn hình kết quả nghỉ ngơi (overlay toàn màn hình)
          if (_restResult != null)
            RestResultOverlay(
              result: _restResult!,
              character: widget.character,
              onContinue: _onRestContinue,
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
          child: _PixelIconButton(icon: '\u2609', onTap: _toggleCharacter),
        ),
      ],
    );
  }

  // ── HUD chỉ số nhân vật ───────────────────────────────────────────────────

  Widget _buildHud() {
    final Character c = widget.character;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ngày hiện tại
        Text(
          '${AppStrings.get('hudDay')} ${c.currentDay}',
          style: const TextStyle(
            fontFamily: 'GnuUnifont',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8A7A58),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
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
        const SizedBox(height: 5),
        _StatBar(
          label: AppStrings.get('charStatSanity'),
          current: c.sanity,
          max: 100,
          color: const Color(0xFF9966BB),
        ),
        const SizedBox(height: 5),
        // Độ bền Lồng Đèn
        _StatBar(
          label: AppStrings.get('hudLantern'),
          current: c.lanternDurability,
          max: 100,
          color: c.lanternDurability >= 70
              ? const Color(0xFFD4A843)
              : c.lanternDurability >= 30
                  ? const Color(0xFFCC8833)
                  : const Color(0xFF882222),
        ),
        // Biểu tượng Hoảng Loạn khi độ sáng dưới ngưỡng
        if (c.isPanicking)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '?  ${AppStrings.get('lanternPanic')}',
              style: const TextStyle(
                fontFamily: 'GnuUnifont',
                fontSize: 10,
                color: Color(0xFFCC4444),
              ),
            ),
          ),
        const SizedBox(height: 6),
        // Tro Tàn
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/items/ash_currency.png',
              width: 14,
              height: 14,
              filterQuality: FilterQuality.none,
            ),
            const SizedBox(width: 4),
            Text(
              '${c.embers}',
              style: const TextStyle(
                fontFamily: 'GnuUnifont',
                fontSize: 11,
                fontWeight: FontWeight.bold,
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
          onTap: () {
            setState(() {
              _showExplore  = true;
              _showCharacter = false;
              _showSettings  = false;
            });
          },
        ),
        const SizedBox(height: 8),
        _HubButton(
          label: AppStrings.get('templeActionTrain'),
          onTap: () => setState(() {
            _showTraining = true;
            _showCharacter = false;
            _showSettings = false;
          }),
        ),
        const SizedBox(height: 8),
        _HubButton(
          label: AppStrings.get('templeActionRest'),
          onTap: _doRest,
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Widget con dùng trong Hub
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
          color: _pressed ? const Color(0xFF1A1206) : const Color(0xCC080808),
          border: Border.all(
            color: _pressed ? const Color(0xFFD4A843) : const Color(0xFF4A3618),
            width: 1,
          ),
        ),
        child: CustomPaint(
          painter: _GearPainter(
            color: _pressed ? const Color(0xFFFFD070) : const Color(0xFFD4A843),
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
            Rect.fromLTWH(padX + col * cw, padY + row * ch, cw, ch),
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