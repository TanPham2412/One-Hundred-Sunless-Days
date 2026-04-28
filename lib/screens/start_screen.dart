import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one_hundred_sunless_days/l10n/app_strings.dart';
import 'package:one_hundred_sunless_days/screens/story_screen.dart';
import 'package:one_hundred_sunless_days/widgets/settings_panel.dart';

// ────────────────────────────────────────────────────────────────────────────
// Màn hình bắt đầu
// ────────────────────────────────────────────────────────────────────────────

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();

  /// Thoát ứng dụng đúng cách trên từng nền tảng.
  static void exitApp() {
    if (Platform.isIOS) {
      // iOS không cho phép tự tắt app theo HIG của Apple – bỏ qua.
      return;
    }
    if (Platform.isAndroid) {
      SystemNavigator.pop();
      return;
    }
    exit(0);
  }
}

class _StartScreenState extends State<StartScreen> {
  bool _showSettings = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Ảnh nền pixel art ──────────────────────────────────────────
          Image.asset(
            'assets/images/backgrounds/start_screen.png',
            fit: BoxFit.cover,
            // Tắt lọc màu để giữ nguyên độ sắc nét của pixel art
            filterQuality: FilterQuality.none,
          ),

          // ── Lớp tối dần từ dưới lên để nổi bật các nút ────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.65,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x00000000),
                      Color(0xCC000000),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Tiêu đề + nút menu (cùng một cột, neo vào đỉnh) ──────────
          Positioned(
            top: 130,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _TitleText('ONE HUNDRED'),
                const SizedBox(height: 4),
                const _TitleText('SUNLESS DAYS'),
                const SizedBox(height: 28),
                // ── Các nút menu ────────────────────────────────────────
                _PixelMenuButton(
                  label: AppStrings.get('startBtnNew'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const StoryScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                // Nút bị vô hiệu khi chưa có save game
                _PixelMenuButton(
                  label: AppStrings.get('startBtnContinue'),
                  onPressed: null,
                ),
                const SizedBox(height: 10),
                _PixelMenuButton(
                  label: AppStrings.get('startBtnSettings'),
                  onPressed: () => setState(() => _showSettings = true),
                ),
                const SizedBox(height: 10),
                _PixelMenuButton(
                  label: AppStrings.get('startBtnQuit'),
                  variant: _ButtonVariant.danger,
                  onPressed: StartScreen.exitApp,
                ),
              ],
            ),
          ),

