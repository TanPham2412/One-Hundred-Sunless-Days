import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_strings.dart';
import '../models/character.dart';
import '../models/combat_formulas.dart';
import '../models/enemy_data.dart';
import '../models/monster.dart';
import '../models/player_skill.dart';
import 'temple_screen.dart';

// ────────────────────────────────────────────────────────────────────────────
// Màn Hình Chiến Đấu
// ────────────────────────────────────────────────────────────────────────────

/// Cặp thông tin hiển thị + chỉ số chiến đấu của một kẻ địch.
typedef CombatEnemy = ({Monster monster, EnemyData data});

/// Màn hình chiến đấu.
///
/// **Thể Lực chiến đấu** khởi đầu bằng [Character.maxStamina] (full),
/// độc lập hoàn toàn với [Character.stamina] ngoài thế giới:
/// sau trận, stamina ngoài thế giới giữ nguyên như trước khi vào trận.
class CombatScreen extends StatefulWidget {
  final Character character;

  /// Danh sách kẻ địch tham chiến (tối đa 4).
  final List<CombatEnemy> enemies;

  /// true nếu vào từ sự kiện Đột Kích Ban Đêm → kẻ thù đi trước.
  final bool startGroggy;

  const CombatScreen({
    super.key,
    required this.character,
    required this.enemies,
    this.startGroggy = false,
  });

  @override
  State<CombatScreen> createState() => _CombatScreenState();
}

// ── Trạng thái runtime của mỗi kẻ địch ──────────────────────────────────────

class _EnemyState {
  final Monster monster;
  final EnemyData data;
  int currentHp;
  int currentStamina;
  bool isDefending = false;

  _EnemyState({required this.monster, required this.data})
      : currentHp = data.maxHp,
        currentStamina = data.maxStamina;

  bool get isDead => currentHp <= 0;
}

// ── State ────────────────────────────────────────────────────────────────────

