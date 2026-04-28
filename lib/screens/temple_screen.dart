import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one_hundred_sunless_days/l10n/app_strings.dart';
import 'package:one_hundred_sunless_days/models/character.dart';
import 'package:one_hundred_sunless_days/models/inventory.dart';
import 'package:one_hundred_sunless_days/models/item.dart';
import 'package:one_hundred_sunless_days/models/lantern.dart';
import 'package:one_hundred_sunless_days/screens/combat_screen.dart';
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
    if (result != null && result.navigateToCombat) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CombatScreen(
          character: widget.character,
          startGroggy: true,
        ),
      ));
    }
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

          // ── Màn hình kết quả nghỉ ngơi (overlay toàn màn hình)
          if (_restResult != null)
            _RestResultOverlay(
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
              '⚠ ${AppStrings.get('lanternPanic')}',
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
              widget.character.lanternDurability = (widget.character.lanternDurability -
                      LanternSystem.exploreCost)
                  .clamp(0, 100);
              // Tiêu thụ bonus Kẻ Mù nếu có
              widget.character.blindWhisperBonusActive = false;
            });
          },
        ),
        const SizedBox(height: 8),
        _HubButton(
          label: AppStrings.get('templeActionTrain'),
          onTap: () {}, // TODO: mở màn hình tập luyện
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
// Overlay kết quả Nghỉ Ngơi
// ────────────────────────────────────────────────────────────────────────────

class _RestResultOverlay extends StatelessWidget {
  final RestResult result;
  final Character character;
  final VoidCallback onContinue;

  const _RestResultOverlay({
    required this.result,
    required this.character,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final r = result;
    return GestureDetector(
      onTap: onContinue,
      child: Container(
        color: const Color(0xEE060606),
        alignment: Alignment.center,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Tiêu đề ngày mới ──────────────────────────────────
                Text(
                  AppStrings.get('restTitleDay')
                      .replaceFirst('%d', '${r.newDay}'),
                  style: const TextStyle(
                    fontFamily: 'GnuUnifont',
                    fontSize: 20,
                    color: Color(0xFFD4A843),
                    letterSpacing: 4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Divider(color: Color(0xFF2A2010)),
                const SizedBox(height: 16),

                // ── Sự kiện đêm ───────────────────────────────────────
                _RestEventBadge(event: r.event),
                const SizedBox(height: 16),

                // ── Danh sách thay đổi chỉ số ─────────────────────────
                _restLine('+', '${AppStrings.get('templeStatStamina')}',
                    r.nightRaidHalfStamina
                        ? AppStrings.get('restStaminaHalf')
                        : r.toxicFogActive
                            ? AppStrings.get('restStaminaHalfFog')
                            : AppStrings.get('restStaminaFull'),
                    positive: true),
                _restLine('+', '${AppStrings.get('templeStatHp')}',
                    '+${r.hpHealed}', positive: true),
                _restLine(
                  r.sanityChange >= 0 ? '+' : '−',
                  AppStrings.get('charStatSanity'),
                  '${r.sanityChange >= 0 ? '+' : ''}${r.sanityChange}',
                  positive: r.sanityChange >= 0,
                ),
                _restLine('−', AppStrings.get('templeStatHunger'),
                    '−${r.hungerLost}', positive: false),
                _restLine('−', AppStrings.get('hudLantern'),
                    '−${r.lanternCost}', positive: false),
                if (r.starvationDamage)
                  _restLine('!', AppStrings.get('restStarvation'),
                      '−${r.starvationHpLost} ${AppStrings.get('templeStatHp')}',
                      positive: false),
                if (r.embersLost > 0)
                  _restLine('!', AppStrings.get('restEmberThiefStole'),
                      '−${r.embersLost} ${AppStrings.get('lanternRefuelCost')}',
                      positive: false),
                if (r.foodStolen != null)
                  _restLine('!', AppStrings.get('restEmberThiefStole'),
                      '−1 ${AppStrings.get(r.foodStolen!.nameKey)}',
                      positive: false),
                if (r.blindWhisperBonus)
                  _restLine('✦', AppStrings.get('restBlindWhisperBonus'),
                      '+20%', positive: true),

                // ── Hồi ức u buồn ─────────────────────────────────────
                if (r.humanityChange > 0)
                  _restLine('+', AppStrings.get('restSadMemoryHumanity'),
                      '+${r.humanityChange}', positive: true),
                if (r.humanityChange < 0)
                  _restLine('!', AppStrings.get('restOutsidePleaHumanity'),
                      '${r.humanityChange}', positive: false),
                if (r.bonusStaminaLoss > 0)
                  _restLine('!', AppStrings.get('restSadMemoryStamina'),
                      '−${r.bonusStaminaLoss}', positive: false),

                // ── Lời cầu cứu ngoài cửa ─────────────────────────────
                if (r.outsidePleaItem != null)
                  _restLine('+', AppStrings.get('restOutsidePleaLoot'),
                      '+1 ${AppStrings.get(r.outsidePleaItem!.nameKey)}',
                      positive: true),

                // ── Cơn bão sương độc ─────────────────────────────────
                if (r.toxicFogActive)
                  _restLine('!', AppStrings.get('restToxicFogStatus'),
                      '', positive: false),

                // ── Khúc hát từ rường cột ─────────────────────────────
                if (r.vaultSongExtraHp > 0)
                  _restLine('+', AppStrings.get('restVaultSongExtraHp'),
                      '+${r.vaultSongExtraHp}', positive: true),
                if (r.vaultSongExtraLanternCost > 0)
                  _restLine('!', AppStrings.get('restVaultSongExtraLantern'),
                      '−${r.vaultSongExtraLanternCost}', positive: false),

                // ── Sự soi rọi của Tro tàn ────────────────────────────
                if (r.ashFlareActive) ...[
                  _restLine('★', AppStrings.get('restAshFlareLantern'),
                      '±0', positive: true),
                  _restLine('★', AppStrings.get('restAshFlareSanity'),
                      '100%', positive: true),
                  _restLine('★', AppStrings.get('restAshFlareStatus'),
                      '', positive: true),
                ],

                // ── Kẻ dòm ngó vô hình ────────────────────────────────
                if (r.invisibleWatcherActive)
                  _restLine('!', AppStrings.get('restInvisibleWatcherStatus'),
                      '', positive: false),
                const SizedBox(height: 24),

                // ── Tap to continue / cảnh báo combat ────────────────
                Text(
                  r.navigateToCombat
                      ? AppStrings.get('restTapToCombat')
                      : AppStrings.get('restTapToContinue'),
                  style: TextStyle(
                    fontFamily: 'GnuUnifont',
                    fontSize: 10,
                    color: r.navigateToCombat
                        ? const Color(0xFFCC4433)
                        : const Color(0xFF4A3A28),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _restLine(String prefix, String label, String value,
      {required bool positive}) {
    final color = positive ? const Color(0xFF88AA66) : const Color(0xFFCC5544);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            child: Text(prefix,
                style: TextStyle(
                    fontFamily: 'GnuUnifont', fontSize: 11, color: color)),
          ),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontFamily: 'GnuUnifont',
                    fontSize: 11,
                    color: Color(0xFF8A8478))),
          ),
          Text(value,
              style: TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

/// Badge mô tả sự kiện đêm.
class _RestEventBadge extends StatelessWidget {
  final NightEvent event;
  const _RestEventBadge({required this.event});

  @override
  Widget build(BuildContext context) {
    final title = AppStrings.get(_eventTitleKey(event));
    final desc = AppStrings.get(_eventDescKey(event));
    final color = _eventColor(event);
    final imagePath = _eventImagePath(event);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
        color: color.withValues(alpha: 0.07),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ảnh minh hoạ sự kiện ────────────────────────────────
          ClipRect(
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                filterQuality: FilterQuality.none,
              ),
            ),
          ),
          // ── Tiêu đề + mô tả ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'GnuUnifont',
                    fontSize: 12,
                    color: color,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: const TextStyle(
                    fontFamily: 'GnuUnifont',
                    fontSize: 10,
                    color: Color(0xFF8A8478),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _eventTitleKey(NightEvent e) => switch (e) {
        NightEvent.deepSleep         => 'nightEventDeepSleepTitle',
        NightEvent.nightmare         => 'nightEventNightmareTitle',
        NightEvent.blindWhisper      => 'nightEventBlindWhisperTitle',
        NightEvent.emberThief        => 'nightEventEmberThiefTitle',
        NightEvent.nightRaid         => 'nightEventNightRaidTitle',
        NightEvent.sadMemory         => 'nightEventSadMemoryTitle',
        NightEvent.outsidePlea       => 'nightEventOutsidePleaTitle',
        NightEvent.toxicFog          => 'nightEventToxicFogTitle',
        NightEvent.vaultSong         => 'nightEventVaultSongTitle',
        NightEvent.ashFlare          => 'nightEventAshFlareTitle',
        NightEvent.invisibleWatcher  => 'nightEventInvisibleWatcherTitle',
      };

  String _eventDescKey(NightEvent e) => switch (e) {
        NightEvent.deepSleep         => 'nightEventDeepSleepDesc',
        NightEvent.nightmare         => 'nightEventNightmareDesc',
        NightEvent.blindWhisper      => 'nightEventBlindWhisperDesc',
        NightEvent.emberThief        => 'nightEventEmberThiefDesc',
        NightEvent.nightRaid         => 'nightEventNightRaidDesc',
        NightEvent.sadMemory         => 'nightEventSadMemoryDesc',
        NightEvent.outsidePlea       => 'nightEventOutsidePleaDesc',
        NightEvent.toxicFog          => 'nightEventToxicFogDesc',
        NightEvent.vaultSong         => 'nightEventVaultSongDesc',
        NightEvent.ashFlare          => 'nightEventAshFlareDesc',
        NightEvent.invisibleWatcher  => 'nightEventInvisibleWatcherDesc',
      };

  Color _eventColor(NightEvent e) => switch (e) {
        NightEvent.deepSleep         => const Color(0xFF5588AA), // xanh dương – bình yên
        NightEvent.nightmare         => const Color(0xFF884466), // tím sẫm – kinh dị
        NightEvent.blindWhisper      => const Color(0xFF88AA66), // xanh lá – may mắn
        NightEvent.emberThief        => const Color(0xFFCC8833), // cam – cảnh báo
        NightEvent.nightRaid         => const Color(0xFFCC4433), // đỏ – nguy hiểm
        NightEvent.sadMemory         => const Color(0xFF8899CC), // xanh nhạt – cảm xúc
        NightEvent.outsidePlea       => const Color(0xFF887766), // nâu xám – lưỡng nan
        NightEvent.toxicFog          => const Color(0xFF668855), // xanh độc
        NightEvent.vaultSong         => const Color(0xFF9966AA), // tím – ám ảnh
        NightEvent.ashFlare          => const Color(0xFFDDB844), // vàng rực – hiếm
        NightEvent.invisibleWatcher  => const Color(0xFF556677), // xám lạnh – kinh dị
      };

  static const String _restBase = 'assets/images/backgrounds/rest/';

  String _eventImagePath(NightEvent e) => switch (e) {
        NightEvent.deepSleep         => '${_restBase}deep_sleep.png',
        NightEvent.nightmare         => '${_restBase}nightmare_cannibal_shadows.png',
        NightEvent.blindWhisper      => '${_restBase}blind_one_whisper_noir.png',
        NightEvent.emberThief        => '${_restBase}ash_rat_thief.png',
        NightEvent.nightRaid         => '${_restBase}raid_monster_confrontation.png',
        NightEvent.sadMemory         => '${_restBase}sad_memory_family_feast.png',
        NightEvent.outsidePlea       => '${_restBase}desperate_beggar_exterior_gothic_door.png',
        NightEvent.toxicFog          => '${_restBase}toxic_fog_storm_choking.png',
        NightEvent.vaultSong         => '${_restBase}haunting_song_from_rafters.png',
        NightEvent.ashFlare          => '${_restBase}skull_lantern_sacred_radiance_grayscale.png',
        NightEvent.invisibleWatcher  => '${_restBase}invisible_watcher_awakening_horror.png',
      };
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
        Container(
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
    ),

    // ── Toast thông báo (overlay phía dưới panel) ─────────────────
    if (_toastMessage != null)
      Positioned(
        bottom: 32,
        left: 24,
        right: 24,
        child: IgnorePointer(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xF0080808),
              border: Border.all(color: const Color(0xFF4A3A28), width: 1),
            ),
            child: Text(
              _toastMessage!,
              style: const TextStyle(
                fontFamily: 'GnuUnifont',
                fontSize: 12,
                color: Color(0xFFD4A843),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
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
                  // Nhãn "ĐỘC NHẤT" ở góc dưới trái
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
                  color: isUnique
                      ? const Color(0xFFD4A843)
                      : const Color(0xFFCEC8B0),
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
              '▸',
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
    final bool canUse = !item.hasFlag(ItemFlag.material) &&
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
                border: item.isUnique
                    ? Border.all(color: const Color(0xFFD4A843), width: 2)
                    : Border.all(color: const Color(0xFF2A2010), width: 1),
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
                        : '×${entry.quantity}  |  ${_groupLabel(item.group)}',
                    style: TextStyle(
                      fontFamily: 'GnuUnifont',
                      fontSize: 10,
                      color: item.isUnique
                          ? const Color(0xFFD4A843)
                          : const Color(0xFF6A5A38),
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
        if (item.healsToFull) ...[
          _EffectLine('+', AppStrings.get('itemEffectHealFull')),
        ],
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
          _EffectLine('', AppStrings.get('itemEffectDrainStamina'), positive: false),

        // Cờ đặc biệt
        if (item.hasFlag(ItemFlag.noTurnCost))
          _EffectLine('★', AppStrings.get('itemFlagNoTurnCost'), positive: true),
        if (item.hasFlag(ItemFlag.passive))
          _EffectLine('★', AppStrings.get('itemFlagPassive'), positive: true),
        if (item.hasFlag(ItemFlag.combatOnly))
          _EffectLine('★', AppStrings.get('itemFlagCombatOnly'), positive: true),
        if (item.blocksLethalHit)
          _EffectLine('★', AppStrings.get('itemFlagBlockLethal'), positive: true),
        if (item.preventNightRaid)
          _EffectLine('★', AppStrings.get('itemFlagNoNightRaid'), positive: true),

        const SizedBox(height: 24),

        // Nút Sử Dụng
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
    final bool canRefuel = LanternSystem.canRefuel(c.embers) &&
        c.lanternDurability < 100;
    final int maxTimes = c.embers ~/ LanternSystem.refuelEmberCost;
    final int clampedTimes = maxTimes
        .clamp(0, (100 - c.lanternDurability) ~/ LanternSystem.refuelBrightnessGain);

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

  /// Trả về lý do tại sao không thể dùng vật phẩm, hoặc null nếu được dùng.
  String? _useBlockReason(Character c, Item item) {
    // Chỉ dùng được trong chiến đấu
    if (item.hasFlag(ItemFlag.combatOnly)) {
      return AppStrings.get('itemOnlyInCombat');
    }
    // Nếu không có hiệu ứng tích cực thì bỏ qua kiểm tra đầy
    if (item.effects.isEmpty && !item.healsToFull) return null;

    // Nếu tất cả hiệu ứng tích cực đều bị capped → không cho dùng
    final posEffects = item.effects.where((fx) => fx.amount > 0).toList();
    if (item.healsToFull && c.hp < c.maxHp) return null; // healsToFull có tác dụng
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

  /// Nhãn hiển thị nhóm vật phẩm.
  String _groupLabel(ItemGroup g) {
    return switch (g) {
      ItemGroup.food    => AppStrings.get('groupFood'),
      ItemGroup.medical => AppStrings.get('groupMedical'),
      ItemGroup.mental  => AppStrings.get('groupMental'),
      ItemGroup.combat  => AppStrings.get('groupCombat'),
      ItemGroup.core    => AppStrings.get('groupCore'),
    };
  }

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
    final suffix = fx.chance < 1.0
        ? '  (${(fx.chance * 100).round()}%)'
        : '';
    final dur = fx.durationDays > 0
        ? '  [${fx.durationDays}d]'
        : '';
    return '$statName  $sign${fx.amount}$dur$suffix';
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
        // ── Phòng Thủ – chỉ số tổng hợp (trang bị / kỹ năng / cảnh giới) ──
        _StatRow(
          label: AppStrings.get('charStatDef'),
          value: c.defense,
          max: null,
          color: const Color(0xFF778899),
          desc: AppStrings.get('charDescDef'),
          isExpanded: _expandedStatKey == 'def',
          onTap: () => toggle('def'),
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
  /// null = không có thanh tiến trình (chỉ số không giới hạn bởi cap).
  final int? max;
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
    final double ratio = (max != null && max! > 0)
        ? (value / max!).clamp(0.0, 1.0)
        : 0.0;
    final String valueText = (showFraction && max != null) ? '$value/$max' : '$value';

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

// ── Dòng hiệu ứng trong chi tiết vật phẩm ────────────────────────────────────

class _EffectLine extends StatelessWidget {
  final String prefix;
  final String text;
  final bool positive;

  const _EffectLine(this.prefix, this.text, {this.positive = true});

  @override
  Widget build(BuildContext context) {
    final color = positive ? const Color(0xFF88AA66) : const Color(0xFFCC5544);
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
