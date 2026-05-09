import 'package:flutter/material.dart';

// ────────────────────────────────────────────────────────────────────────────
// Widget toast thông báo dùng chung
// ────────────────────────────────────────────────────────────────────────────

/// Toast thông báo kết quả hành động (dùng vật phẩm, lỗi, v.v.).
/// Đặt bên trong [Positioned] khi dùng trong một [Stack].
class GameToast extends StatelessWidget {
  final String message;

  const GameToast({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xF0080808),
          border: Border.all(color: const Color(0xFF4A3A28), width: 1),
        ),
        child: Text(
          message,
          style: const TextStyle(
            fontFamily: 'GnuUnifont',
            fontSize: 12,
            color: Color(0xFFD4A843),
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
