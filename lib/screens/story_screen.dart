import 'dart:async';

import 'package:flutter/material.dart';
import 'package:one_hundred_sunless_days/l10n/app_strings.dart';
import 'package:one_hundred_sunless_days/models/character.dart';
import 'package:one_hundred_sunless_days/models/enemy_data.dart';
import 'package:one_hundred_sunless_days/models/monster.dart';
import 'package:one_hundred_sunless_days/screens/combat_prep_screen.dart';
import 'package:one_hundred_sunless_days/screens/start_screen.dart';
import 'package:one_hundred_sunless_days/screens/temple_screen.dart';

// ────────────────────────────────────────────────────────────────────────────
// Kiểu đoạn cốt truyện
// ────────────────────────────────────────────────────────────────────────────

/// Phân loại một đoạn trong cốt truyện.
enum _SegType {
  /// Văn miêu tả cảnh thông thường.
  narrative,
  /// Lời thoại nhân vật – kèm tên người nói.
  dialogue,
  /// Thông báo hệ thống – hiển thị ô đặc biệt.
  system,
}

/// Một đoạn cốt truyện: loại, nội dung và tên người nói (tùy chọn).
class _Segment {
  final _SegType type;
  final String text;
  final String? speaker;

  const _Segment.narrative(this.text)
      : type = _SegType.narrative,
        speaker = null;

  const _Segment.dialogue(this.speaker, this.text)
      : type = _SegType.dialogue;

  const _Segment.system(this.text)
      : type = _SegType.system,
        speaker = null;
}

// ────────────────────────────────────────────────────────────────────────────
// Một màn cảnh: ảnh nền + danh sách đoạn
// ────────────────────────────────────────────────────────────────────────────

class _StoryAct {
  final String backgroundAsset;
  final List<_Segment> segments;
  const _StoryAct({required this.backgroundAsset, required this.segments});
}

// ────────────────────────────────────────────────────────────────────────────
// Màn hình cốt truyện
// ────────────────────────────────────────────────────────────────────────────

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

/// Lựa chọn hướng đi của người chơi ở cuối cảnh 2.
enum _Branch { none, attack, trust }

// Pha hiển thị: tiêu đề → cảnh → lựa chọn → chiến đấu / chết
enum _Phase { title, scene, choice, death }

