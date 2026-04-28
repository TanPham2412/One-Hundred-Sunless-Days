import 'package:flutter/material.dart';
import 'package:one_hundred_sunless_days/l10n/app_strings.dart';

// ────────────────────────────────────────────────────────────────────────────
// Bảng cài đặt dùng chung (start_screen & temple_screen)
// ────────────────────────────────────────────────────────────────────────────

/// Overlay bảng cài đặt.
///
/// - [onClose]: đóng bảng.
/// - [onLocaleChanged]: gọi sau khi đổi ngôn ngữ để cha rebuild.
/// - [onQuit]: hành động khi nhấn nút THOÁT (platform exit hoặc navigate).
/// - [showSaveLoad]: hiện nút Lưu Game & Bắt Đầu Lại (ẩn ở start screen).
class SettingsPanel extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onLocaleChanged;
  final VoidCallback onQuit;
  final bool showSaveLoad;

  const SettingsPanel({
    super.key,
    required this.onClose,
    required this.onLocaleChanged,
    required this.onQuit,
    this.showSaveLoad = false,
  });

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  // Trạng thái âm thanh (chưa kết nối audio engine)
  bool _soundOn = true;

  // Danh sách ngôn ngữ hỗ trợ: [locale code, nhãn hiển thị]
  static const List<(String, String)> _langs = [
    ('en', 'EN'),
    ('vi', 'VI'),
  ];

  @override
  Widget build(BuildContext context) {
    // Nhấn vùng tối ngoài để đóng
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: const Color(0x99000000),
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {}, // Chặn tap lan ra ngoài hộp
          child: Container(
            width: 288,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              border: Border.all(color: const Color(0xFF4A3618), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tiêu đề
                Text(
                  AppStrings.get('settingsTitle'),
                  style: const TextStyle(
                    fontFamily: 'GnuUnifont',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4A843),
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 18),

                // ── Ngôn ngữ ────────────────────────────────────────────
                _buildDivider(),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppStrings.get('settingsLanguage'),
                    style: _labelStyle(),
                  ),
                ),
                const SizedBox(height: 8),
                // Lưới 2 hàng × 3 cột
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _langs.map((pair) {
                    final String code = pair.$1;
                    final String label = pair.$2;
                    return _LangButton(
                      label: label,
                      selected: AppStrings.locale == code,
                      onTap: () {
                        AppStrings.setLocale(code);
                        widget.onLocaleChanged();
                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // ── Âm thanh ────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.get('settingsSound'),
                      style: _labelStyle(),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _soundOn = !_soundOn),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _soundOn
                                ? const Color(0xFF4A8A4A)
                                : const Color(0xFF6A3030),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _soundOn
                              ? AppStrings.get('settingsSoundOn')
                              : AppStrings.get('settingsSoundOff'),
                          style: TextStyle(
                            fontFamily: 'GnuUnifont',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _soundOn
                                ? const Color(0xFF88CC88)
                                : const Color(0xFFCC6666),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Lưu & bắt đầu lại (chỉ hiện trong game) ────────────
                if (widget.showSaveLoad) ...[
                  const SizedBox(height: 16),
                  _buildDivider(),
                  const SizedBox(height: 12),
                  _SettingsButton(
                    label: AppStrings.get('settingsSave'),
                    onTap: () {}, // TODO: lưu game
                  ),
                  const SizedBox(height: 8),
                  _SettingsButton(
                    label: AppStrings.get('settingsNewGame'),
                    danger: true,
                    onTap: () {}, // TODO: xác nhận bắt đầu lại
                  ),
                ],

                // ── Thoát ───────────────────────────────────────────────
                const SizedBox(height: 16),
                _buildDivider(),
                const SizedBox(height: 12),
                _SettingsButton(
                  label: AppStrings.get('settingsQuit'),
                  danger: true,
                  onTap: widget.onQuit,
                ),
                const SizedBox(height: 16),

                // Nút đóng
                GestureDetector(
                  onTap: widget.onClose,
                  child: Text(
                    '[ ${AppStrings.get('close')} ]',
                    style: const TextStyle(
                      fontFamily: 'GnuUnifont',
                      fontSize: 12,
                      color: Color(0xFF5A4A28),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() =>
      Container(height: 1, color: const Color(0xFF2A2010));

  TextStyle _labelStyle() => const TextStyle(
        fontFamily: 'GnuUnifont',
        fontSize: 12,
        color: Color(0xFFCEC8B0),
      );
}

// ────────────────────────────────────────────────────────────────────────────
// Widget nút ngôn ngữ
// ────────────────────────────────────────────────────────────────────────────

class _LangButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2A1C08) : Colors.transparent,
          border: Border.all(
            color:
                selected ? const Color(0xFFD4A843) : const Color(0xFF4A3618),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'GnuUnifont',
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected
                ? const Color(0xFFD4A843)
                : const Color(0xFF8A7A58),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Widget nút trong bảng cài đặt
// ────────────────────────────────────────────────────────────────────────────

class _SettingsButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool danger;

  const _SettingsButton({
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                danger ? const Color(0xFF6A2020) : const Color(0xFF4A3618),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'GnuUnifont',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: danger
                ? const Color(0xFFCC6666)
                : const Color(0xFFCEC8B0),
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