          // ── Bảng cài đặt (overlay toàn màn hình) ─────────────────────
          if (_showSettings)
            SettingsPanel(
              onClose: () => setState(() => _showSettings = false),
              onLocaleChanged: () => setState(() {}),
              showSaveLoad: false,
              onQuit: StartScreen.exitApp,
            ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Widget tiêu đề
// ────────────────────────────────────────────────────────────────────────────

class _TitleText extends StatelessWidget {
  final String text;
  const _TitleText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'ThaleahFat',
        fontSize: 42,
        color: Color(0xFFD4A843),
        letterSpacing: 4,
        shadows: [
          // Bóng đổ đậm để nổi bật trên nền tối
          Shadow(color: Color(0xFF000000), offset: Offset(2, 2)),
          Shadow(color: Color(0xFF000000), offset: Offset(-1, -1)),
          // Hào quang màu hổ phách
          Shadow(
            color: Color(0x887A4A00),
            offset: Offset(0, 0),
            blurRadius: 10,
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Kiểu nút
// ────────────────────────────────────────────────────────────────────────────

enum _ButtonVariant {
  /// Nút thông thường – viền/chữ màu hổ phách.
  normal,

  /// Nút nguy hiểm (THOÁT) – viền/chữ màu đỏ.
  danger,
}

// ────────────────────────────────────────────────────────────────────────────
// Widget nút pixel art
// ────────────────────────────────────────────────────────────────────────────

class _PixelMenuButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final _ButtonVariant variant;

  const _PixelMenuButton({
    required this.label,
    required this.onPressed,
    this.variant = _ButtonVariant.normal,
  });

  @override
  State<_PixelMenuButton> createState() => _PixelMenuButtonState();
}

class _PixelMenuButtonState extends State<_PixelMenuButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  void _onTapDown(TapDownDetails _) {
    if (_enabled) setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    if (_enabled) {
      setState(() => _pressed = false);
      widget.onPressed!();
    }
  }

  void _onTapCancel() {
    if (_enabled) setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    // Màu chữ theo trạng thái
    final Color textColor = switch ((_enabled, widget.variant)) {
      (false, _) => const Color(0xFF505050),
      (true, _ButtonVariant.danger) => const Color(0xFFFF7070),
      _ => const Color(0xFFE8C87A),
    };

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: SizedBox(
        width: 200,
        child: CustomPaint(
          painter: _PixelBorderPainter(
            pressed: _pressed,
            enabled: _enabled,
            variant: widget.variant,
          ),
          child: Padding(
            // Khi nhấn: chữ dịch xuống 2px để tạo cảm giác nhấn vật lý
            padding: EdgeInsets.fromLTRB(
              14,
              _pressed ? 11 : 9,
              14,
              _pressed ? 7 : 9,
            ),
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'GnuUnifont',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 1.5,
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// CustomPainter vẽ viền pixel art 3 lớp
//
// Cấu trúc viền (mỗi đơn vị = 2 logical pixel):
//   [borderOuter] – viền ngoài cùng mọi phía
//   [highlight]   – cạnh trên + trái (ánh sáng)
//   [shadow]      – cạnh dưới + phải (bóng tối)
//   [fill]        – nền bên trong
// Khi _pressed: highlight/shadow đổi chỗ nhau.
// ────────────────────────────────────────────────────────────────────────────

class _PixelBorderPainter extends CustomPainter {
  final bool pressed;
  final bool enabled;
  final _ButtonVariant variant;

  const _PixelBorderPainter({
    required this.pressed,
    required this.enabled,
    required this.variant,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double p = 2.0; // kích thước 1 "pixel" viền

    // ── Bảng màu theo trạng thái ──────────────────────────────────────────
    final Color fill;
    final Color borderOuter;
    final Color highlight;
    final Color shadow;

    if (!enabled) {
      fill = const Color(0xFF111111);
      borderOuter = const Color(0xFF252525);
      highlight = const Color(0xFF333333);
      shadow = const Color(0xFF0a0a0a);
    } else if (variant == _ButtonVariant.danger) {
      fill = pressed ? const Color(0xFF1C0808) : const Color(0xFF280E0E);
      borderOuter = const Color(0xFF5C1C1C);
      highlight = const Color(0xFFCC4040);
      shadow = const Color(0xFF0E0404);
    } else {
      fill = pressed ? const Color(0xFF140E06) : const Color(0xFF1E1508);
      borderOuter = const Color(0xFF4A3618);
      highlight = const Color(0xFFB8903A);
      shadow = const Color(0xFF0C0804);
    }

    final paint = Paint()..style = PaintingStyle.fill;
    final double w = size.width;
    final double h = size.height;

    // Lớp 1: nền bên trong (tránh 1 pixel mỗi cạnh để lộ viền ngoài)
    paint.color = fill;
    canvas.drawRect(Rect.fromLTWH(p, p, w - p * 2, h - p * 2), paint);

    // Lớp 2: viền ngoài cùng
    paint.color = borderOuter;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, p), paint);           // trên
    canvas.drawRect(Rect.fromLTWH(0, h - p, w, p), paint);       // dưới
    canvas.drawRect(Rect.fromLTWH(0, p, p, h - p * 2), paint);   // trái
    canvas.drawRect(Rect.fromLTWH(w - p, p, p, h - p * 2), paint); // phải

    // Lớp 3: viền bên trong tạo hiệu ứng 3D pixel
    final Color innerTop = pressed ? shadow : highlight;
    final Color innerBot = pressed ? highlight : shadow;

    paint.color = innerTop;
    // cạnh trên trong
    canvas.drawRect(Rect.fromLTWH(p, p, w - p * 2, p), paint);
    // cạnh trái trong
    canvas.drawRect(Rect.fromLTWH(p, p * 2, p, h - p * 3), paint);

    paint.color = innerBot;
    // cạnh dưới trong
    canvas.drawRect(Rect.fromLTWH(p, h - p * 2, w - p * 2, p), paint);
    // cạnh phải trong
    canvas.drawRect(Rect.fromLTWH(w - p * 2, p * 2, p, h - p * 3), paint);
  }

  @override
  bool shouldRepaint(_PixelBorderPainter old) =>
      old.pressed != pressed ||
      old.enabled != enabled ||
      old.variant != variant;
}
