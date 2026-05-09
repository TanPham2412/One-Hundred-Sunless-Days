import 'package:flutter/material.dart';
import 'package:one_hundred_sunless_days/l10n/app_strings.dart';
import 'package:one_hundred_sunless_days/models/character.dart';
import 'package:one_hundred_sunless_days/models/item.dart';

// ────────────────────────────────────────────────────────────────────────────
// Overlay Tập Luyện
// ────────────────────────────────────────────────────────────────────────────

class TrainingOverlay extends StatefulWidget {
  final Character character;
  final VoidCallback onClose;

  /// Callback gọi khi sự kiện [StrengthTrainingEvent.dangerAttracted] xảy ra.
  /// Nếu null, hành động mặc định là đóng overlay (onClose).
  final VoidCallback? onCombat;

  const TrainingOverlay({
    super.key,
    required this.character,
    required this.onClose,
    this.onCombat,
  });

  @override
  State<TrainingOverlay> createState() => _TrainingOverlayState();
}

class _TrainingOverlayState extends State<TrainingOverlay> {
  TrainingResult? _result;

  void _doTrain(TrainingType type) {
    final result = widget.character.train(type);
    setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xEE0A0A0A),
      child: SafeArea(
        child: _result == null ? _buildOptions() : _TrainingResultScreen(
        result: _result!,
        onClose: widget.onClose,
        onCombat: widget.onCombat,
      ),
      ),
    );
  }

  // ── Màn hình chọn bài tập ───────────────────────────────────────────────

  Widget _buildOptions() {
    final c = widget.character;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.get('templeActionTrain'),
            style: const TextStyle(
              fontFamily: 'GnuUnifont',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4A843),
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildOptionCard(
            type: TrainingType.strength,
            name: AppStrings.get('trainOptionStrength'),
            subLabel: AppStrings.get('trainOptionStrengthStat'),
            staminaCost: 15,
            hungerCost: 5,
            statLevel: c.str,
            statExp: c.strExp,
            color: const Color(0xFFCC5533),
          ),
          const SizedBox(height: 10),
          _buildOptionCard(
            type: TrainingType.endurance,
            name: AppStrings.get('trainOptionEndurance'),
            subLabel: AppStrings.get('trainOptionEnduranceStat'),
            staminaCost: 20,
            hungerCost: 10,
            statLevel: c.vit,
            statExp: c.vitExp,
            color: const Color(0xFF3399CC),
          ),
          const SizedBox(height: 10),
          _buildOptionCard(
            type: TrainingType.meditation,
            name: AppStrings.get('trainOptionMeditation'),
            subLabel: AppStrings.get('trainOptionMeditationStat'),
            staminaCost: 5,
            hungerCost: 5,
            statLevel: c.will,
            statExp: c.willExp,
            color: const Color(0xFF9966BB),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                border: Border.all(color: const Color(0xFF4A3618), width: 1),
              ),
              child: Text(
                AppStrings.get('trainBack'),
                style: const TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 11,
                  color: Color(0xFF8A7A58),
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required TrainingType type,
    required String name,
    required String subLabel,
    required int staminaCost,
    required int hungerCost,
    required int statLevel,
    required double statExp,
    required Color color,
  }) {
    final double needed = Character.expNeededToLevel(statLevel);
    final bool atMax = statLevel >= CharacterDefaults.maxStatLevel;
    final bool canAfford = widget.character.stamina >= staminaCost &&
        widget.character.hunger >= hungerCost;

    return GestureDetector(
      onTap: canAfford ? () => _doTrain(type) : null,
      child: Opacity(
        opacity: canAfford ? 1.0 : 0.45,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D0D),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subLabel,
                style: const TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 10,
                  color: Color(0xFF8A8478),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${AppStrings.get('trainExpLabel')}  Lv.$statLevel',
                    style: const TextStyle(
                      fontFamily: 'GnuUnifont',
                      fontSize: 10,
                      color: Color(0xFFCEC8B0),
                    ),
                  ),
                  const Spacer(),
                  if (atMax)
                    Text(
                      'MAX',
                      style: TextStyle(
                        fontFamily: 'GnuUnifont',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    )
                  else
                    Text(
                      '${_fmtExp(statExp)} / ${_fmtExp(needed)}',
                      style: const TextStyle(
                        fontFamily: 'GnuUnifont',
                        fontSize: 10,
                        color: Color(0xFF8A8478),
                      ),
                    ),
                ],
              ),
              if (!atMax) ...[
                const SizedBox(height: 4),
                _ExpBar(current: statExp, needed: needed, color: color),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  _CostChip(
                    label: '-$staminaCost ${AppStrings.get('templeStatStamina')}',
                    ok: widget.character.stamina >= staminaCost,
                  ),
                  const SizedBox(width: 10),
                  _CostChip(
                    label: '-$hungerCost ${AppStrings.get('templeStatHunger')}',
                    ok: widget.character.hunger >= hungerCost,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

// ────────────────────────────────────────────────────────────────────────────
// Màn hình kết quả tập luyện – có animation hiện từng dòng + EXP bar chạy
// ────────────────────────────────────────────────────────────────────────────

class _TrainingResultScreen extends StatefulWidget {
  final TrainingResult result;
  final VoidCallback onClose;
  final VoidCallback? onCombat;

  const _TrainingResultScreen({
    required this.result,
    required this.onClose,
    this.onCombat,
  });

  @override
  State<_TrainingResultScreen> createState() => _TrainingResultScreenState();
}

class _TrainingResultScreenState extends State<_TrainingResultScreen>
    with TickerProviderStateMixin {
  // Số dòng stat hiện ra
  int _visibleLines = 0;
  bool _showExpBars = false;
  bool _showLevelUpBanners = false;
  bool _showButton = false;

  late final List<_StatLine> _lines;

  @override
  void initState() {
    super.initState();
    _lines = _buildLines(widget.result);
    _startSequence();
  }

  // Xây danh sách các dòng stat từ TrainingResult
  List<_StatLine> _buildLines(TrainingResult r) {
    final List<_StatLine> lines = [];
    if (!r.success) {
      lines.add(_StatLine('!', AppStrings.get('trainNotEnoughResources'), '', positive: false));
      return lines;
    }
    if (r.staminaCost > 0)
      lines.add(_StatLine('−', AppStrings.get('templeStatStamina'), '${r.staminaCost}', positive: false));
    if (r.hungerCost > 0)
      lines.add(_StatLine('−', AppStrings.get('templeStatHunger'), '${r.hungerCost}', positive: false));

    if (r.type == TrainingType.strength) {
      if (r.expGain > 0)
        lines.add(_StatLine('+', '${AppStrings.get('charStatStr')} ${AppStrings.get('trainExpLabel')}', '+${_fmtExp(r.expGain)}', positive: true));
      if (r.agiExpGain > 0)
        lines.add(_StatLine('+', '${AppStrings.get('charStatAgi')} ${AppStrings.get('trainExpLabel')}', '+${_fmtExp(r.agiExpGain)}', positive: true));
      if (r.expGain == 0 && r.agiExpGain == 0)
        lines.add(_StatLine('', AppStrings.get('trainExpLabel'), '0', positive: false));
      if (r.hpChange < 0)
        lines.add(_StatLine('−', AppStrings.get('templeStatHp'), '${r.hpChange}', positive: false));
      if (r.sanityTrainChange < 0)
        lines.add(_StatLine('−', AppStrings.get('charStatSanity'), '${r.sanityTrainChange}', positive: false));
      if (r.humanityTrainChange < 0)
        lines.add(_StatLine('−', AppStrings.get('charStatHumanity'), '${r.humanityTrainChange}', positive: false));
      if (r.bleedActive)
        lines.add(_StatLine('!', AppStrings.get('trainStrEvBleedStatus'), '', positive: false));
      if (r.staminaDrained)
        lines.add(_StatLine('!', AppStrings.get('trainStrEvStaminaDrained'), '', positive: false));
      if (r.itemDropped != null)
        lines.add(_StatLine('+', AppStrings.get('trainStrEvItemFound'), AppStrings.get(r.itemDropped!.nameKey), positive: true));
    } else if (r.type == TrainingType.endurance) {
      if (r.expGain > 0)
        lines.add(_StatLine('+', '${AppStrings.get('charStatVit')} ${AppStrings.get('trainExpLabel')}', '+${_fmtExp(r.expGain)}', positive: true));
      if (r.defExpGain > 0)
        lines.add(_StatLine('+', '${AppStrings.get('charStatDef')} ${AppStrings.get('trainExpLabel')}', '+${_fmtExp(r.defExpGain)}', positive: true));
      if (r.expGain == 0 && r.defExpGain == 0)
        lines.add(_StatLine('', AppStrings.get('trainExpLabel'), '0', positive: false));
      if (r.staminaGainFromEvent > 0)
        lines.add(_StatLine('+', AppStrings.get('templeStatStamina'), '+${r.staminaGainFromEvent}', positive: true));
      if (r.hpChange < 0)
        lines.add(_StatLine('−', AppStrings.get('templeStatHp'), '${r.hpChange}', positive: false));
      if (r.sanityTrainChange < 0)
        lines.add(_StatLine('−', AppStrings.get('charStatSanity'), '${r.sanityTrainChange}', positive: false));
      if (r.humanityTrainChange < 0)
        lines.add(_StatLine('−', AppStrings.get('charStatHumanity'), '${r.humanityTrainChange}', positive: false));
      if (r.dislocatedActive)
        lines.add(_StatLine('!', AppStrings.get('trainEndEvDislocStatus'), '', positive: false));
      if (r.infectionActive)
        lines.add(_StatLine('!', AppStrings.get('trainEndEvInfectionStatus'), '', positive: false));
      if (r.staminaDrained)
        lines.add(_StatLine('!', AppStrings.get('trainStrEvStaminaDrained'), '', positive: false));
      if (r.itemDropped != null)
        lines.add(_StatLine('+', AppStrings.get('trainStrEvItemFound'), AppStrings.get(r.itemDropped!.nameKey), positive: true));
    } else {
      // meditation – event-based
      if (r.hpChange < 0)
        lines.add(_StatLine('−', AppStrings.get('templeStatHp'), '${r.hpChange}', positive: false));
      if (r.lanternLossFromEvent > 0)
        lines.add(_StatLine('−', AppStrings.get('hudLantern'), '−${r.lanternLossFromEvent}', positive: false));
      if (r.sanityTrainChange < 0)
        lines.add(_StatLine('−', AppStrings.get('charStatSanity'), '${r.sanityTrainChange}', positive: false));
      if (r.humanityTrainChange < 0)
        lines.add(_StatLine('−', AppStrings.get('charStatHumanity'), '${r.humanityTrainChange}', positive: false));
      if (r.expGain > 0)
        lines.add(_StatLine('+', '${AppStrings.get('charStatWill')} ${AppStrings.get('trainExpLabel')}', '+${_fmtExp(r.expGain)}', positive: true));
      if (r.sanityHealFromBranch > 0)
        lines.add(_StatLine('+', AppStrings.get('charStatSanity'), '+${r.sanityHealFromBranch}', positive: true));
      if (r.maxSanityIncrease > 0)
        lines.add(_StatLine('↑', AppStrings.get('charStatSanity'), '+${r.maxSanityIncrease} Max', positive: true));
      if (r.itemDropped != null)
        lines.add(_StatLine('+', AppStrings.get('trainStrEvItemFound'), AppStrings.get(r.itemDropped!.nameKey), positive: true));
      if (r.burnActive)
        lines.add(_StatLine('!', AppStrings.get('trainMedEvBurnStatus'), '', positive: false));
      if (r.staminaDrained)
        lines.add(_StatLine('!', AppStrings.get('trainStrEvStaminaDrained'), '', positive: false));
      if (r.expGain == 0 && r.sanityHealFromBranch == 0 && !r.navigateToCombat)
        lines.add(_StatLine('', AppStrings.get('trainExpLabel'), '0', positive: false));
    }
    return lines;
  }

  void _startSequence() async {
    // Delay nhỏ trước khi bắt đầu
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // Hiện từng dòng stat
    for (int i = 0; i < _lines.length; i++) {
      if (!mounted) return;
      setState(() => _visibleLines = i + 1);
      await Future.delayed(const Duration(milliseconds: 340));
    }
    if (!mounted) return;

    // Hiện EXP bars (chúng sẽ tự animate)
    setState(() => _showExpBars = true);
    // Chờ EXP bar animate xong (tối đa ~1.2s)
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    // Hiện level-up banners
    setState(() => _showLevelUpBanners = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    // Hiện nút tiếp tục
    setState(() => _showButton = true);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final Color color = switch (r.type) {
      TrainingType.strength   => const Color(0xFFCC5533),
      TrainingType.endurance  => const Color(0xFF3399CC),
      TrainingType.meditation => const Color(0xFF9966BB),
    };
    final String optionName = switch (r.type) {
      TrainingType.strength   => AppStrings.get('trainOptionStrength'),
      TrainingType.endurance  => AppStrings.get('trainOptionEndurance'),
      TrainingType.meditation => AppStrings.get('trainOptionMeditation'),
    };
    final bool atMax = r.statAfter >= CharacterDefaults.maxStatLevel;

    final String? eventImagePath = r.type == TrainingType.strength
        ? _strengthEventImagePath(r.strengthEvent)
        : r.type == TrainingType.endurance
            ? _enduranceEventImagePath(r.enduranceEvent)
            : r.type == TrainingType.meditation
                ? _meditationEventImagePath(r.meditationEvent)
                : null;
    final String? eventTitleKey = r.type == TrainingType.strength
        ? _strengthEventTitleKey(r.strengthEvent)
        : r.type == TrainingType.endurance
            ? _enduranceEventTitleKey(r.enduranceEvent)
            : r.type == TrainingType.meditation
                ? _meditationEventTitleKey(r.meditationEvent)
                : null;
    final String? eventDescKey = r.type == TrainingType.strength
        ? _strengthEventDescKey(r.strengthEvent)
        : r.type == TrainingType.endurance
            ? _enduranceEventDescKey(r.enduranceEvent)
            : r.type == TrainingType.meditation
                ? _meditationEventDescKey(r.meditationEvent)
                : null;
    final Color eventColor = r.type == TrainingType.strength
        ? _strengthEventColor(r.strengthEvent)
        : r.type == TrainingType.endurance
            ? _enduranceEventColor(r.enduranceEvent)
            : r.type == TrainingType.meditation
                ? _meditationEventColor(r.meditationEvent)
                : color;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.get('trainResultTitle'),
            style: const TextStyle(
              fontFamily: 'GnuUnifont',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4A843),
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            optionName,
            style: TextStyle(
              fontFamily: 'GnuUnifont',
              fontSize: 11,
              color: color,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),

          // ── Event block (image + title + desc) – hiện ngay lập tức ──────
          if (eventImagePath != null) ...[
            const SizedBox(height: 16),
            ClipRect(
              child: Image.asset(
                eventImagePath,
                width: double.infinity,
                height: 160,
                filterQuality: FilterQuality.none,
                fit: BoxFit.cover,
              ),
            ),
            if (eventTitleKey != null) ...[
              const SizedBox(height: 10),
              Text(
                AppStrings.get(eventTitleKey),
                style: TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: eventColor,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (eventDescKey != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF080808),
                  border: Border.all(color: const Color(0xFF2A2010), width: 1),
                ),
                child: Text(
                  AppStrings.get(eventDescKey),
                  style: const TextStyle(
                    fontFamily: 'GnuUnifont',
                    fontSize: 10,
                    color: Color(0xFF8A8478),
                    height: 1.7,
                  ),
                ),
              ),
            ],
          ],

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D0D),
              border: Border.all(color: const Color(0xFF2A2010), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Các dòng stat (hiện từng dòng) ─────────────────────
                for (int i = 0; i < _lines.length; i++)
                  AnimatedOpacity(
                    opacity: i < _visibleLines ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: AnimatedSlide(
                      offset: i < _visibleLines ? Offset.zero : const Offset(-0.08, 0),
                      duration: const Duration(milliseconds: 200),
                      child: _buildLine(_lines[i]),
                    ),
                  ),

                // ── EXP bars (xuất hiện sau, animate từ old→new) ────────
                if (_showExpBars) ...[
                  const SizedBox(height: 10),
                  if (r.type == TrainingType.strength) ...[
                    _AnimatedStatExpRow(
                      name: AppStrings.get('charStatStr'),
                      levelBefore: r.statBefore,
                      levelAfter: r.statAfter,
                      expBefore: r.expBefore,
                      expAfter: r.expAfter,
                      expNeeded: r.expNeeded,
                      leveledUp: r.leveledUp,
                      color: color,
                    ),
                    const SizedBox(height: 8),
                    _AnimatedStatExpRow(
                      name: AppStrings.get('charStatAgi'),
                      levelBefore: r.agiStatBefore,
                      levelAfter: r.agiStatAfter,
                      expBefore: r.agiExpBefore,
                      expAfter: r.agiExpAfter,
                      expNeeded: r.agiExpNeeded,
                      leveledUp: r.agiLeveledUp,
                      color: color,
                    ),
                  ] else if (r.type == TrainingType.endurance) ...[
                    _AnimatedStatExpRow(
                      name: AppStrings.get('charStatVit'),
                      levelBefore: r.statBefore,
                      levelAfter: r.statAfter,
                      expBefore: r.expBefore,
                      expAfter: r.expAfter,
                      expNeeded: r.expNeeded,
                      leveledUp: r.leveledUp,
                      color: color,
                    ),
                    const SizedBox(height: 8),
                    _AnimatedStatExpRow(
                      name: AppStrings.get('charStatDef'),
                      levelBefore: r.defStatBefore,
                      levelAfter: r.defStatAfter,
                      expBefore: r.defExpBefore,
                      expAfter: r.defExpAfter,
                      expNeeded: r.defExpNeeded,
                      leveledUp: r.defLeveledUp,
                      color: color,
                    ),
                  ] else if (atMax && !r.leveledUp)
                    Text(
                      AppStrings.get('trainMaxLevel'),
                      style: const TextStyle(
                        fontFamily: 'GnuUnifont',
                        fontSize: 10,
                        color: Color(0xFF8A8478),
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else ...[
                    _AnimatedStatExpRow(
                      name: AppStrings.get(switch (r.type) {
                        TrainingType.meditation => 'charStatWill',
                        _ => 'charStatWill',
                      }),
                      levelBefore: r.statBefore,
                      levelAfter: r.statAfter,
                      expBefore: r.expBefore,
                      expAfter: r.expAfter,
                      expNeeded: r.expNeeded,
                      leveledUp: r.leveledUp,
                      color: color,
                    ),
                  ],
                ],
              ],
            ),
          ),

          // ── Level-up banners ──────────────────────────────────────────
          if (_showLevelUpBanners && r.success) ...[
            if (r.type == TrainingType.strength) ...[
              if (r.leveledUp) ...[
                const SizedBox(height: 12),
                _FadeIn(child: _buildLevelUpBanner(
                  '${AppStrings.get('charStatStr')} ${r.statBefore} → ${r.statAfter}', color)),
              ],
              if (r.agiLeveledUp) ...[
                const SizedBox(height: 12),
                _FadeIn(child: _buildLevelUpBanner(
                  '${AppStrings.get('charStatAgi')} ${r.agiStatBefore} → ${r.agiStatAfter}', color)),
              ],
            ] else if (r.type == TrainingType.endurance) ...[
              if (r.leveledUp) ...[
                const SizedBox(height: 12),
                _FadeIn(child: _buildLevelUpBanner(
                  '${AppStrings.get('charStatVit')} ${r.statBefore} → ${r.statAfter}', color)),
              ],
              if (r.defLeveledUp) ...[
                const SizedBox(height: 12),
                _FadeIn(child: _buildLevelUpBanner(
                  '${AppStrings.get('charStatDef')} ${r.defStatBefore} → ${r.defStatAfter}', color)),
              ],
            ] else if (r.leveledUp) ...[
              const SizedBox(height: 12),
              _FadeIn(child: _buildLevelUpBanner(
                '${AppStrings.get('charStatWill')} ${r.statBefore} → ${r.statAfter}', color)),
            ],
          ],

          // ── Nút tiếp tục ─────────────────────────────────────────────
          const SizedBox(height: 20),
          AnimatedOpacity(
            opacity: _showButton ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: GestureDetector(
              onTap: _showButton
                  ? (r.navigateToCombat
                      ? (widget.onCombat ?? widget.onClose)
                      : widget.onClose)
                  : null,
              child: Container(
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  border: Border.all(
                    color: r.navigateToCombat
                        ? const Color(0xFF882222)
                        : const Color(0xFF4A3618),
                    width: 1,
                  ),
                ),
                child: Text(
                  r.navigateToCombat
                      ? AppStrings.get('trainStrEvCombatWarning')
                      : AppStrings.get('trainResultContinue'),
                  style: TextStyle(
                    fontFamily: 'GnuUnifont',
                    fontSize: 11,
                    color: r.navigateToCombat
                        ? const Color(0xFFCC4433)
                        : const Color(0xFFD4A843),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLine(_StatLine line) {
    final Color c = line.positive ? const Color(0xFF88AA66) : const Color(0xFFCC5544);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            child: Text(line.prefix, style: TextStyle(fontFamily: 'GnuUnifont', fontSize: 11, color: c)),
          ),
          Expanded(
            child: Text(line.label, style: const TextStyle(fontFamily: 'GnuUnifont', fontSize: 11, color: Color(0xFF8A8478))),
          ),
          Text(line.value, style: TextStyle(fontFamily: 'GnuUnifont', fontSize: 11, color: c, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLevelUpBanner(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
      ),
      child: Column(
        children: [
          Text(
            AppStrings.get('trainLevelUp'),
            style: TextStyle(
              fontFamily: 'GnuUnifont',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(fontFamily: 'GnuUnifont', fontSize: 11, color: Color(0xFFCEC8B0)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Helpers sự kiện ──────────────────────────────────────────────────────

  static String? _strengthEventTitleKey(StrengthTrainingEvent? ev) =>
      switch (ev) {
        StrengthTrainingEvent.normal          => 'trainStrEvNormalTitle',
        StrengthTrainingEvent.physicalInjury  => 'trainStrEvInjuryTitle',
        StrengthTrainingEvent.psychTrauma     => 'trainStrEvTraumaTitle',
        StrengthTrainingEvent.weaponAccident  => 'trainStrEvWeaponAccTitle',
        StrengthTrainingEvent.breakthrough    => 'trainStrEvBreakthruTitle',
        StrengthTrainingEvent.accidentalFind  => 'trainStrEvFindTitle',
        StrengthTrainingEvent.abyssCall       => 'trainStrEvAbyssTitle',
        StrengthTrainingEvent.exhaustion      => 'trainStrEvExhausTitle',
        StrengthTrainingEvent.dangerAttracted => 'trainStrEvDangerTitle',
        null                                  => null,
      };

  static String? _strengthEventDescKey(StrengthTrainingEvent? ev) =>
      switch (ev) {
        StrengthTrainingEvent.normal          => 'trainStrEvNormalDesc',
        StrengthTrainingEvent.physicalInjury  => 'trainStrEvInjuryDesc',
        StrengthTrainingEvent.psychTrauma     => 'trainStrEvTraumaDesc',
        StrengthTrainingEvent.weaponAccident  => 'trainStrEvWeaponAccDesc',
        StrengthTrainingEvent.breakthrough    => 'trainStrEvBreakthruDesc',
        StrengthTrainingEvent.accidentalFind  => 'trainStrEvFindDesc',
        StrengthTrainingEvent.abyssCall       => 'trainStrEvAbyssDesc',
        StrengthTrainingEvent.exhaustion      => 'trainStrEvExhausDesc',
        StrengthTrainingEvent.dangerAttracted => 'trainStrEvDangerDesc',
        null                                  => null,
      };

  static String? _strengthEventImagePath(StrengthTrainingEvent? ev) =>
      switch (ev) {
        StrengthTrainingEvent.normal          => 'assets/images/backgrounds/train/dry_weapon_swings/event_swing_success.png',
        StrengthTrainingEvent.physicalInjury  => 'assets/images/backgrounds/train/dry_weapon_swings/swing_physical_injury.png',
        StrengthTrainingEvent.psychTrauma     => 'assets/images/backgrounds/train/dry_weapon_swings/swing_psychological_horror.png',
        StrengthTrainingEvent.weaponAccident  => 'assets/images/backgrounds/train/dry_weapon_swings/swing_weapon_rust_accident.png',
        StrengthTrainingEvent.breakthrough    => 'assets/images/backgrounds/train/dry_weapon_swings/swing_enlightenment_breakthrough.png',
        StrengthTrainingEvent.accidentalFind  => 'assets/images/backgrounds/train/dry_weapon_swings/swing_accidental_discovery_lucky.png',
        StrengthTrainingEvent.abyssCall       => 'assets/images/backgrounds/train/dry_weapon_swings/swing_abyss_temptation.png',
        StrengthTrainingEvent.exhaustion      => 'assets/images/backgrounds/train/dry_weapon_swings/swing_life_drain_exhaustion.png',
        StrengthTrainingEvent.dangerAttracted => 'assets/images/backgrounds/train/dry_weapon_swings/swing_danger_combat_warning.png',
        null                                  => null,
      };

  static Color _strengthEventColor(StrengthTrainingEvent? ev) => switch (ev) {
        StrengthTrainingEvent.normal          => const Color(0xFFCEC8B0),
        StrengthTrainingEvent.physicalInjury  => const Color(0xFFCC4433),
        StrengthTrainingEvent.psychTrauma     => const Color(0xFF9966BB),
        StrengthTrainingEvent.weaponAccident  => const Color(0xFFCC4433),
        StrengthTrainingEvent.breakthrough    => const Color(0xFFD4A843),
        StrengthTrainingEvent.accidentalFind  => const Color(0xFF88AA66),
        StrengthTrainingEvent.abyssCall       => const Color(0xFF882266),
        StrengthTrainingEvent.exhaustion      => const Color(0xFF8A8478),
        StrengthTrainingEvent.dangerAttracted => const Color(0xFFCC2222),
        null                                  => const Color(0xFFCEC8B0),
      };

  static String? _enduranceEventTitleKey(EnduranceTrainingEvent? ev) =>
      switch (ev) {
        EnduranceTrainingEvent.normal              => 'trainEndEvNormalTitle',
        EnduranceTrainingEvent.spinalInjury        => 'trainEndEvSpinalTitle',
        EnduranceTrainingEvent.hiddenHazard        => 'trainEndEvHazardTitle',
        EnduranceTrainingEvent.psychologicalWeight => 'trainEndEvPsychTitle',
        EnduranceTrainingEvent.ironWill            => 'trainEndEvIronWillTitle',
        EnduranceTrainingEvent.forgottenCave       => 'trainEndEvCaveTitle',
        EnduranceTrainingEvent.bloodInRock         => 'trainEndEvBloodRockTitle',
        EnduranceTrainingEvent.crushed             => 'trainEndEvCrushedTitle',
        EnduranceTrainingEvent.collapseSound       => 'trainEndEvCollapseTitle',
        null                                       => null,
      };

  static String? _enduranceEventDescKey(EnduranceTrainingEvent? ev) =>
      switch (ev) {
        EnduranceTrainingEvent.normal              => 'trainEndEvNormalDesc',
        EnduranceTrainingEvent.spinalInjury        => 'trainEndEvSpinalDesc',
        EnduranceTrainingEvent.hiddenHazard        => 'trainEndEvHazardDesc',
        EnduranceTrainingEvent.psychologicalWeight => 'trainEndEvPsychDesc',
        EnduranceTrainingEvent.ironWill            => 'trainEndEvIronWillDesc',
        EnduranceTrainingEvent.forgottenCave       => 'trainEndEvCaveDesc',
        EnduranceTrainingEvent.bloodInRock         => 'trainEndEvBloodRockDesc',
        EnduranceTrainingEvent.crushed             => 'trainEndEvCrushedDesc',
        EnduranceTrainingEvent.collapseSound       => 'trainEndEvCollapseDesc',
        null                                       => null,
      };

  static Color _enduranceEventColor(EnduranceTrainingEvent? ev) => switch (ev) {
        EnduranceTrainingEvent.normal              => const Color(0xFFCEC8B0),
        EnduranceTrainingEvent.spinalInjury        => const Color(0xFFCC4433),
        EnduranceTrainingEvent.hiddenHazard        => const Color(0xFF996633),
        EnduranceTrainingEvent.psychologicalWeight => const Color(0xFF9966BB),
        EnduranceTrainingEvent.ironWill            => const Color(0xFFD4A843),
        EnduranceTrainingEvent.forgottenCave       => const Color(0xFF88AA66),
        EnduranceTrainingEvent.bloodInRock         => const Color(0xFF882266),
        EnduranceTrainingEvent.crushed             => const Color(0xFFCC2222),
        EnduranceTrainingEvent.collapseSound       => const Color(0xFFCC4422),
        null                                       => const Color(0xFFCEC8B0),
      };

  static String? _enduranceEventImagePath(EnduranceTrainingEvent? ev) =>
      switch (ev) {
        EnduranceTrainingEvent.normal              => 'assets/images/backgrounds/train/lumber_hauling/carry_success.png',
        EnduranceTrainingEvent.spinalInjury        => 'assets/images/backgrounds/train/lumber_hauling/carry_spine_injury.png',
        EnduranceTrainingEvent.hiddenHazard        => 'assets/images/backgrounds/train/lumber_hauling/carry_hidden_hazard_bite.png',
        EnduranceTrainingEvent.psychologicalWeight => 'assets/images/backgrounds/train/lumber_hauling/carry_psychological_horror.png',
        EnduranceTrainingEvent.ironWill            => 'assets/images/backgrounds/train/lumber_hauling/carry_iron_will_breakthrough.png',
        EnduranceTrainingEvent.forgottenCave       => 'assets/images/backgrounds/train/lumber_hauling/carry_accidental_discovery.png',
        EnduranceTrainingEvent.bloodInRock         => 'assets/images/backgrounds/train/lumber_hauling/carry_abyss_symbiosis.png',
        EnduranceTrainingEvent.crushed             => 'assets/images/backgrounds/train/lumber_hauling/carry_crushed_exhaustion.png',
        EnduranceTrainingEvent.collapseSound       => 'assets/images/backgrounds/train/lumber_hauling/carry_danger_noise.png',
        null                                       => null,
      };

  // ── Meditation event helpers ─────────────────────────────────────────────

  static String? _meditationEventTitleKey(MeditationTrainingEvent? ev) =>
      switch (ev) {
        MeditationTrainingEvent.normal             => 'trainMedEvNormalTitle',
        MeditationTrainingEvent.psychHallucination => 'trainMedEvPsychHallucinationTitle',
        MeditationTrainingEvent.burnInjury         => 'trainMedEvBurnInjuryTitle',
        MeditationTrainingEvent.lanternFlicker     => 'trainMedEvLanternFlickerTitle',
        MeditationTrainingEvent.enlightenment      => 'trainMedEvEnlightenmentTitle',
        MeditationTrainingEvent.ancientScript      => 'trainMedEvAncientScriptTitle',
        MeditationTrainingEvent.abyssCall          => 'trainMedEvAbyssCallTitle',
        MeditationTrainingEvent.soulWander         => 'trainMedEvSoulWanderTitle',
        MeditationTrainingEvent.shadowBetrayal     => 'trainMedEvShadowBetrayalTitle',
        null                                       => null,
      };

  static String? _meditationEventDescKey(MeditationTrainingEvent? ev) =>
      switch (ev) {
        MeditationTrainingEvent.normal             => 'trainMedEvNormalDesc',
        MeditationTrainingEvent.psychHallucination => 'trainMedEvPsychHallucinationDesc',
        MeditationTrainingEvent.burnInjury         => 'trainMedEvBurnInjuryDesc',
        MeditationTrainingEvent.lanternFlicker     => 'trainMedEvLanternFlickerDesc',
        MeditationTrainingEvent.enlightenment      => 'trainMedEvEnlightenmentDesc',
        MeditationTrainingEvent.ancientScript      => 'trainMedEvAncientScriptDesc',
        MeditationTrainingEvent.abyssCall          => 'trainMedEvAbyssCallDesc',
        MeditationTrainingEvent.soulWander         => 'trainMedEvSoulWanderDesc',
        MeditationTrainingEvent.shadowBetrayal     => 'trainMedEvShadowBetrayalDesc',
        null                                       => null,
      };

  static Color _meditationEventColor(MeditationTrainingEvent? ev) => switch (ev) {
        MeditationTrainingEvent.normal             => const Color(0xFFCEC8B0),
        MeditationTrainingEvent.psychHallucination => const Color(0xFF9966BB),
        MeditationTrainingEvent.burnInjury         => const Color(0xFFCC4433),
        MeditationTrainingEvent.lanternFlicker     => const Color(0xFF4A6688),
        MeditationTrainingEvent.enlightenment      => const Color(0xFFD4A843),
        MeditationTrainingEvent.ancientScript      => const Color(0xFF88AA66),
        MeditationTrainingEvent.abyssCall          => const Color(0xFF882266),
        MeditationTrainingEvent.soulWander         => const Color(0xFF8A8478),
        MeditationTrainingEvent.shadowBetrayal     => const Color(0xFFCC2222),
        null                                       => const Color(0xFFCEC8B0),
      };

  static String? _meditationEventImagePath(MeditationTrainingEvent? ev) =>
      switch (ev) {
        MeditationTrainingEvent.normal             => 'assets/images/backgrounds/train/fire_meditation/meditate_calm.png',
        MeditationTrainingEvent.psychHallucination => 'assets/images/backgrounds/train/fire_meditation/meditate_trauma_faces.png',
        MeditationTrainingEvent.burnInjury         => 'assets/images/backgrounds/train/fire_meditation/meditate_fire_burn.png',
        MeditationTrainingEvent.lanternFlicker     => 'assets/images/backgrounds/train/fire_meditation/meditate_encroaching_darkness.png',
        MeditationTrainingEvent.enlightenment      => 'assets/images/backgrounds/train/fire_meditation/meditate_enlightenment_aura.png',
        MeditationTrainingEvent.ancientScript      => 'assets/images/backgrounds/train/fire_meditation/meditate_rune_discovery.png',
        MeditationTrainingEvent.abyssCall          => 'assets/images/backgrounds/train/fire_meditation/meditate_abyss_eye.png',
        MeditationTrainingEvent.soulWander         => 'assets/images/backgrounds/train/fire_meditation/meditate_frozen_death.png',
        MeditationTrainingEvent.shadowBetrayal     => 'assets/images/backgrounds/train/fire_meditation/meditate_betrayal_shadow.png',
        null                                       => null,
      };
}

// Model cho từng dòng stat
class _StatLine {
  final String prefix;
  final String label;
  final String value;
  final bool positive;
  const _StatLine(this.prefix, this.label, this.value, {required this.positive});
}

// ────────────────────────────────────────────────────────────────────────────
// Widget fade-in đơn giản (dùng cho event block và level-up banner)
// ────────────────────────────────────────────────────────────────────────────

class _FadeIn extends StatefulWidget {
  final Widget child;
  const _FadeIn({required this.child});

  @override
  State<_FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<_FadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _opacity, child: widget.child);
}

// ────────────────────────────────────────────────────────────────────────────
// Animated EXP row: thanh chạy từ expBefore→expAfter, level counter tăng
// ────────────────────────────────────────────────────────────────────────────

class _AnimatedStatExpRow extends StatefulWidget {
  final String name;
  final int levelBefore;
  final int levelAfter;
  final double expBefore;
  final double expAfter;
  final double expNeeded;
  final bool leveledUp;
  final Color color;

  const _AnimatedStatExpRow({
    required this.name,
    required this.levelBefore,
    required this.levelAfter,
    required this.expBefore,
    required this.expAfter,
    required this.expNeeded,
    required this.leveledUp,
    required this.color,
  });

  @override
  State<_AnimatedStatExpRow> createState() => _AnimatedStatExpRowState();
}

class _AnimatedStatExpRowState extends State<_AnimatedStatExpRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late int _displayLevel;

  @override
  void initState() {
    super.initState();
    _displayLevel = widget.levelBefore;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _ctrl.addListener(_onTick);
    _ctrl.forward();
  }

  void _onTick() {
    if (!widget.leveledUp) {
      setState(() {});
      return;
    }
    // Khi progress vượt điểm mà EXP bar "đầy" (= xong level cũ), cập nhật level
    // Điểm reset xảy ra khi expBefore + gain >= expNeeded
    // Ta ước tính khi animation value đạt tỷ lệ nhất định
    final double expNeededOld = Character.expNeededToLevel(widget.levelBefore);
    final double totalGain = (widget.levelAfter > widget.levelBefore
        ? expNeededOld - widget.expBefore + widget.expAfter
        : widget.expAfter - widget.expBefore);
    if (totalGain <= 0) {
      setState(() {});
      return;
    }
    // Fraction tại điểm level-up
    final double levelUpFraction = (expNeededOld - widget.expBefore) / totalGain;
    final int newLevel = _ctrl.value >= levelUpFraction.clamp(0.0, 1.0)
        ? widget.levelAfter
        : widget.levelBefore;
    if (newLevel != _displayLevel) {
      setState(() => _displayLevel = newLevel);
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onTick);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMax = _displayLevel >= CharacterDefaults.maxStatLevel;

    // Tính EXP hiện tại để hiển thị
    double currentExp;
    double currentNeeded;
    if (!widget.leveledUp) {
      currentExp = widget.expBefore + (widget.expAfter - widget.expBefore) * _ctrl.value;
      currentNeeded = widget.expNeeded;
    } else {
      final double expNeededOld = Character.expNeededToLevel(widget.levelBefore);
      final double totalGain = expNeededOld - widget.expBefore + widget.expAfter;
      if (totalGain <= 0) {
        currentExp = widget.expAfter;
        currentNeeded = widget.expNeeded;
      } else {
        final double levelUpFraction = (expNeededOld - widget.expBefore) / totalGain;
        if (_ctrl.value < levelUpFraction) {
          // Đang fill đến max level cũ
          final double frac = totalGain > 0 ? _ctrl.value / levelUpFraction : 1.0;
          currentExp = widget.expBefore + (expNeededOld - widget.expBefore) * frac.clamp(0.0, 1.0);
          currentNeeded = expNeededOld;
        } else {
          // Đã level-up, bắt đầu fill mức mới từ 0→expAfter
          final double frac = levelUpFraction < 1.0
              ? (_ctrl.value - levelUpFraction) / (1.0 - levelUpFraction)
              : 1.0;
          currentExp = widget.expAfter * frac.clamp(0.0, 1.0);
          currentNeeded = widget.expNeeded;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${widget.name}  Lv.$_displayLevel',
              style: const TextStyle(
                fontFamily: 'GnuUnifont',
                fontSize: 10,
                color: Color(0xFFCEC8B0),
              ),
            ),
            const Spacer(),
            if (isMax)
              Text(
                'MAX',
                style: TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                ),
              )
            else
              Text(
                '${_fmtExp(currentExp)} / ${_fmtExp(currentNeeded)}',
                style: const TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 10,
                  color: Color(0xFF8A8478),
                ),
              ),
          ],
        ),
        if (!isMax) ...[
          const SizedBox(height: 4),
          _ExpBar(current: currentExp, needed: currentNeeded, color: widget.color),
        ],
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────

/// Thanh EXP pixel art.
class _ExpBar extends StatelessWidget {
  final double current;
  final double needed;
  final Color color;

  const _ExpBar(
      {required this.current, required this.needed, required this.color});

  @override
  Widget build(BuildContext context) {
    final double ratio =
        needed > 0 ? (current / needed).clamp(0.0, 1.0) : 1.0;
    return Container(
      height: 6,
      width: double.infinity,
      color: const Color(0xFF1A1A1A),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: ratio,
          child: Container(color: color),
        ),
      ),
    );
  }
}

/// Định dạng giá trị EXP: số nguyên không có dấu chấm, phân số 1 chữ số thập phân.
String _fmtExp(double v) =>
    v == v.truncateToDouble() ? '${v.toInt()}' : v.toStringAsFixed(1);

// ────────────────────────────────────────────────────────────────────────────

/// Badge sự kiện ngẫu nhiên khi Vung Vũ Khí Khan.
class _StrTrainingEventBadge extends StatelessWidget {
  final StrengthTrainingEvent event;
  const _StrTrainingEventBadge({required this.event});

  static Color _color(StrengthTrainingEvent e) => switch (e) {
        StrengthTrainingEvent.normal          => const Color(0xFF88AA66),
        StrengthTrainingEvent.physicalInjury  => const Color(0xFFCC5544),
        StrengthTrainingEvent.psychTrauma     => const Color(0xFF9966BB),
        StrengthTrainingEvent.weaponAccident  => const Color(0xFFCC4433),
        StrengthTrainingEvent.breakthrough    => const Color(0xFFD4A843),
        StrengthTrainingEvent.accidentalFind  => const Color(0xFF66AACC),
        StrengthTrainingEvent.abyssCall       => const Color(0xFF8855AA),
        StrengthTrainingEvent.exhaustion      => const Color(0xFF997755),
        StrengthTrainingEvent.dangerAttracted => const Color(0xFFCC3322),
      };

  static String _titleKey(StrengthTrainingEvent e) => switch (e) {
        StrengthTrainingEvent.normal          => 'trainStrEvNormalTitle',
        StrengthTrainingEvent.physicalInjury  => 'trainStrEvInjuryTitle',
        StrengthTrainingEvent.psychTrauma     => 'trainStrEvTraumaTitle',
        StrengthTrainingEvent.weaponAccident  => 'trainStrEvWeaponAccTitle',
        StrengthTrainingEvent.breakthrough    => 'trainStrEvBreakthruTitle',
        StrengthTrainingEvent.accidentalFind  => 'trainStrEvFindTitle',
        StrengthTrainingEvent.abyssCall       => 'trainStrEvAbyssTitle',
        StrengthTrainingEvent.exhaustion      => 'trainStrEvExhausTitle',
        StrengthTrainingEvent.dangerAttracted => 'trainStrEvDangerTitle',
      };

  static String _descKey(StrengthTrainingEvent e) => switch (e) {
        StrengthTrainingEvent.normal          => 'trainStrEvNormalDesc',
        StrengthTrainingEvent.physicalInjury  => 'trainStrEvInjuryDesc',
        StrengthTrainingEvent.psychTrauma     => 'trainStrEvTraumaDesc',
        StrengthTrainingEvent.weaponAccident  => 'trainStrEvWeaponAccDesc',
        StrengthTrainingEvent.breakthrough    => 'trainStrEvBreakthruDesc',
        StrengthTrainingEvent.accidentalFind  => 'trainStrEvFindDesc',
        StrengthTrainingEvent.abyssCall       => 'trainStrEvAbyssDesc',
        StrengthTrainingEvent.exhaustion      => 'trainStrEvExhausDesc',
        StrengthTrainingEvent.dangerAttracted => 'trainStrEvDangerDesc',
      };

  @override
  Widget build(BuildContext context) {
    final color = _color(event);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.get(_titleKey(event)),
            style: TextStyle(
              fontFamily: 'GnuUnifont',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.get(_descKey(event)),
            style: const TextStyle(
              fontFamily: 'GnuUnifont',
              fontSize: 10,
              color: Color(0xFF8A8478),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────

/// Chip chi phí – đỏ nếu không đủ tài nguyên.
class _CostChip extends StatelessWidget {
  final String label;
  final bool ok;

  const _CostChip({required this.label, required this.ok});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'GnuUnifont',
        fontSize: 10,
        color: ok ? const Color(0xFF8A8478) : const Color(0xFFCC4433),
      ),
    );
  }
}
