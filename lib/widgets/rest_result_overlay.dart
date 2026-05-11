import 'package:flutter/material.dart';
import 'package:one_hundred_sunless_days/l10n/app_strings.dart';
import 'package:one_hundred_sunless_days/models/character.dart';
import 'package:one_hundred_sunless_days/models/item.dart';
import 'package:one_hundred_sunless_days/models/lantern.dart';

// ────────────────────────────────────────────────────────────────────────────
// Overlay kết quả Nghỉ Ngơi – animated (dòng hiện từng cái, nút cuối)
// ────────────────────────────────────────────────────────────────────────────

class RestResultOverlay extends StatefulWidget {
  final RestResult result;
  final Character character;
  final VoidCallback onContinue;

  const RestResultOverlay({
    super.key,
    required this.result,
    required this.character,
    required this.onContinue,
  });

  @override
  State<RestResultOverlay> createState() => _RestResultOverlayState();
}

// ── Dữ liệu một dòng chỉ số ─────────────────────────────────────────────────

class _RestLine {
  final String prefix;
  final String label;
  final String value;
  final bool positive;
  const _RestLine(this.prefix, this.label, this.value,
      {required this.positive});
}

// ── State với animation ──────────────────────────────────────────────────────

class _RestResultOverlayState extends State<RestResultOverlay>
    with TickerProviderStateMixin {
  int _visibleLines = 0;
  bool _showButton = false;

  late final List<_RestLine> _lines;

  @override
  void initState() {
    super.initState();
    _lines = _buildLines(widget.result, widget.character);
    _startSequence();
  }

  // Xây danh sách các dòng chỉ số từ RestResult
  List<_RestLine> _buildLines(RestResult r, Character character) {
    final lines = <_RestLine>[];

    // ── THỂ LỰC ─────────────────────────────────────────────────────────────
    // Hiển thị delta thực tế (staminaAfter − staminaBefore)
    final int staminaAfter = character.stamina;
    final int staminaDelta = staminaAfter - r.staminaBefore;
    if (staminaDelta > 0) {
      lines.add(_RestLine('+', AppStrings.get('templeStatStamina'),
          '+$staminaDelta', positive: true));
    } else if (staminaDelta < 0) {
      lines.add(_RestLine('−', AppStrings.get('templeStatStamina'),
          '−${staminaDelta.abs()}', positive: false));
    } else {
      // Không thay đổi (đã đầy hoặc bị giới hạn)
      lines.add(_RestLine('|', AppStrings.get('templeStatStamina'),
          '±0', positive: true));
    }

    // ── MÁU ──────────────────────────────────────────────────────────────────
    if (r.event == NightEvent.suddenDeathDoor) {
      // HP bị ép về 1 bất kể lượng hồi phục thực tế
      lines.add(_RestLine('!', AppStrings.get('templeStatHp'),
          AppStrings.get('restHpToOne'), positive: false));
    } else {
      // baseHpChange = HP thay đổi không tính phần extra của vaultSong
      // (vaultSongExtraHp sẽ được hiển thị thành dòng riêng bên dưới)
      final int baseHpChange = (r.event == NightEvent.vaultSong && r.vaultSongExtraHp > 0)
          ? r.hpHealed - r.vaultSongExtraHp
          : r.hpHealed;
      final String hpPfx = baseHpChange >= 0 ? '+' : '!';
      final String hpVal = baseHpChange >= 0
          ? '+$baseHpChange'
          : '−${baseHpChange.abs()}';
      lines.add(_RestLine(hpPfx, AppStrings.get('templeStatHp'), hpVal,
          positive: baseHpChange >= 0));
    }

    // ── ĐỘ TỈNH TÁO (ẩn khi ashFlare – đã có dòng ★ bên dưới) ──────────────
    if (r.sanityChange != 0 && !r.ashFlareActive)
      lines.add(_RestLine(
        r.sanityChange >= 0 ? '+' : '−',
        AppStrings.get('charStatSanity'),
        r.sanityChange >= 0
            ? '+${r.sanityChange}'
            : '−${r.sanityChange.abs()}',
        positive: r.sanityChange >= 0,
      ));

    // ── ĐỘ NO ─────────────────────────────────────────────────────────────────
    lines.add(_RestLine('−', AppStrings.get('templeStatHunger'),
        '−${r.hungerLost}', positive: false));

    // ── LỒNG ĐÈN (ẩn khi ashFlare) ──────────────────────────────────────────
    if (!r.ashFlareActive)
      lines.add(_RestLine('−', AppStrings.get('hudLantern'),
          '−${r.lanternCost}', positive: false));

    // ── CHẾT ĐÓI ──────────────────────────────────────────────────────────────
    if (r.starvationDamage)
      lines.add(_RestLine('!', AppStrings.get('restStarvation'),
          '−${r.starvationHpLost} ${AppStrings.get('templeStatHp')}',
          positive: false));

    // ── CHUỘT THAN – cắp đồ ăn / y tế ──────────────────────────────────────
    if (r.foodStolen != null)
      lines.add(_RestLine('!', AppStrings.get('restFoodStolen'),
          '−1 ${AppStrings.get(r.foodStolen!.nameKey)}', positive: false));

    // ── CHUỘT THAN – hút Độ Sáng ────────────────────────────────────────────
    if (r.emberThiefBrightnessLost > 0)
      lines.add(_RestLine('!', AppStrings.get('restEmberThiefBrightness'),
          '−${r.emberThiefBrightnessLost}', positive: false));

    // ── THÌ THẦM TỪ BÓNG TỐI – khám phá ngày mai ────────────────────────────
    if (r.blindWhisperBonus)
      lines.add(_RestLine('✦', AppStrings.get('restBlindWhisperBonus'),
          '+20%', positive: true));

    // ── NHÂN TÍNH ─────────────────────────────────────────────────────────────
    if (r.humanityChange > 0)
      lines.add(_RestLine('+', AppStrings.get('restSadMemoryHumanity'),
          '+${r.humanityChange}', positive: true));
    if (r.humanityChange < 0)
      lines.add(_RestLine('!', AppStrings.get('restOutsidePleaHumanity'),
          '−${r.humanityChange.abs()}', positive: false));

    // ── LỜI CẦU CỨU – bị trộm vật phẩm ────────────────────────────────────
    if (r.outsidePleaItem != null)
      lines.add(_RestLine('!', AppStrings.get('restOutsidePleaStolen'),
          '−1 ${AppStrings.get(r.outsidePleaItem!.nameKey)}', positive: false));

    // ── SƯƠNG ĐỘC – trạng thái [Tức Ngực] ────────────────────────────────────
    if (r.toxicFogActive)
      lines.add(_RestLine('!', AppStrings.get('restToxicFogStatus'), '',
          positive: false));

    // ── KHÚC HÁT TỪ RƯỜNG CỘT – HP thêm / đèn mất thêm ─────────────────────
    if (r.vaultSongExtraHp > 0)
      lines.add(_RestLine('+', AppStrings.get('restVaultSongExtraHp'),
          '+${r.vaultSongExtraHp}', positive: true));
    if (r.vaultSongExtraLanternCost > 0)
      lines.add(_RestLine('!', AppStrings.get('restVaultSongExtraLantern'),
          '−${r.vaultSongExtraLanternCost}', positive: false));

    // ── SỰ SOI RỌI CỦA TRO TÀN ───────────────────────────────────────────────
    if (r.ashFlareActive) {
      lines.add(_RestLine('★', AppStrings.get('restAshFlareLantern'), '±0',
          positive: true));
      lines.add(_RestLine('★', AppStrings.get('restAshFlareSanity'), '100%',
          positive: true));
      lines.add(_RestLine('★', AppStrings.get('restAshFlareStatus'), '',
          positive: true));
    }

    // ── DEBUFF KÍCH HOẠT ─────────────────────────────────────────────────────
    if (r.racingHeartActive)
      lines.add(_RestLine('!', AppStrings.get('statusRacingHeart'), '',
          positive: false));
    if (r.sleepyActive)
      lines.add(_RestLine('!', AppStrings.get('statusSleepy'), '',
          positive: false));
    if (r.fearActive)
      lines.add(_RestLine('!', AppStrings.get('statusFear'), '',
          positive: false));

    return lines;
  }

  // Chuỗi animation: delay → hiện từng dòng → hiện nút
  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    for (int i = 0; i < _lines.length; i++) {
      if (!mounted) return;
      setState(() => _visibleLines = i + 1);
      await Future.delayed(const Duration(milliseconds: 340));
    }
    if (!mounted) return;
    setState(() => _showButton = true);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final Color eventColor = _eventColor(r.event);

    return Container(
      color: const Color(0xEE0A0A0A),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Tiêu đề chính ──────────────────────────────────────
              Text(
                AppStrings.get('restResultTitle'),
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

              // ── Ngày mới ───────────────────────────────────────────
              Text(
                AppStrings.get('restTitleDay').replaceFirst('%d', '${r.newDay}'),
                style: const TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 11,
                  color: Color(0xFF8A7A58),
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // ── Ảnh sự kiện đêm (hiện ngay lập tức) ───────────────
              ClipRect(
                child: Image.asset(
                  _eventImagePath(r.event),
                  width: double.infinity,
                  height: 160,
                  filterQuality: FilterQuality.none,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),

              // ── Tên sự kiện ────────────────────────────────────────
              Text(
                AppStrings.get(_eventTitleKey(r.event)),
                style: TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: eventColor,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // ── Mô tả sự kiện ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF080808),
                  border: Border.all(color: const Color(0xFF2A2010), width: 1),
                ),
                child: Text(
                  AppStrings.get(_eventDescKey(r)),
                  style: const TextStyle(
                    fontFamily: 'GnuUnifont',
                    fontSize: 10,
                    color: Color(0xFF8A8478),
                    height: 1.7,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Card chứa các dòng chỉ số ──────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D0D),
                  border: Border.all(color: const Color(0xFF2A2010), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < _lines.length; i++)
                      AnimatedOpacity(
                        opacity: i < _visibleLines ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: AnimatedSlide(
                          offset: i < _visibleLines
                              ? Offset.zero
                              : const Offset(-0.08, 0),
                          duration: const Duration(milliseconds: 200),
                          child: _buildLine(_lines[i]),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Nút tiếp tục (hiện cuối cùng) ─────────────────────
              const SizedBox(height: 20),
              AnimatedOpacity(
                opacity: _showButton ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: GestureDetector(
                  onTap: _showButton ? widget.onContinue : null,
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
                          ? AppStrings.get('restTapToCombat')
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLine(_RestLine line) {
    final color =
        line.positive ? const Color(0xFF88AA66) : const Color(0xFFCC5544);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            child: Text(line.prefix,
                style: TextStyle(
                    fontFamily: 'GnuUnifont', fontSize: 11, color: color)),
          ),
          Expanded(
            child: Text(line.label,
                style: const TextStyle(
                    fontFamily: 'GnuUnifont',
                    fontSize: 11,
                    color: Color(0xFF8A8478))),
          ),
          Text(line.value,
              style: TextStyle(
                  fontFamily: 'GnuUnifont',
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ── Metadata sự kiện đêm ─────────────────────────────────────────────────

  String _eventTitleKey(NightEvent e) => switch (e) {
        NightEvent.deepSleep        => 'nightEventDeepSleepTitle',
        NightEvent.nightmare        => 'nightEventNightmareTitle',
        NightEvent.blindWhisper     => 'nightEventBlindWhisperTitle',
        NightEvent.emberThief       => 'nightEventEmberThiefTitle',
        NightEvent.nightRaid        => 'nightEventNightRaidTitle',
        NightEvent.sadMemory        => 'nightEventSadMemoryTitle',
        NightEvent.outsidePlea      => 'nightEventOutsidePleaTitle',
        NightEvent.toxicFog         => 'nightEventToxicFogTitle',
        NightEvent.vaultSong        => 'nightEventVaultSongTitle',
        NightEvent.ashFlare         => 'nightEventAshFlareTitle',
        NightEvent.suddenDeathDoor  => 'nightEventSuddenDeathDoorTitle',
      };

  String _eventDescKey(RestResult r) {
    if (r.event == NightEvent.outsidePlea) {
      // 3 nhánh phụ: đóng cửa | mở cửa bị trộm | mở cửa bị tấn công
      if (r.humanityChange < 0)   return 'nightEventOutsidePleaDesc';       // đóng cửa
      if (r.navigateToCombat)     return 'nightEventOutsidePleaCombatDesc'; // bị tấn công
      return 'nightEventOutsidePleaStolenDesc';                              // bị trộm / cố trộm
    }
    return switch (r.event) {
      NightEvent.deepSleep        => 'nightEventDeepSleepDesc',
      NightEvent.nightmare        => 'nightEventNightmareDesc',
      NightEvent.blindWhisper     => 'nightEventBlindWhisperDesc',
      NightEvent.emberThief       => 'nightEventEmberThiefDesc',
      NightEvent.nightRaid        => 'nightEventNightRaidDesc',
      NightEvent.sadMemory        => 'nightEventSadMemoryDesc',
      NightEvent.outsidePlea      => 'nightEventOutsidePleaDesc', // fallback
      NightEvent.toxicFog         => 'nightEventToxicFogDesc',
      NightEvent.vaultSong        => 'nightEventVaultSongDesc',
      NightEvent.ashFlare         => 'nightEventAshFlareDesc',
      NightEvent.suddenDeathDoor  => 'nightEventSuddenDeathDoorDesc',
    };
  }

  Color _eventColor(NightEvent e) => switch (e) {
        NightEvent.deepSleep        => const Color(0xFF5588AA),
        NightEvent.nightmare        => const Color(0xFF884466),
        NightEvent.blindWhisper     => const Color(0xFF88AA66),
        NightEvent.emberThief       => const Color(0xFFCC8833),
        NightEvent.nightRaid        => const Color(0xFFCC4433),
        NightEvent.sadMemory        => const Color(0xFF8899CC),
        NightEvent.outsidePlea      => const Color(0xFF887766),
        NightEvent.toxicFog         => const Color(0xFF668855),
        NightEvent.vaultSong        => const Color(0xFF9966AA),
        NightEvent.ashFlare         => const Color(0xFFDDB844),
        NightEvent.suddenDeathDoor  => const Color(0xFFCC2222),
      };

  static const String _restBase = 'assets/images/backgrounds/rest/';

  String _eventImagePath(NightEvent e) => switch (e) {
        NightEvent.deepSleep        => '${_restBase}deep_sleep.png',
        NightEvent.nightmare        => '${_restBase}nightmare_cannibal_shadows.png',
        NightEvent.blindWhisper     => '${_restBase}blind_one_whisper_noir.png',
        NightEvent.emberThief       => '${_restBase}ash_rat_thief.png',
        NightEvent.nightRaid        => '${_restBase}raid_monster_confrontation.png',
        NightEvent.sadMemory        => '${_restBase}sad_memory_family_feast.png',
        NightEvent.outsidePlea      => '${_restBase}desperate_beggar_exterior_gothic_door.png',
        NightEvent.toxicFog         => '${_restBase}toxic_fog_storm_choking.png',
        NightEvent.vaultSong        => '${_restBase}haunting_song_from_rafters.png',
        NightEvent.ashFlare         => '${_restBase}skull_lantern_sacred_radiance_grayscale.png',
        NightEvent.suddenDeathDoor  => '${_restBase}sleep_sudden_death.png',
      };
}
