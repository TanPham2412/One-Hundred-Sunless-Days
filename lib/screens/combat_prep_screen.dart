import 'package:flutter/material.dart';
import 'package:one_hundred_sunless_days/l10n/app_strings.dart';
import 'package:one_hundred_sunless_days/models/character.dart';
import 'package:one_hundred_sunless_days/models/enemy_data.dart';
import 'package:one_hundred_sunless_days/models/monster.dart';
import 'package:one_hundred_sunless_days/screens/combat_screen.dart';

// ────────────────────────────────────────────────────────────────────────────
// Màn hình chuẩn bị chiến đấu
// ────────────────────────────────────────────────────────────────────────────

/// Hiển thị thông tin quái vật trước khi vào combat.
/// Người chơi phải bấm [ CHIẾN ĐẤU ] mới chuyển sang [CombatScreen].
class CombatPrepScreen extends StatefulWidget {
  final Character character;
  final Monster monster;

  /// Dữ liệu chiến đấu của kẻ địch tương ứng với [monster].
  final EnemyData enemyData;

  /// true nếu người chơi đang bị trạng thái [Ngái Ngủ] khi vào trận.
  final bool startGroggy;

  const CombatPrepScreen({
    super.key,
    required this.character,
    required this.monster,
    required this.enemyData,
    this.startGroggy = false,
  });

  @override
  State<CombatPrepScreen> createState() => _CombatPrepScreenState();
}

class _CombatPrepScreenState extends State<CombatPrepScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _enterCombat() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => CombatScreen(
          character: widget.character,
          enemies: [
            (monster: widget.monster, data: widget.enemyData),
          ],
          startGroggy: widget.startGroggy,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final monster = widget.monster;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Column(
            children: [
              // ── Ảnh quái vật (phần trên, ~45% chiều cao) ──────────────
              Expanded(
                flex: 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Ảnh pixel-art
                    Image.asset(
                      monster.imagePath,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                    ),
                    // Vignette tối ở 4 cạnh
                    _buildVignette(),
                  ],
                ),
              ),

              // ── Tên + mô tả (phần dưới) ────────────────────────────────
              Expanded(
                flex: 11,
                child: _buildInfoPanel(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Vignette tối bao quanh ảnh ──────────────────────────────────────────

  Widget _buildVignette() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.9,
          colors: [Colors.transparent, Color(0xCC0A0A0A)],
          stops: [0.5, 1.0],
        ),
      ),
    );
  }

  // ── Panel thông tin quái vật ─────────────────────────────────────────────

  Widget _buildInfoPanel() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF2A1A0A), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Divider vàng mờ
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 32),
            color: const Color(0xFF6A4820),
          ),
          const SizedBox(height: 16),

          // ── Tên quái vật ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              AppStrings.get(widget.monster.nameKey),
              style: const TextStyle(
                fontFamily: 'GnuUnifont',
                fontSize: 15,
                color: Color(0xFFD4A843),
                letterSpacing: 3,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 4),

          // ── Phụ đề / tên tiếng Anh ───────────────────────────────────
          Text(
            AppStrings.get(widget.monster.subtitleKey),
            style: const TextStyle(
              fontFamily: 'GnuUnifont',
              fontSize: 10,
              color: Color(0xFF5A4A35),
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 14),

          // ── Dòng phân cách ────────────────────────────────────────────
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            color: const Color(0xFF2A1A0A),
          ),

          const SizedBox(height: 14),

          // ── Mô tả (scrollable) ────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                AppStrings.get(widget.monster.descKey),
                style: const TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 10,
                  color: Color(0xFF8A7E68),
                  height: 1.8,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Nút CHIẾN ĐẤU ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: GestureDetector(
              onTap: _enterCombat,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF8A2020), width: 1),
                  color: const Color(0xFF1A0808),
                ),
                child: Text(
                  AppStrings.get('combatPrepFight'),
                  style: const TextStyle(
                    fontFamily: 'GnuUnifont',
                    fontSize: 13,
                    color: Color(0xFFCC3333),
                    letterSpacing: 4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