class _StoryScreenState extends State<StoryScreen>
    with TickerProviderStateMixin {
  _Phase _phase = _Phase.title;
  _Branch _branch = _Branch.none;

  // ── Dữ liệu cốt truyện ────────────────────────────────────────────────────
  late final String _title = AppStrings.get('storyDay1Title');
  final List<_StoryAct> _acts = [
    _StoryAct(
      backgroundAsset: 'assets/images/backgrounds/intro_scene.png',
      segments: [
        _Segment.narrative(AppStrings.get('storyDay1Seg1')),
        _Segment.narrative(AppStrings.get('storyDay1Seg2')),
        _Segment.narrative(AppStrings.get('storyDay1Seg3')),
      ],
    ),
    _StoryAct(
      backgroundAsset: 'assets/images/backgrounds/day1_watcher_handover.png',
      segments: [
        _Segment.dialogue(
          AppStrings.get('storyDay1WatcherName'),
          AppStrings.get('storyDay1WatcherLine1'),
        ),
        _Segment.narrative(AppStrings.get('storyDay1WatcherAction')),
        _Segment.dialogue(
          AppStrings.get('storyDay1WatcherName'),
          AppStrings.get('storyDay1WatcherLine2'),
        ),
      ],
    ),
  ];

  // ── Animation fade-in tiêu đề (0 → 1 khi màn hình mở) ───────────────────
  late final AnimationController _titleFadeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..forward();

  late final Animation<double> _titleFade = CurvedAnimation(
    parent: _titleFadeCtrl,
    curve: Curves.easeIn,
  );

  // ── Animation overlay đen chuyển cảnh (0 → 1 → 0) ───────────────────────
  late final AnimationController _overlayCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  bool _transitioning = false;

  // ── Typewriter ────────────────────────────────────────────────────────────
  int _actIndex = 0;
  int _segmentIndex = 0;
  String _displayed = '';
  bool _isTyping = false;
  Timer? _typeTimer;

  // ── Tốc độ gõ chữ (ms mỗi ký tự) ────────────────────────────────────────
  static const int _typeSpeedMs = 38;

  // ── Tiện ích ─────────────────────────────────────────────────────────────
  _StoryAct get _currentAct => _acts[_actIndex];
  _Segment get _currentSegment => _currentAct.segments[_segmentIndex];
  bool get _isLastSegmentInAct =>
      _segmentIndex == _currentAct.segments.length - 1;
  bool get _isLastAct => _actIndex == _acts.length - 1;

  @override
  void dispose() {
    _titleFadeCtrl.dispose();
    _overlayCtrl.dispose();
    _typeTimer?.cancel();
    super.dispose();
  }

  // ── Xử lý chạm ───────────────────────────────────────────────────────────

  void _onTap() {
    if (_transitioning) return;
    if (_phase == _Phase.choice || _phase == _Phase.death) return;

    if (_phase == _Phase.title) {
      _transitionToScene();
      return;
    }

    // Nếu đang gõ → hiển thị ngay toàn bộ đoạn
    if (_isTyping) {
      _typeTimer?.cancel();
      setState(() {
        _displayed = _currentSegment.text;
        _isTyping = false;
      });
      return;
    }

    if (!_isLastSegmentInAct) {
      // Còn đoạn trong cảnh hiện tại
      _startTyping(_actIndex, _segmentIndex + 1);
    } else if (!_isLastAct) {
      // Hết đoạn → chuyển sang cảnh tiếp theo
      _transitionToNextAct();
    } else {
      // Hết tất cả → xử lý theo nhánh
      if (_branch == _Branch.none) {
        _transitionToChoice();
      } else if (_branch == _Branch.attack) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => CombatPrepScreen(
              character: Character(),
              monster: MonsterRegistry.watcherGuise,
              enemyData: EnemyRegistry.watcherGuise,
            ),
          ),
        );
      } else {
        _showDeathScreen();
      }
    }
  }

  /// Fade màn hình về đen, đổi nội dung, fade trở lại.
  Future<void> _transitionToScene() async {
    setState(() => _transitioning = true);

    // Pha 1: fade sang đen
    await _overlayCtrl.forward();
    if (!mounted) return;

    // Đổi nội dung khi màn đen hoàn toàn
    setState(() {
      _phase = _Phase.scene;
      _transitioning = false;
    });

    // Pha 2: fade về trong suốt
    await _overlayCtrl.reverse();
    if (!mounted) return;

    // Bắt đầu typewriter sau khi cảnh hiện ra
    _startTyping(0, 0);
  }

  /// Fade sang đen, đổi sang act tiếp theo, fade trở lại.
  Future<void> _transitionToNextAct() async {
    setState(() => _transitioning = true);
    await _overlayCtrl.forward();
    if (!mounted) return;

    setState(() {
      _actIndex++;
      _transitioning = false;
    });

    await _overlayCtrl.reverse();
    if (!mounted) return;

    _startTyping(_actIndex, 0);
  }

  /// Khởi chạy typewriter cho đoạn tại [act][seg].
  /// Đoạn kiểu [_SegType.system] hiển thị ngay, không gõ từng chữ.
  void _startTyping(int act, int seg) {
    _typeTimer?.cancel();
    final _Segment segment = _acts[act].segments[seg];

    if (segment.type == _SegType.system) {
      setState(() {
        _actIndex = act;
        _segmentIndex = seg;
        _displayed = segment.text;
        _isTyping = false;
      });
      return;
    }

    final String full = segment.text;
    int charPos = 0;

    setState(() {
      _actIndex = act;
      _segmentIndex = seg;
      _displayed = '';
      _isTyping = true;
    });

    _typeTimer = Timer.periodic(
      const Duration(milliseconds: _typeSpeedMs),
      (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        if (charPos < full.length) {
          setState(() => _displayed = full.substring(0, charPos + 1));
          charPos++;
        } else {
          t.cancel();
          if (mounted) setState(() => _isTyping = false);
        }
      },
    );
  }

  // ── Build gốc ─────────────────────────────────────────────────────────────

  /// Fade sang đen → hiện màn lựa chọn → fade trở lại.
  Future<void> _transitionToChoice() async {
    setState(() => _transitioning = true);
    await _overlayCtrl.forward();
    if (!mounted) return;
    setState(() {
      _phase = _Phase.choice;
      _transitioning = false;
    });
    await _overlayCtrl.reverse();
  }

  /// Người chơi chọn nhánh → append acts + chuyển sang cảnh tiếp theo.
  void _onChoiceMade(bool attackChoice) {
    _acts.addAll(attackChoice ? _buildAttackActs() : _buildTrustActs());
    setState(() {
      _branch = attackChoice ? _Branch.attack : _Branch.trust;
      _phase = _Phase.scene;
    });
    _transitionToNextAct();
  }

  /// Fade sang đen → hiện màn chết → fade trở lại.
  Future<void> _showDeathScreen() async {
    setState(() => _transitioning = true);
    await _overlayCtrl.forward();
    if (!mounted) return;
    setState(() {
      _phase = _Phase.death;
      _transitioning = false;
    });
    await _overlayCtrl.reverse();
  }

  List<_StoryAct> _buildAttackActs() => [
    _StoryAct(
      backgroundAsset: 'assets/images/backgrounds/story_day1_attack.png',
      segments: [
        _Segment.narrative(AppStrings.get('storyDay1AttackSeg1')),
        _Segment.narrative(AppStrings.get('storyDay1AttackSeg2')),
        _Segment.dialogue(
          AppStrings.get('storyDay1WatcherName'),
          AppStrings.get('storyDay1AttackLine'),
        ),
        _Segment.system(AppStrings.get('storyDay1SystemNoticeCombat')),
      ],
    ),
  ];

  List<_StoryAct> _buildTrustActs() => [
    _StoryAct(
      backgroundAsset: 'assets/images/backgrounds/story_day1_trust.png',
      segments: [
        _Segment.narrative(AppStrings.get('storyDay1TrustSeg1')),
        _Segment.narrative(AppStrings.get('storyDay1TrustSeg2')),
        _Segment.dialogue(
          AppStrings.get('storyDay1WatcherName'),
          AppStrings.get('storyDay1TrustLine'),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (_) => _onTap(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Nội dung chính ──────────────────────────────────────────
            switch (_phase) {
              _Phase.title  => _buildTitleCard(),
              _Phase.scene  => _buildScene(),
              _Phase.choice => _buildChoiceScreen(),
              _Phase.death  => _buildDeathScreen(),
            },

            // ── Overlay đen chuyển cảnh ─────────────────────────────────
            AnimatedBuilder(
              animation: _overlayCtrl,
              builder: (_, __) {
                if (_overlayCtrl.value == 0) return const SizedBox.shrink();
                return ColoredBox(
                  color: Colors.black
                      .withValues(alpha: _overlayCtrl.value),
                  child: const SizedBox.expand(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Pha tiêu đề ───────────────────────────────────────────────────────────

  Widget _buildTitleCard() {
    return FadeTransition(
      opacity: _titleFade,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 22,
                  color: Color(0xFFD4C9A8),
                  letterSpacing: 2,
                  height: 1.9,
                ),
              ),
              const SizedBox(height: 56),
              _BlinkText(AppStrings.get('hintTapToContinue')),
            ],
          ),
        ),
      ),
    );
  }

  // ── Pha cảnh ──────────────────────────────────────────────────────────────

  Widget _buildScene() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // Nền đen
            const ColoredBox(color: Colors.black),

            // Ảnh cảnh pixel art – full chiều ngang, chiều cao tự co theo tỉ lệ ảnh
            Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                _currentAct.backgroundAsset,
                width: constraints.maxWidth,
                fit: BoxFit.fitWidth,
                filterQuality: FilterQuality.none,
              ),
            ),

        // Gradient tối từ giữa xuống để hộp thoại nổi lên tự nhiên
        const Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 320,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xF2000000)],
                ),
              ),
            ),
          ),
        ),

        // Hộp thoại
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildDialogBox(),
        ),
      ],
    );
      },
    );
  }

  // ── Hộp thoại ─────────────────────────────────────────────────────────────

  Widget _buildDialogBox() {
    final int total = _currentAct.segments.length;
    final bool isLast = _isLastSegmentInAct && _isLastAct;
    final _Segment seg = _currentSegment;
    final bool isSys = seg.type == _SegType.system;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
      decoration: BoxDecoration(
        color: isSys ? const Color(0xE5000A00) : const Color(0xD5080808),
        border: Border(
          top: BorderSide(
            color: isSys ? const Color(0xFF2A5A2A) : const Color(0xFF4A3618),
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dots tiến trình (ẩn cho system)
          if (!isSys)
            Row(
              children: List.generate(total, (i) {
                final bool active = i <= _segmentIndex;
                final bool current = i == _segmentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: current ? 10 : 8,
                  height: current ? 10 : 8,
                  margin: const EdgeInsets.only(right: 6),
                  color: active
                      ? const Color(0xFFD4A843)
                      : const Color(0xFF2A2A2A),
                );
              }),
            ),

          if (!isSys) const SizedBox(height: 12),

          // Tên người nói (chỉ cho dialogue)
          if (seg.type == _SegType.dialogue && seg.speaker != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                seg.speaker!,
                style: const TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4A843),
                  letterSpacing: 2,
                ),
              ),
            ),

          // Nội dung chính
          if (isSys)
            _buildSystemNotice()
          else
            Text(
              _displayed,
              style: TextStyle(
                fontFamily: 'GnuUnifont',
                fontSize: 16,
                fontStyle: seg.type == _SegType.dialogue
                    ? FontStyle.italic
                    : FontStyle.normal,
                color: seg.type == _SegType.dialogue
                    ? const Color(0xFFE8DFC0)
                    : const Color(0xFFCEC8B0),
                height: 1.85,
                letterSpacing: 0.2,
              ),
            ),

          // Chỉ báo nhấn tiếp
          SizedBox(
            height: 28,
            child: _isTyping
                ? null
                : Align(
                    alignment: Alignment.centerRight,
                    child: _BlinkText(
                      isLast
                          ? AppStrings.get('hintContinue')
                          : AppStrings.get('hintNextSegment'),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// Render đặc biệt cho thông báo hệ thống: mỗi dòng một widget.
  Widget _buildSystemNotice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _displayed
          .split('\n')
          .map(
            (line) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text(
                line,
                style: const TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 15,
                  color: Color(0xFF88CC88),
                  height: 1.7,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // ── Màn lựa chọn ─────────────────────────────────────────────────────────

  Widget _buildChoiceScreen() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Colors.black),
            Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                _currentAct.backgroundAsset,
                width: constraints.maxWidth,
                fit: BoxFit.fitWidth,
                filterQuality: FilterQuality.none,
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 320,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00000000), Color(0xF2000000)],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildChoicePanel(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChoicePanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 44),
      decoration: const BoxDecoration(
        color: Color(0xED080808),
        border: Border(
          top: BorderSide(color: Color(0xFF4A3618), width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildChoiceBtn(
            label: AppStrings.get('storyDay1ChoiceAttack'),
            accentColor: const Color(0xFF8B2020),
            onTap: () => _onChoiceMade(true),
          ),
          const SizedBox(height: 12),
          _buildChoiceBtn(
            label: AppStrings.get('storyDay1ChoiceTrust'),
            accentColor: const Color(0xFF4A3618),
            onTap: () => _onChoiceMade(false),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceBtn({
    required String label,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          border: Border.all(color: accentColor, width: 2),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'GnuUnifont',
            fontSize: 15,
            color: Color(0xFFCEC8B0),
            height: 1.6,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  // ── Màn chết ──────────────────────────────────────────────────────────────

  Widget _buildDeathScreen() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Colors.black),
            Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                'assets/images/backgrounds/death/death_screen_stab_through_heart.png',
                width: constraints.maxWidth,
                fit: BoxFit.fitWidth,
                filterQuality: FilterQuality.none,
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 320,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00000000), Color(0xF2000000)],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildDeathBox(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDeathBox() {
    final lines = AppStrings.get('storyDay1SystemNoticeDeath').split('\n');
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 44),
      decoration: const BoxDecoration(
        color: Color(0xE5100000),
        border: Border(
          top: BorderSide(color: Color(0xFF5A0000), width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text(
                line,
                style: const TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 15,
                  color: Color(0xFFCC4444),
                  height: 1.7,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const StartScreen()),
              (_) => false,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                border: Border.all(color: const Color(0xFF5A0000), width: 2),
              ),
              child: Text(
                AppStrings.get('storyDay1DeathReturnBtn'),
                style: const TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 14,
                  color: Color(0xFFCC4444),
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Widget chữ chớp nháy
// ────────────────────────────────────────────────────────────────────────────

class _BlinkText extends StatefulWidget {
  final String text;
  const _BlinkText(this.text);

  @override
  State<_BlinkText> createState() => _BlinkTextState();
}

class _BlinkTextState extends State<_BlinkText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Text(
        widget.text,
        style: const TextStyle(
          fontFamily: 'GnuUnifont',
          fontSize: 14,
          color: Color(0xFF8A7A58),
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