class _CombatScreenState extends State<CombatScreen>
    with TickerProviderStateMixin {
  // ── Chỉ số người chơi trong trận ─────────────────────────────────────────
  late int _playerHp;
  late int _combatStamina; // độc lập với character.stamina

  bool _playerDefending = false;

  // ── Kẻ địch ──────────────────────────────────────────────────────────────
  late List<_EnemyState> _enemies;

  // ── UI state ──────────────────────────────────────────────────────────────
  int? _detailEnemyIndex;
  late AnimationController _detailCtrl;
  late Animation<double> _detailAnim;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  bool _showGroggyBanner = false;

  // ── Combat state ─────────────────────────────────────────────────────────
  bool _selectingTarget = false;

  // ── Attack animation ─────────────────────────────────────────────────
  late AnimationController _attackCtrl;
  late Animation<double> _attackLunge;
  late AnimationController _slashCtrl;   // controller riêng cho hiệu ứng chém
  int? _slashTargetIndex;

  // ── Floating damage (enemy) ─────────────────────────────────────────
  AnimationController? _floatDmgCtrl;
  Animation<double>? _floatDmgY;
  Animation<double>? _floatDmgFade;
  int _floatDmgValue = 0;
  bool _floatDmgKill = false;
  int? _floatDmgTargetIndex;

  // ── Enemy lunge animation ─────────────────────────────────────────────
  late AnimationController _enemyLungeCtrl;
  late Animation<double> _enemyLungeAnim;
  int? _lungeEnemyIndex;

  // ── Player hit flash ───────────────────────────────────────────────────
  bool _playerSlashActive = false; // hiệu ứng chém trên sprite người chơi

  // ── Floating damage (player) ──────────────────────────────────────────
  AnimationController? _floatPlayerDmgCtrl;
  Animation<double>? _floatPlayerDmgY;
  Animation<double>? _floatPlayerDmgFade;
  int _floatPlayerDmgValue = 0;
  bool _floatPlayerDmgShow = false;

  // ── Floating heal (player) ────────────────────────────────────────────────
  AnimationController? _floatPlayerHealCtrl;
  Animation<double>? _floatPlayerHealY;
  Animation<double>? _floatPlayerHealFade;
  int _floatPlayerHealValue = 0;
  bool _floatPlayerHealShow = false;

  // ── Skill banner (enemy) ──────────────────────────────────────────────
  int? _skillBannerEnemyIndex;
  String _skillBannerText = '';

  // ── Kỹ năng người chơi ────────────────────────────────────────────────
  bool _selectingForDoubleSlash = false;

  // ── Chiến thắng ─────────────────────────────────────────────────────────
  bool _showVictoryPanel = false;

  @override
  void initState() {
    super.initState();
    _playerHp = widget.character.hp;
    // Thể lực chiến đấu luôn bắt đầu ở max – không phụ thuộc stamina hiện tại
    _combatStamina = widget.character.maxStamina;

    _enemies = widget.enemies
        .take(4)
        .map((e) => _EnemyState(monster: e.monster, data: e.data))
        .toList();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);

    _attackCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _attackLunge = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _attackCtrl, curve: Curves.easeOut),
    );
    _slashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _enemyLungeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _enemyLungeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _enemyLungeCtrl, curve: Curves.easeOut),
    );
    _detailCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _detailAnim = CurvedAnimation(parent: _detailCtrl, curve: Curves.easeOut);

    if (widget.startGroggy) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _showGroggyBanner = true);
      });
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _attackCtrl.dispose();
    _slashCtrl.dispose();
    _enemyLungeCtrl.dispose();
    _floatDmgCtrl?.dispose();
    _floatPlayerDmgCtrl?.dispose();
    _floatPlayerHealCtrl?.dispose();
    _detailCtrl.dispose();
    super.dispose();
  }

  // ── Panel chi tiết kẻ địch ────────────────────────────────────────────────

  void _openEnemyDetail(int index) {
    HapticFeedback.heavyImpact();
    setState(() => _detailEnemyIndex = index);
    _detailCtrl.forward(from: 0);
  }

  void _closeEnemyDetail() {
    _detailCtrl.reverse().then((_) {
      if (mounted) setState(() => _detailEnemyIndex = null);
    });
  }

  // ── Actions (UI – logic chiến đấu sẽ kết nối sau) ────────────────────────

  // Nhấn "Tấn Công" → vào/thoát chế độ chọn mục tiêu
  void _onAttack() {
    if (_enemies.every((e) => e.isDead)) return;
    setState(() {
      _playerDefending = false;
      _selectingTarget = !_selectingTarget;
    });
  }

  // Chọn mục tiêu → animation lao vào + gây sát thương
  void _onTargetSelected(int index) async {
    if (_selectingForDoubleSlash) {
      _selectingForDoubleSlash = false;
      _onDoubleSlashTarget(index);
      return;
    }
    final target = _enemies[index];
    if (target.isDead) return;

    final int rawDmg        = widget.character.totalAttack;
    final int actualDmgBase = CombatFormulas.applyArmor(rawDmg, target.data.defense);
    final int actualDmg     = target.isDefending
        ? max(1, actualDmgBase ~/ 2)
        : actualDmgBase;

    setState(() => _selectingTarget = false);

    // Phase 1: người chơi lao tới (250ms)
    await _attackCtrl.forward(from: 0);
    if (!mounted) return;

    // Áp dụng sát thương — bắt đầu slash animation (380ms, độc lập)
    setState(() {
      target.currentHp  = (target.currentHp - actualDmg).clamp(0, target.data.maxHp);
      _slashTargetIndex = index;
    });
    _slashCtrl.forward(from: 0).then((_) {
      if (mounted) setState(() => _slashTargetIndex = null);
    });
    _startFloatingDamage(index, actualDmg, target.isDead);

    // Người chơi trở về (bắt đầu sau 150ms, slash vẫn chạy song song)
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    // Phase 2: người chơi trở về (250ms)
    await _attackCtrl.reverse();
    if (!mounted) return;

    if (_enemies.every((e) => e.isDead)) {
      setState(() => _showVictoryPanel = true);
      return;
    }

    // Quái phản công sau 1 giây
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) _enemyTurn();
  }

  void _startFloatingDamage(int targetIndex, int amount, bool kill) {
    _floatDmgCtrl?.dispose();
    _floatDmgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _floatDmgY = Tween<double>(begin: 0, end: -44).animate(
      CurvedAnimation(parent: _floatDmgCtrl!, curve: Curves.easeOut),
    );
    _floatDmgFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _floatDmgCtrl!,
        curve: const Interval(0.45, 1.0, curve: Curves.easeIn),
      ),
    );
    setState(() {
      _floatDmgValue       = amount;
      _floatDmgKill        = kill;
      _floatDmgTargetIndex = targetIndex;
    });
    _floatDmgCtrl!.forward().then((_) {
      if (mounted) setState(() => _floatDmgTargetIndex = null);
    });
  }

  // ── AI quái: quyết định có nên phòng thủ không ───────────────────────────────────
  bool _enemyDecideDefend(_EnemyState e) {
    final double hpRatio = e.currentHp / e.data.maxHp;
    final double chance;
    if (hpRatio <= 0.20)      { chance = 0.65; } // nguy kịch → thường phòng thủ
    else if (hpRatio <= 0.40) { chance = 0.40; }
    else if (hpRatio <= 0.60) { chance = 0.20; }
    else                      { chance = 0.05; } // máu cao → hầu như luôn tấn công
    return Random().nextDouble() < chance;
  }

  // Lượt quái: hết phòng thủ → quyết định → lần lượt tấn công
  void _enemyTurn() async {
    final rng    = Random();
    final living = _enemies.where((e) => !e.isDead).toList();
    if (living.isEmpty) return;

    // Snapshot trạng thái phòng thủ người chơi ngay đầu lượt
    // (dùng cho tính toán damage; _playerDefending sẽ được reset ở cuối)
    final bool wasPlayerDefending = _playerDefending;

    // ── Phase 1: kết thúc phòng thủ của quái + hồi 25% thể lực ──────────────────────
    for (final e in living) {
      if (e.isDefending) {
        final int heal = (e.data.maxStamina * 0.25).round();
        setState(() {
          e.isDefending    = false;
          e.currentStamina = (e.currentStamina + heal).clamp(0, e.data.maxStamina);
        });
        await Future.delayed(const Duration(milliseconds: 200));
        if (!mounted) return;
      }
    }

    // ── Phase 2: mỗi quái quyết định hành động ─────────────────────────────
    final List<_EnemyState> normalAttackers = [];
    final List<({_EnemyState enemy, int skillSlot})> skillActors = [];

    for (final e in living) {
      if (_enemyDecideDefend(e)) {
        setState(() => e.isDefending = true);
      } else {
        final int? slot = e.data.rollActionIndex(e.currentStamina, rng);
        if (slot != null) {
          skillActors.add((enemy: e, skillSlot: slot));
        } else {
          normalAttackers.add(e);
        }
      }
    }
    if (mounted) setState(() {});

    // ── Phase 3a: kỹ năng ────────────────────────────────────────────────────
    for (final actor in skillActors) {
      final e     = actor.enemy;
      final skill = e.data.skills[actor.skillSlot];
      final int atkIndex = _enemies.indexOf(e);

      // Trừ thể lực + hiện banner tên kỹ năng
      setState(() {
        e.currentStamina       = (e.currentStamina - skill.staminaCost)
            .clamp(0, e.data.maxStamina);
        _skillBannerEnemyIndex = atkIndex;
        _skillBannerText       = AppStrings.get(skill.nameKey);
      });
      await Future.delayed(const Duration(milliseconds: 650));
      if (!mounted) return;

      if (skill.dmgMin > 0 || skill.dmgMax > 0) {
        setState(() => _lungeEnemyIndex = atkIndex);
        await _enemyLungeCtrl.forward(from: 0);
        if (!mounted) return;

        final int range     = (skill.dmgMax - skill.dmgMin).clamp(0, 9999);
        final int rawDmg    = skill.dmgMin + (range > 0 ? rng.nextInt(range + 1) : 0);
        final int dmgBase   = skill.ignoresArmor
            ? rawDmg
            : CombatFormulas.applyArmor(rawDmg, widget.character.totalDefense);
        final int actualDmg = wasPlayerDefending ? max(1, dmgBase ~/ 2) : dmgBase;

        setState(() {
          _playerHp              = (_playerHp - actualDmg).clamp(0, widget.character.maxHp);
          _playerSlashActive     = true;
          _skillBannerEnemyIndex = null;
        });
        _slashCtrl.forward(from: 0).then((_) {
          if (mounted) setState(() => _playerSlashActive = false);
        });
        _startFloatingPlayerDamage(actualDmg);

        if (skill.lifestealHp > 0) {
          setState(() {
            e.currentHp = (e.currentHp + skill.lifestealHp).clamp(0, e.data.maxHp);
          });
        }

        await Future.delayed(const Duration(milliseconds: 120));
        if (!mounted) return;
        await _enemyLungeCtrl.reverse();
        if (!mounted) return;
        setState(() => _lungeEnemyIndex = null);
      } else {
        setState(() => _skillBannerEnemyIndex = null);
      }

      if (skill.playerStaminaDrain > 0) {
        setState(() {
          _combatStamina = (_combatStamina - skill.playerStaminaDrain)
              .clamp(0, widget.character.maxStamina);
        });
      }

      if (_playerHp <= 0) {
        setState(() => _playerDefending = false);
        // TODO: màn hình thất bại
        return;
      }
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
    }

    // ── Phase 3b: tấn công thường ────────────────────────────────────────────
    for (int i = 0; i < normalAttackers.length; i++) {
      final attacker = normalAttackers[i];
      final int atkIndex = _enemies.indexOf(attacker);
      final int range    = (attacker.data.atkMax - attacker.data.atkMin).clamp(0, 9999);
      final int rawDmg   = attacker.data.atkMin + (range > 0 ? rng.nextInt(range + 1) : 0);
      final int dmgBase  = CombatFormulas.applyArmor(rawDmg, widget.character.totalDefense);
      final int actualDmg = wasPlayerDefending ? max(1, dmgBase ~/ 2) : dmgBase;

      setState(() => _lungeEnemyIndex = atkIndex);
      await _enemyLungeCtrl.forward(from: 0);
      if (!mounted) return;

      setState(() {
        _playerHp          = (_playerHp - actualDmg).clamp(0, widget.character.maxHp);
        _playerSlashActive = true;
      });
      _slashCtrl.forward(from: 0).then((_) {
        if (mounted) setState(() => _playerSlashActive = false);
      });
      _startFloatingPlayerDamage(actualDmg);

      await Future.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      await _enemyLungeCtrl.reverse();
      if (!mounted) return;
      setState(() => _lungeEnemyIndex = null);

      if (_playerHp <= 0) {
        setState(() => _playerDefending = false);
        // TODO: màn hình thất bại
        return;
      }
      if (i < normalAttackers.length - 1) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (!mounted) return;
      }
    }

    // ── Kết thúc lượt quái → lượt người chơi ────────────────────────────────
    if (wasPlayerDefending) {
      final int heal = (widget.character.maxStamina * 0.25).round();
      setState(() {
        _playerDefending = false;
        _combatStamina   = (_combatStamina + heal).clamp(0, widget.character.maxStamina);
      });
      _startFloatingPlayerHeal(heal);
    } else {
      setState(() => _playerDefending = false);
    }
    // Dừng 1 giây trước khi trả quyền cho người chơi
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  void _startFloatingPlayerDamage(int amount) {
    _floatPlayerDmgCtrl?.dispose();
    _floatPlayerDmgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _floatPlayerDmgY = Tween<double>(begin: 0, end: -44).animate(
      CurvedAnimation(parent: _floatPlayerDmgCtrl!, curve: Curves.easeOut),
    );
    _floatPlayerDmgFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _floatPlayerDmgCtrl!,
        curve: const Interval(0.45, 1.0, curve: Curves.easeIn),
      ),
    );
    setState(() {
      _floatPlayerDmgValue = amount;
      _floatPlayerDmgShow  = true;
    });
    _floatPlayerDmgCtrl!.forward().then((_) {
      if (mounted) setState(() => _floatPlayerDmgShow = false);
    });
  }

  void _startFloatingPlayerHeal(int amount) {
    _floatPlayerHealCtrl?.dispose();
    _floatPlayerHealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _floatPlayerHealY = Tween<double>(begin: 0, end: -50).animate(
      CurvedAnimation(parent: _floatPlayerHealCtrl!, curve: Curves.easeOut),
    );
    _floatPlayerHealFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _floatPlayerHealCtrl!,
        curve: const Interval(0.45, 1.0, curve: Curves.easeIn),
      ),
    );
    setState(() {
      _floatPlayerHealValue = amount;
      _floatPlayerHealShow  = true;
    });
    _floatPlayerHealCtrl!.forward().then((_) {
      if (mounted) setState(() => _floatPlayerHealShow = false);
    });
  }

  void _onDoubleSlash() {
    final skill = PlayerSkills.doubleSlash;
    if (_combatStamina < skill.staminaCost) return;
    if (_enemies.every((e) => e.isDead)) return;
    setState(() {
      _playerDefending          = false;
      _selectingForDoubleSlash  = true;
      _selectingTarget          = true;
    });
  }

  void _onDoubleSlashTarget(int index) async {
    final target = _enemies[index];
    if (target.isDead) return;

    final skill    = PlayerSkills.doubleSlash;
    final bool wasDefending = target.isDefending;
    final int baseAtk = widget.character.totalAttack;

    setState(() {
      _combatStamina = (_combatStamina - skill.staminaCost)
          .clamp(0, widget.character.maxStamina);
      _selectingTarget = false;
    });

    // Lao tới
    await _attackCtrl.forward(from: 0);
    if (!mounted) return;

    for (int i = 0; i < skill.hits.length; i++) {
      final hit     = skill.hits[i];
      final int raw = max(1, (baseAtk * hit.atkMultiplier).round());
      final int dmgBase = hit.ignoresArmor
          ? raw
          : CombatFormulas.applyArmor(raw, target.data.defense);
      final int dmg = wasDefending ? max(1, dmgBase ~/ 2) : dmgBase;

      setState(() {
        target.currentHp  = (target.currentHp - dmg).clamp(0, target.data.maxHp);
        _slashTargetIndex = index;
      });
      _slashCtrl.forward(from: 0).then((_) {
        if (mounted) setState(() => _slashTargetIndex = null);
      });
      _startFloatingDamage(index, dmg, target.isDead);

      if (target.isDead || i == skill.hits.length - 1) {
        // Ýt nhất 150ms trước khi trở về
        await Future.delayed(const Duration(milliseconds: 150));
        if (!mounted) return;
        break;
      }
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
    }

    await _attackCtrl.reverse();
    if (!mounted) return;

    if (_enemies.every((e) => e.isDead)) {
      setState(() => _showVictoryPanel = true);
      return;
    }
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) _enemyTurn();
  }

  void _onBlock() async {
    if (_playerDefending) return; // đã phòng thủ rồi
    setState(() {
      _selectingTarget = false;
      _playerDefending = true;
    });
    // Người chơi mất lượt → quái phản công sau 1 giây
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) _enemyTurn();
  }

  void _onSkill(int i) {} // TODO
  void _onFlee()   => Navigator.of(context).pop();

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildBattleArea()),
                _buildStatsPanel(),
                _buildActionBar(),
                const SizedBox(height: 4),
              ],
            ),
            if (_showGroggyBanner)
              Positioned(
                top: 48,
                left: 16,
                right: 16,
                child: _buildGroggyBanner(),
              ),
            if (_detailEnemyIndex != null)
              _buildEnemyDetailOverlay(_enemies[_detailEnemyIndex!]),
            if (_showVictoryPanel)
              _buildVictoryPanel(),
          ],
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppStrings.get('combatTitle'),
            style: const TextStyle(
              fontFamily: 'GnuUnifont',
              fontSize: 12,
              color: Color(0xFFCC4433),
              letterSpacing: 3,
            ),
          ),
          GestureDetector(
            onTap: _onFlee,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF3A2A18))),
              child: Text(
                AppStrings.get('combatFlee'),
                style: const TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 9,
                  color: Color(0xFF6A5A38),
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Panel chỉ số (JRPG-style, cửa sổ ở dưới) ──────────────────────────────

  Widget _buildStatsPanel() {
    final ch = widget.character;
    final double hpFrac =
        ch.maxHp > 0 ? (_playerHp / ch.maxHp).clamp(0.0, 1.0) : 0;
    final Color hpColor = hpFrac > 0.5
        ? const Color(0xFF88AA66)
        : hpFrac > 0.25
            ? const Color(0xFFCC8833)
            : const Color(0xFFCC4433);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 7, 12, 7),
      decoration: const BoxDecoration(
        color: Color(0xFF0C0C0C),
        border: Border(
          top:    BorderSide(color: Color(0xFF2A1A08)),
          bottom: BorderSide(color: Color(0xFF1A1008)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            const SizedBox(
              width: 36,
              child: Text('[HP]', style: TextStyle(
                  fontFamily: 'GnuUnifont', fontSize: 9,
                  color: Color(0xFF884433))),
            ),
            Expanded(child: _buildBar(_playerHp, ch.maxHp, hpColor, height: 5)),
            const SizedBox(width: 6),
            Text('$_playerHp/${ch.maxHp}', style: TextStyle(
                fontFamily: 'GnuUnifont', fontSize: 9, color: hpColor)),
          ]),
          const SizedBox(height: 5),
          Row(children: [
            const SizedBox(
              width: 36,
              child: Text('[STM]', style: TextStyle(
                  fontFamily: 'GnuUnifont', fontSize: 9,
                  color: Color(0xFF664488))),
            ),
            Expanded(child: _buildBar(
                _combatStamina, ch.maxStamina,
                const Color(0xFF9966CC), height: 5)),
            const SizedBox(width: 6),
            Text('$_combatStamina', style: const TextStyle(
                fontFamily: 'GnuUnifont', fontSize: 9,
                color: Color(0xFF9966CC))),
          ]),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _statChip('[ATK]', '${ch.totalAttack}',
                  const Color(0xFFD4A843)),
              const SizedBox(width: 20),
              _statChip('[DEF]', '${ch.totalDefense}',
                  const Color(0xFF5599CC)),
              const SizedBox(width: 20),
              _statChip('[AGI]', '${ch.agi}',
                  const Color(0xFF88AA66)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(String icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon,
            style: TextStyle(
                fontFamily: 'GnuUnifont', fontSize: 10, color: color)),
        const SizedBox(width: 3),
        Text(value,
            style: TextStyle(
                fontFamily: 'GnuUnifont',
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ── Khu vực chiến đấu ─────────────────────────────────────────────────────

  Widget _buildBattleArea() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Ảnh nền chiến đấu
        Image.asset(
          'assets/images/backgrounds/temple_arena_wide.png',
          fit: BoxFit.cover,
          filterQuality: FilterQuality.none,
          color: const Color(0x88000000),
          colorBlendMode: BlendMode.darken,
        ),

        Column(
          children: [
            // Kẻ địch (phía trên, chiếm nhiều không gian hơn)
            Expanded(flex: 7, child: _buildEnemyArea()),

            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 0),
              color: const Color(0xFF1A1008),
            ),

            // Người chơi (phía dưới, nhỏ hơn)
            Expanded(flex: 3, child: _buildPlayerArea()),
          ],
        ),
      ],
    );
  }

  // ── Khu vực kẻ địch ───────────────────────────────────────────────────────

  Widget _buildEnemyArea() {
    return Stack(
      children: [
        // Hàng quái vật – full height, không bị đẩy bởi banner
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (int i = 0; i < _enemies.length; i++)
              Flexible(child: _buildEnemyCard(i)),
          ],
        ),
        // Banner nổi ở trên, không chiếm không gian layout
        if (_selectingTarget)
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: const Color(0xDD150800),
              child: const Text(
                '▶ CHỌN MỤC TIÊU',
                style: TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 9,
                  color: Color(0xFFCC8833),
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEnemyCard(int index) {
    final e = _enemies[index];
    final double frac =
        e.data.maxHp > 0 ? (e.currentHp / e.data.maxHp).clamp(0, 1) : 0;
    final Color hpColor = frac > 0.5
        ? const Color(0xFF88AA66)
        : frac > 0.25
            ? const Color(0xFFCC8833)
            : const Color(0xFFCC4433);

    final bool isTargetable = _selectingTarget && !e.isDead;

    return GestureDetector(
      onTap: isTargetable ? () => _onTargetSelected(index) : null,
      onLongPressStart: _selectingTarget ? null : (_) => _openEnemyDetail(index),
      onLongPressEnd:   _selectingTarget ? null : (_) => _closeEnemyDetail(),
      onLongPressCancel: _selectingTarget ? null : _closeEnemyDetail,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: AnimatedBuilder(
          animation: _enemyLungeCtrl,
          builder: (_, child) => Transform.translate(
            offset: index == _lungeEnemyIndex
                ? Offset(0, _enemyLungeAnim.value * 40)
                : Offset.zero,
            child: child,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tên kẻ địch
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  AppStrings.get(e.monster.nameKey),
                  style: const TextStyle(
                    fontFamily: 'GnuUnifont',
                    fontSize: 8,
                    color: Color(0xFF6A4820),
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              // Ảnh + hiệu ứng chiến đấu
              Container(
                constraints: const BoxConstraints(maxWidth: 110, maxHeight: 120),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF000000), width: 2),
                  color: const Color(0xCC000000),
                ),
                child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Opacity(
                    opacity: e.isDead ? 0.2 : 1.0,
                    child: Image.asset(
                      e.monster.imagePath,
                      filterQuality: FilterQuality.none,
                    ),
                  ),
                  // Chỉ báo quái đang phòng thủ (nhấp nháy)
                  if (e.isDefending)
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (_, _) => DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color.lerp(
                                const Color(0xFF3366AA).withValues(alpha: 0.3),
                                const Color(0xFF55AAFF).withValues(alpha: 0.85),
                                _pulseAnim.value,
                              )!,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (e.isDefending)
                    Positioned(
                      top: 4, right: 4,
                      child: AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (_, _) => Opacity(
                          opacity: 0.5 + _pulseAnim.value * 0.5,
                          child: const Text(
                            '◈',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF55AAFF),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Vòng tròn chọn mục tiêu
                  if (isTargetable)
                    AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (_, _) => Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color.lerp(
                              const Color(0xFFCC2222).withValues(alpha: 0.5),
                              const Color(0xFFFF5555),
                              _pulseAnim.value,
                            )!,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color.lerp(
                                Colors.transparent,
                                const Color(0xFFFF2222).withValues(alpha: 0.35),
                                _pulseAnim.value,
                              )!,
                              blurRadius: 10,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Hiệu ứng vét chém pixel
                  if (index == _slashTargetIndex)
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _slashCtrl,
                        builder: (_, _) => Center(
                          child: Transform.translate(
                            offset: const Offset(-6, 0),
                            child: Transform.rotate(
                              angle: pi,
                              child: CustomPaint(
                                size: const Size(90, 90),
                                painter: _SlashPainter(_slashCtrl.value),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Số sát thương pixel nổi lên
                  if (index == _floatDmgTargetIndex && _floatDmgCtrl != null)
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _floatDmgCtrl!,
                        builder: (_, _) => Opacity(
                          opacity: _floatDmgFade!.value,
                          child: Align(
                            alignment: Alignment.center,
                            child: Transform.translate(
                              offset: Offset(0, _floatDmgY!.value),
                              child: CustomPaint(
                                size: Size(
                                  _PixelDmgPainter.textWidth('−$_floatDmgValue'),
                                  _PixelDmgPainter.textHeight,
                                ),
                                painter: _PixelDmgPainter(
                                  '−$_floatDmgValue',
                                  _floatDmgKill
                                      ? const Color(0xFFFF4444)
                                      : const Color(0xFFFFCC22),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Banner tên kỹ năng
                  if (index == _skillBannerEnemyIndex)
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: ColoredBox(
                        color: const Color(0xDD1A0800),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 3, horizontal: 4),
                          child: Text(
                            _skillBannerText,
                            style: const TextStyle(
                              fontFamily: 'GnuUnifont',
                              fontSize: 7,
                              color: Color(0xFFFF9944),
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                ],
                ),
              ),
              const SizedBox(height: 4),
              // Thanh máu
              SizedBox(
                width: 90,
                child: _buildBar(e.currentHp, e.data.maxHp, hpColor, height: 4),
              ),
              const SizedBox(height: 2),
              Text(
                '${e.currentHp}/${e.data.maxHp}',
                style: TextStyle(
                    fontFamily: 'GnuUnifont', fontSize: 8, color: hpColor),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  // ── Khu vực người chơi ────────────────────────────────────────────────────

  Widget _buildPlayerArea() {
    final ch = widget.character;
    final double frac =
        ch.maxHp > 0 ? (_playerHp / ch.maxHp).clamp(0, 1) : 0;
    final Color hpColor = frac > 0.5
        ? const Color(0xFF88AA66)
        : frac > 0.25
            ? const Color(0xFFCC8833)
            : const Color(0xFFCC4433);

    const double spriteH = 120.0;
    const double barW    = 80.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Ảnh người chơi với animation lao vào
            AnimatedBuilder(
              animation: _attackCtrl,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, -_attackLunge.value * 50),
                child: child,
              ),
              child: Container(
                constraints:
                    const BoxConstraints(maxWidth: 80, maxHeight: 120),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF000000), width: 2),
                  color: const Color(0xCC000000),
                ),
                child: Image.asset(
                  'assets/images/player.png',
                  filterQuality: FilterQuality.none,
                  color: _playerDefending
                      ? const Color(0xFF5599CC).withValues(alpha: 0.3)
                      : null,
                  colorBlendMode:
                      _playerDefending ? BlendMode.srcATop : null,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF2A1A08)),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '[ PLAYER ]',
                      style: TextStyle(
                        fontFamily: 'GnuUnifont',
                        fontSize: 8,
                        color: Color(0xFF3A2A18),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_playerDefending)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, _) => DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color.lerp(
                          const Color(0xFF2255AA).withValues(alpha: 0.4),
                          const Color(0xFF55AAFF).withValues(alpha: 0.9),
                          _pulseAnim.value,
                        )!,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            if (_playerDefending)
              Positioned(
                top: 8,
                right: 0,
                child: AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, _) => Opacity(
                    opacity: 0.5 + _pulseAnim.value * 0.5,
                    child: const Text(
                      '◈',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF55AAFF),
                      ),
                    ),
                  ),
                ),
              ),
            if (_playerDefending)
              Positioned(
                bottom: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  color: const Color(0xCC050505),
                  child: Text(
                    AppStrings.get('combatStatusBlocking'),
                    style: const TextStyle(
                      fontFamily: 'GnuUnifont',
                      fontSize: 8,
                      color: Color(0xFF5599CC),
                    ),
                  ),
                ),
              ),
            // Số máu người chơi bị trừ (nổi lên)
            if (_floatPlayerDmgShow && _floatPlayerDmgCtrl != null)
              Positioned(
                top: 0,
                child: AnimatedBuilder(
                  animation: _floatPlayerDmgCtrl!,
                  builder: (_, _) => Transform.translate(
                    offset: Offset(0, _floatPlayerDmgY!.value),
                    child: Opacity(
                      opacity: _floatPlayerDmgFade!.value,
                      child: CustomPaint(
                        size: Size(
                          _PixelDmgPainter.textWidth('−$_floatPlayerDmgValue'),
                          _PixelDmgPainter.textHeight,
                        ),
                        painter: _PixelDmgPainter(
                          '−$_floatPlayerDmgValue',
                          const Color(0xFFFF4444),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // Số máu hồi nổi lên (khi kết thúc phòng thủ)
            if (_floatPlayerHealShow && _floatPlayerHealCtrl != null)
              Positioned(
                top: 0,
                left: 10,
                child: AnimatedBuilder(
                  animation: _floatPlayerHealCtrl!,
                  builder: (_, _) => Transform.translate(
                    offset: Offset(0, _floatPlayerHealY!.value),
                    child: Opacity(
                      opacity: _floatPlayerHealFade!.value,
                      child: CustomPaint(
                        size: Size(
                          _PixelDmgPainter.textWidth('+$_floatPlayerHealValue'),
                          _PixelDmgPainter.textHeight,
                        ),
                        painter: _PixelDmgPainter(
                          '+$_floatPlayerHealValue',
                          const Color(0xFF9966CC), // màu stamina (tím)
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // Hiệu ứng chém trên người chơi (quái tấn công)
            if (_playerSlashActive)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _slashCtrl,
                  builder: (_, _) => CustomPaint(
                    painter: _SlashPainter(_slashCtrl.value),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: barW,
          child: _buildBar(_playerHp, ch.maxHp, hpColor, height: 4),
        ),
        const SizedBox(height: 2),
        Text(
          '$_playerHp / ${ch.maxHp}',
          style: TextStyle(
              fontFamily: 'GnuUnifont', fontSize: 8, color: hpColor),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  // ── Thanh hành động ───────────────────────────────────────────────────────

  Widget _buildActionBar() {
    final bool canDoubleSlash =
        _combatStamina >= PlayerSkills.doubleSlash.staminaCost &&
        !_enemies.every((e) => e.isDead);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border.all(color: const Color(0xFF2A1A08), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Nút TẤN CÔNG
          _actionBtn(
            label: AppStrings.get('combatActionAttack'),
            color: const Color(0xFFCC4433),
            onTap: _onAttack,
          ),
          const SizedBox(width: 10),
          // Nút PHÒNG THỦ
          _actionBtn(
            label: AppStrings.get('combatActionBlock'),
            color: _playerDefending
                ? const Color(0xFF5599CC)
                : const Color(0xFF3A5A7A),
            onTap: _onBlock,
          ),
          const SizedBox(width: 10),
          // Kỹ năng Chém Đôi
          _skillActionBtn(
            label: AppStrings.get(PlayerSkills.doubleSlash.nameKey),
            costLabel: '−${PlayerSkills.doubleSlash.staminaCost} STM',
            color: canDoubleSlash
                ? const Color(0xFFD4A843)
                : const Color(0xFF5A4820),
            onTap: canDoubleSlash ? _onDoubleSlash : null,
          ),
        ],
      ),
    );
  }

  Widget _skillActionBtn({
    required String label,
    required String costLabel,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'GnuUnifont',
                fontSize: 9,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              costLabel,
              style: TextStyle(
                fontFamily: 'GnuUnifont',
                fontSize: 7,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(
      {required String label,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontFamily: 'GnuUnifont',
              fontSize: 10,
              color: color,
              letterSpacing: 1),
        ),
      ),
    );
  }

  Widget _skillCircleBtn(int index) {
    const Color color = Color(0xFFD4A843);
    return GestureDetector(
      onTap: () => _onSkill(index),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color, width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          '${index + 1}',
          style: const TextStyle(
              fontFamily: 'GnuUnifont',
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ── Banner [Ngái Ngủ] ────────────────────────────────────────────────────

  Widget _buildGroggyBanner() {
    return GestureDetector(
      onTap: () => setState(() => _showGroggyBanner = false),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A0D00),
          border: Border.all(
              color: const Color(0xFFCC8833).withValues(alpha: 0.6), width: 1),
        ),
        child: Text(
          AppStrings.get('combatGroggyWarning'),
          style: const TextStyle(
            fontFamily: 'GnuUnifont',
            fontSize: 10,
            color: Color(0xFFCC8833),
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ── Bảng chiến thắng ─────────────────────────────────────────────────────

  Widget _buildVictoryPanel() {
    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0xCC000000),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D0D),
              border: Border.all(color: const Color(0xFFD4A843), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.get('combatVictoryTitle'),
                  style: const TextStyle(
                    fontFamily: 'GnuUnifont',
                    fontSize: 11,
                    color: Color(0xFFD4A843),
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(height: 1, color: const Color(0xFF3A2A08)),
                const SizedBox(height: 12),
                Text(
                  AppStrings.get('storyDay1SystemNoticeWin'),
                  style: const TextStyle(
                    fontFamily: 'GnuUnifont',
                    fontSize: 8,
                    color: Color(0xFFAA8855),
                    height: 1.7,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TempleScreen(character: widget.character),
                      ),
                      (route) => false,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A843).withValues(alpha: 0.12),
                      border: Border.all(
                          color: const Color(0xFFD4A843), width: 1),
                    ),
                    child: Text(
                      AppStrings.get('combatVicContinue'),
                      style: const TextStyle(
                        fontFamily: 'GnuUnifont',
                        fontSize: 10,
                        color: Color(0xFFD4A843),
                        letterSpacing: 2,
                      ),
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

  // ── Overlay chi tiết kẻ địch (giữ ngón tay) ──────────────────────────────

  Widget _buildEnemyDetailOverlay(_EnemyState e) {
    return GestureDetector(
      onTap: _closeEnemyDetail,
      child: Container(
        color: Colors.black.withValues(alpha: 0.70),
        child: Center(
          child: FadeTransition(
            opacity: _detailAnim,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D0D),
                border: Border.all(color: const Color(0xFF4A3018), width: 1),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên
                    Text(
                      AppStrings.get(e.monster.nameKey),
                      style: const TextStyle(
                        fontFamily: 'GnuUnifont',
                        fontSize: 12,
                        color: Color(0xFFCC4433),
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      AppStrings.get(e.monster.subtitleKey),
                      style: const TextStyle(
                        fontFamily: 'GnuUnifont',
                        fontSize: 9,
                        color: Color(0xFF5A4A30),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Chỉ số
                    _detailRow('[HP]  ${AppStrings.get("templeStatHp")}',
                        '${e.currentHp} / ${e.data.maxHp}',
                        const Color(0xFFCC4433)),
                    _detailRow('[ATK] ${AppStrings.get("charStatAttack")}',
                        '${e.data.atkMin}\u2013${e.data.atkMax}',
                        const Color(0xFFD4A843)),
                    _detailRow('[DEF] ${AppStrings.get("charStatDef")}',
                        '${e.data.defense}', const Color(0xFF5599CC)),
                    _detailRow('[AGI] ${AppStrings.get("charStatAgi")}',
                        '${e.data.agility}', const Color(0xFF88AA66)),
                    _detailRow('[STM] ${AppStrings.get("templeStatStamina")}',
                        '${e.currentStamina} / ${e.data.maxStamina}',
                        const Color(0xFF9966CC)),

                    // Kỹ năng
                    if (e.data.skills.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.get('combatEnemySkills'),
                        style: const TextStyle(
                          fontFamily: 'GnuUnifont',
                          fontSize: 10,
                          color: Color(0xFF8A8478),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      for (final skill in e.data.skills)
                        _buildSkillRow(skill),
                    ],

                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        AppStrings.get('combatDetailDismiss'),
                        style: const TextStyle(
                          fontFamily: 'GnuUnifont',
                          fontSize: 9,
                          color: Color(0xFF3A2A18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 10,
                  color: Color(0xFF8A8478))),
          Text(value,
              style: TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSkillRow(EnemySkill skill) {
    final tags = <String>[];
    if (skill.ignoresArmor) tags.add(AppStrings.get('combatSkillIgnoresArmor'));
    if (skill.lifestealHp > 0) {
      tags.add(
          '${AppStrings.get('combatSkillLifesteal')} +${skill.lifestealHp}');
    }
    if (skill.bleed != null) {
      final b = skill.bleed!;
      tags.add(
          '${AppStrings.get('combatSkillBleed')} ${(b.chance * 100).round()}%'
          ' / ${b.dmgPerTurn}×${b.turns}');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0800),
        border: Border.all(color: const Color(0xFF2A1A08), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.get(skill.nameKey),
                  style: const TextStyle(
                      fontFamily: 'GnuUnifont',
                      fontSize: 10,
                      color: Color(0xFFD4A843))),
              Text('◈ ${skill.staminaCost}  ⚔ ${skill.dmgMin}–${skill.dmgMax}',
                  style: const TextStyle(
                      fontFamily: 'GnuUnifont',
                      fontSize: 9,
                      color: Color(0xFF6A5A38))),
            ],
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                for (final tag in tags)
                  Text('▸ $tag',
                      style: const TextStyle(
                          fontFamily: 'GnuUnifont',
                          fontSize: 8,
                          color: Color(0xFF886644))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Thanh HP / Stamina dạng fill ─────────────────────────────────────────

  Widget _buildBar(int current, int max, Color color, {double height = 6}) {
    final double frac = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    return LayoutBuilder(builder: (_, c) {
      return Stack(children: [
        Container(
            height: height,
            width: c.maxWidth,
            color: const Color(0xFF1A1008)),
        Container(
            height: height,
            width: c.maxWidth * frac,
            color: color),
      ]);
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Số sát thương dạng pixel art — vẽ từng ô vuông theo bitmap font 3×5
// ─────────────────────────────────────────────────────────────────────────────
class _PixelDmgPainter extends CustomPainter {
  final String text;
  final Color color;

  static const double _cs = 3.5; // kích thước 1 ô pixel

  // Bitmap font 3 cột × 5 hàng cho các ký tự cần dùng
  static const Map<String, List<String>> _g = {
    '0': ['111', '101', '101', '101', '111'],
    '1': ['110', '010', '010', '010', '111'],
    '2': ['111', '001', '111', '100', '111'],
    '3': ['111', '001', '011', '001', '111'],
    '4': ['101', '101', '111', '001', '001'],
    '5': ['111', '100', '111', '001', '111'],
    '6': ['011', '100', '111', '101', '111'],
    '7': ['111', '001', '001', '001', '001'],
    '8': ['111', '101', '111', '101', '111'],
    '9': ['111', '101', '111', '001', '110'],
    '−': ['000', '000', '111', '000', '000'],
    '+': ['010', '111', '010', '000', '000'],
  };

  const _PixelDmgPainter(this.text, this.color);

  /// Tổng chiều rộng của chuỗi (3 cols + 1 gap) × số ký tự, bỏ gap cuối
  static double textWidth(String s) =>
      s.isEmpty ? 0 : s.length * 4 * _cs - _cs;

  /// Chiều cao: 5 hàng × _cs + 1 pixel bóng
  static double get textHeight => 5 * _cs + 1;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint fg = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    final Paint sh = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    double x = 0;
    for (int ci = 0; ci < text.length; ci++) {
      final glyph = _g[text[ci]];
      if (glyph == null) {
        x += 4 * _cs;
        continue;
      }
      for (int row = 0; row < 5; row++) {
        final String rowStr = glyph[row];
        for (int col = 0; col < 3; col++) {
          if (rowStr[col] == '1') {
            final double rx = x + col * _cs;
            final double ry = row * _cs;
            // bóng đổ (+1, +1)
            canvas.drawRect(Rect.fromLTWH(rx + 1, ry + 1, _cs, _cs), sh);
            // ô pixel chính
            canvas.drawRect(Rect.fromLTWH(rx, ry, _cs, _cs), fg);
          }
        }
      }
      x += 4 * _cs; // 3 cột + 1 khoảng cách
    }
  }

  @override
  bool shouldRepaint(_PixelDmgPainter old) =>
      old.text != text || old.color != color;
}
//   t = 0→1.0
//   [0.00–0.35] scan pixels từ góc trái-trên → phải-dưới (không smooth)
//   [0.35–0.65] hold đủ pixels
//   [0.65–1.00] fade out cứng (alpha giảm theo bước pixel)
// ─────────────────────────────────────────────────────────────────────────────
class _SlashPainter extends CustomPainter {
  final double t;
  const _SlashPainter(this.t);

  /// Vẽ một cung tròn dưới dạng các pixel vuông rời nhau (pixel art, không anti-alias).
  /// [center] : tâm đường tròn sinh ra cung
  /// [startAngle]/[endAngle] : radian, chiều kim đồng hồ
  /// [progress] : 0→1, tỉ lệ cung được vẽ (dùng để animate scan-in)
  static void _pixelArc(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double endAngle,
    Color color,
    double px,
    double progress,
  ) {
    if (progress <= 0 || color.a < 0.008) return;
    final double sweep = endAngle - startAngle;
    final double arcLen = sweep.abs() * radius;
    final int steps = max(1, (arcLen / (px * 0.65)).ceil());
    final int count = (steps * progress.clamp(0.0, 1.0)).round();
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    for (int i = 0; i < count; i++) {
      final double angle = startAngle + sweep * (i / steps);
      // snap tọa độ vào lưới pixel
      final double rx = ((center.dx + cos(angle) * radius) / px).roundToDouble() * px;
      final double ry = ((center.dy + sin(angle) * radius) / px).roundToDouble() * px;
      canvas.drawRect(Rect.fromLTWH(rx - px / 2, ry - px / 2, px, px), paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;   // 45
    final double cy = size.height / 2;  // 45

    // ── Pha thời gian ────────────────────────────────────────────────────
    final double scan1 = (t / 0.40).clamp(0.0, 1.0);
    final double scan2 = ((t - 0.12) / 0.33).clamp(0.0, 1.0); // trễ 12%
    final double scan3 = ((t - 0.22) / 0.28).clamp(0.0, 1.0); // trễ 22%

    // Fade-out theo 4 bước cứng (pixel art — không mượt)
    double alpha;
    if (t < 0.65) {
      alpha = 1.0;
    } else {
      final double p = (t - 0.65) / 0.35;
      if (p < 0.25)      { alpha = 0.75; }
      else if (p < 0.50) { alpha = 0.50; }
      else if (p < 0.75) { alpha = 0.25; }
      else               { alpha = 0.0;  }
    }
    if (alpha <= 0) return;

    // ── Hình học ─────────────────────────────────────────────────────────
    // Tâm vòng tròn sinh cung đặt ở trên-trái canvas:
    // cung quét từ góc trên-phải (≈10°) xuống góc dưới-trái (≈77°)
    // → vệt chém hình lưỡi liềm theo đường chéo \.
    final Offset c1 = Offset(cx - 55, cy - 55); // ≈ (-10, -10)
    const double kStartA = 1.35; // đảo chiều scan: bắt đầu từ ≈77° → ≈10°
    const double kEndA   = 0.18;
    const double px  = 3.0;
    const double px2 = 2.0;

    // ── Bảng màu ─────────────────────────────────────────────────────────
    final Color shadow = Color.fromARGB((alpha * 150).round(), 0x00, 0x08, 0x22);
    final Color outer  = Color.fromARGB((alpha * 160).round(), 0xAA, 0xDD, 0xFF);
    final Color fill1  = Color.fromARGB((alpha * 210).round(), 0xCC, 0xEE, 0xFF);
    final Color core   = Color.fromARGB((alpha * 255).round(), 0xFF, 0xFF, 0xFF);
    final Color inner  = Color.fromARGB((alpha * 130).round(), 0x88, 0xCC, 0xFF);

    // ── Cung lưỡi liềm chính (5 vòng cung tạo độ dày) ───────────────────
    // Bóng đổ (lệch +px theo hai chiều)
    final Offset c1s = Offset(c1.dx + px, c1.dy + px);
    _pixelArc(canvas, c1s, 82, kStartA, kEndA, shadow, px, scan1);
    _pixelArc(canvas, c1s, 70, kStartA, kEndA, shadow, px, scan1);
    _pixelArc(canvas, c1s, 58, kStartA, kEndA, shadow, px, scan1);
    // Cạnh ngoài (xanh nhạt)
    _pixelArc(canvas, c1, 82, kStartA, kEndA, outer, px, scan1);
    // Điền thân lưỡi liềm
    _pixelArc(canvas, c1, 76, kStartA, kEndA, fill1, px, scan1);
    // Lõi sáng trắng
    _pixelArc(canvas, c1, 70, kStartA, kEndA, core,  px, scan1);
    // Điền thân phía trong
    _pixelArc(canvas, c1, 64, kStartA, kEndA, fill1, px, scan1);
    // Cạnh trong (xanh đậm hơn)
    _pixelArc(canvas, c1, 58, kStartA, kEndA, inner, px, scan1);

    // ── Cung phụ 1 (nhỏ hơn, trễ 12%) ───────────────────────────────────
    final Offset c2 = Offset(cx - 42, cy - 52); // ≈ (3, -7)
    final Color sec2 = Color.fromARGB((alpha * 110).round(), 0xBB, 0xEE, 0xFF);
    _pixelArc(canvas, c2, 58, 1.20, 0.15, sec2, px2, scan2);
    _pixelArc(canvas, c2, 51, 1.20, 0.15, sec2, px2, scan2);

    // ── Cung đuôi (mờ nhất, trễ 22%) ────────────────────────────────────
    final Offset c3 = Offset(cx - 30, cy - 48); // ≈ (15, -3)
    final Color trail = Color.fromARGB((alpha * 70).round(), 0xAA, 0xDD, 0xFF);
    _pixelArc(canvas, c3, 42, 1.10, 0.12, trail, px2, scan3);

    // ── Pixel sparks tại điểm cuối cung khi scan ≥ 90% ──────────────────
    if (scan1 >= 0.90) {
      final double sa = ((scan1 - 0.90) / 0.10) * alpha;
      final Color sc = Color.fromARGB((sa * 255).round(), 0xFF, 0xFF, 0xFF);
      final double tipX = c1.dx + cos(kEndA) * 70;
      final double tipY = c1.dy + sin(kEndA) * 70;
      final paint = Paint()..color = sc..style = PaintingStyle.fill..isAntiAlias = false;
      for (final Offset o in [
        Offset(tipX + 5, tipY + 5),
        Offset(tipX + 8, tipY + 1),
        Offset(tipX + 1, tipY + 8),
        Offset(tipX + 11, tipY + 4),
        Offset(tipX + 4, tipY + 11),
      ]) {
        canvas.drawRect(Rect.fromLTWH(o.dx, o.dy, px2, px2), paint);
      }
      // pixel sáng lớn hơn ở đúng điểm va chạm
      canvas.drawRect(
        Rect.fromLTWH(tipX + 2, tipY + 2, px, px),
        Paint()..color = sc..style = PaintingStyle.fill..isAntiAlias = false,
      );
    }
  }

  @override
  bool shouldRepaint(_SlashPainter old) => old.t != t;
}
