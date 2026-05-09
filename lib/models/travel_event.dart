import 'dart:math';

// ────────────────────────────────────────────────────────────────────────────
// Hệ thống sự kiện di chuyển (Travel Event System)
// ────────────────────────────────────────────────────────────────────────────

/// Tất cả loại sự kiện có thể xảy ra trong mỗi lượt di chuyển.
enum TravelEventType {
  breathOfSilence,   // 36.0% – Khoảng Không Tĩnh Lặng
  shatteredCarriage, // 10.5% – Cỗ Xe Ngựa Gãy Nát
  hangedMan,         // 10.5% – Kẻ Treo Cổ Giữa Rừng
  blackBloodRain,    //  7.5% – Cơn Mưa Máu Đen
  criesInThicket,    //  7.5% – Tiếng Khóc Trong Bụi Rậm
  feralTerritory,    //  7.5% – Lãnh Địa Dã Thú
  wanderingAmbush,   //  7.5% – Kẻ Đi Săn Lang Thang
  facelessGoddess,   //  2.5% – Tượng Nữ Thần Vô Diện
  madmanChessboard,  //  2.5% – Bàn Cờ Của Kẻ Điên
  wanderingSmuggler, //  2.5% – Thương Nhân Lưu Vong
  theConfessor,      //  2.5% – Tu Sĩ Xưng Tội
  fogAnomaly,        //  3.0% – Biến Cố Sương Mù
}

/// Dữ liệu tĩnh của một sự kiện di chuyển.
class TravelEvent {
  final TravelEventType type;

  /// Đường dẫn ảnh minh họa. null = sự kiện không có hình ảnh.
  final String? imagePath;

  final String titleKey;
  final String descKey;

  /// Danh sách lựa chọn. null = chỉ hiện nút TIẾP TỤC.
  final List<EventChoice>? choices;

  const TravelEvent({
    required this.type,
    this.imagePath,
    required this.titleKey,
    required this.descKey,
    this.choices,
  });
}

// ────────────────────────────────────────────────────────────────────────────
// Hệ thống lựa chọn & kết quả (Choice / Outcome System)
// ────────────────────────────────────────────────────────────────────────────

enum OutcomeEffectType {
  gainLantern,          // +value% độ sáng
  gainStamina,          // +value thể lực
  loseSanity,           // −value tỉnh táo
  loseStamina,          // −value thể lực
  triggerCombat,        // chuyển sang combat, kẻ địch đánh trước
  gainSanity,           // +value tỉnh táo
  loseHp,               // −value máu
  applyPoison,          // gây Nhiễm Độc N lượt (value = số lượt)
  applyBleeding,        // gây Chảy Máu
  gainRandomMaterials,  // nhận value nguyên liệu ngẫu nhiên (tier trọng số)
  gainRandomEpicMaterial, // nhận 1 nguyên liệu Epic ngẫu nhiên
  gainFullSanity,       // hồi đầy tỉnh táo
  applyBloodlust,       // buff Cuồng Huyết value lượt
  loseMaxHp,            // giảm Max HP vĩnh viễn value điểm
}

class OutcomeEffect {
  final OutcomeEffectType type;
  final int value;
  const OutcomeEffect(this.type, this.value);
}

class EventOutcome {
  final String titleKey;
  final String descKey;
  final String? imagePath;
  final List<OutcomeEffect> effects;
  final double weight; // trọng số xác suất

  const EventOutcome({
    required this.titleKey,
    required this.descKey,
    this.imagePath,
    this.effects = const [],
    required this.weight,
  });
}

class EventChoice {
  final String labelKey;
  final String? costLabelKey; // hiển thị chi phí trên nút
  final List<EventOutcome>? outcomes; // null = placeholder (disabled)
  final bool isContinue; // bỏ qua sự kiện, tiếp tục đi luôn

  const EventChoice({
    required this.labelKey,
    this.costLabelKey,
    this.outcomes,
    this.isContinue = false,
  });

  /// Roll kết quả ngẫu nhiên theo weight. Trả về null nếu không có outcomes.
  EventOutcome? rollOutcome(Random rng) {
    if (outcomes == null || outcomes!.isEmpty) return null;
    final total = outcomes!.fold(0.0, (s, o) => s + o.weight);
    var roll = rng.nextDouble() * total;
    for (final o in outcomes!) {
      roll -= o.weight;
      if (roll <= 0) return o;
    }
    return outcomes!.last;
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Registry & Logic
// ────────────────────────────────────────────────────────────────────────────

class TravelEventSystem {
  TravelEventSystem._();

  static final Map<TravelEventType, TravelEvent> _registry = {
    TravelEventType.breathOfSilence: const TravelEvent(
      type:      TravelEventType.breathOfSilence,
      imagePath: 'assets/images/backgrounds/event/breath_of_silence.png',
      titleKey:  'travelEventBreathOfSilence',
      descKey:   'travelEventBreathOfSilenceDesc',
      choices: [
        // 1. Dập tắt lồng đèn
        EventChoice(
          labelKey: 'choiceBreathLanternOff',
          outcomes: [
            EventOutcome(
              titleKey:  'outcomeBreathLanternSuccessTitle',
              descKey:   'outcomeBreathLanternSuccessDesc',
              imagePath: 'assets/images/backgrounds/event/outcome_lantern_success.png',
              effects: [
                OutcomeEffect(OutcomeEffectType.gainLantern, 15),
                OutcomeEffect(OutcomeEffectType.gainStamina, 10),
              ],
              weight: 50,
            ),
            EventOutcome(
              titleKey:  'outcomeBreathLanternPanicTitle',
              descKey:   'outcomeBreathLanternPanicDesc',
              imagePath: 'assets/images/backgrounds/event/outcome_lantern_panic.png',
              effects: [
                OutcomeEffect(OutcomeEffectType.loseSanity, 10),
              ],
              weight: 35,
            ),
            EventOutcome(
              titleKey:  'outcomeBreathLanternAmbushTitle',
              descKey:   'outcomeBreathLanternAmbushDesc',
              imagePath: 'assets/images/backgrounds/event/outcome_lantern_ambush.png',
              effects: [
                OutcomeEffect(OutcomeEffectType.triggerCombat, 0),
              ],
              weight: 15,
            ),
          ],
        ),
        // 2–4. Placeholder (sẽ thêm sau)
        EventChoice(labelKey: 'choiceBreathSleep', outcomes: [
          EventOutcome(
            titleKey:  'outcomeBreathSleepPeacefulTitle',
            descKey:   'outcomeBreathSleepPeacefulDesc',
            imagePath: 'assets/images/backgrounds/event/outcome_sleep_peaceful.png',
            effects: [
              OutcomeEffect(OutcomeEffectType.gainStamina, 20),
              OutcomeEffect(OutcomeEffectType.gainSanity, 15),
            ],
            weight: 45,
          ),
          EventOutcome(
            titleKey:  'outcomeBreathSleepParasitesTitle',
            descKey:   'outcomeBreathSleepParasitesDesc',
            imagePath: 'assets/images/backgrounds/event/outcome_sleep_parasites.png',
            effects: [
              OutcomeEffect(OutcomeEffectType.gainStamina, 10),
              OutcomeEffect(OutcomeEffectType.applyPoison, 3),
            ],
            weight: 35,
          ),
          EventOutcome(
            titleKey:  'outcomeBreathSleepProphecyTitle',
            descKey:   'outcomeBreathSleepProphecyDesc',
            imagePath: 'assets/images/backgrounds/event/outcome_sleep_prophecy.png',
            effects: [
              OutcomeEffect(OutcomeEffectType.loseSanity, 15),
              OutcomeEffect(OutcomeEffectType.gainRandomEpicMaterial, 1),
            ],
            weight: 20,
          ),
        ]),
        EventChoice(labelKey: 'choiceBreathSearch', costLabelKey: 'choiceBreathSearchCost', outcomes: [
          EventOutcome(
            titleKey:  'outcomeBreathScavengeSuccessTitle',
            descKey:   'outcomeBreathScavengeSuccessDesc',
            imagePath: 'assets/images/backgrounds/event/outcome_scavenge_success.png',
            effects: [
              OutcomeEffect(OutcomeEffectType.loseStamina, 3),
              OutcomeEffect(OutcomeEffectType.gainRandomMaterials, 3),
            ],
            weight: 50,
          ),
          EventOutcome(
            titleKey:  'outcomeBreathScavengeDespairTitle',
            descKey:   'outcomeBreathScavengeDespairDesc',
            imagePath: 'assets/images/backgrounds/event/outcome_scavenge_despair.png',
            effects: [
              OutcomeEffect(OutcomeEffectType.loseStamina, 3),
              OutcomeEffect(OutcomeEffectType.loseSanity, 5),
            ],
            weight: 30,
          ),
          EventOutcome(
            titleKey:  'outcomeBreathScavengeTrapTitle',
            descKey:   'outcomeBreathScavengeTrapDesc',
            imagePath: 'assets/images/backgrounds/event/outcome_scavenge_trap.png',
            effects: [
              OutcomeEffect(OutcomeEffectType.loseStamina, 3),
              OutcomeEffect(OutcomeEffectType.loseHp, 15),
              OutcomeEffect(OutcomeEffectType.applyBleeding, 0),
            ],
            weight: 20,
          ),
        ]),
        EventChoice(labelKey: 'choiceBreathPray', outcomes: [
          EventOutcome(
            titleKey:  'outcomeBreathPraySolaceTitle',
            descKey:   'outcomeBreathPraySolaceDesc',
            imagePath: 'assets/images/backgrounds/event/outcome_pray_solace.png',
            effects: [
              OutcomeEffect(OutcomeEffectType.gainFullSanity, 0),
            ],
            weight: 60,
          ),
          EventOutcome(
            titleKey:  'outcomeBreathPrayDespairTitle',
            descKey:   'outcomeBreathPrayDespairDesc',
            imagePath: 'assets/images/backgrounds/event/outcome_pray_despair.png',
            effects: [
              OutcomeEffect(OutcomeEffectType.loseSanity, 20),
            ],
            weight: 30,
          ),
          EventOutcome(
            titleKey:  'outcomeBreathPrayDarkgodTitle',
            descKey:   'outcomeBreathPrayDarkgodDesc',
            imagePath: 'assets/images/backgrounds/event/outcome_pray_darkgod.png',
            effects: [
              OutcomeEffect(OutcomeEffectType.applyBloodlust, 3),
              OutcomeEffect(OutcomeEffectType.loseMaxHp, 5),
            ],
            weight: 10,
          ),
        ]),
        // 5. Tiếp tục đi
        EventChoice(labelKey: 'choiceBreathContinue', isContinue: true),
      ],
    ),
    TravelEventType.shatteredCarriage: const TravelEvent(
      type:      TravelEventType.shatteredCarriage,
      imagePath: 'assets/images/backgrounds/event/shattered_carriage.png',
      titleKey:  'travelEventShatteredCarriage',
      descKey:   'travelEventShatteredCarriageDesc',
    ),
    TravelEventType.hangedMan: const TravelEvent(
      type:      TravelEventType.hangedMan,
      imagePath: 'assets/images/backgrounds/event/hanged_man.png',
      titleKey:  'travelEventHangedMan',
      descKey:   'travelEventHangedManDesc',
    ),
    TravelEventType.blackBloodRain: const TravelEvent(
      type:      TravelEventType.blackBloodRain,
      imagePath: 'assets/images/backgrounds/event/black_blood_rain.png',
      titleKey:  'travelEventBlackBloodRain',
      descKey:   'travelEventBlackBloodRainDesc',
    ),
    TravelEventType.criesInThicket: const TravelEvent(
      type:      TravelEventType.criesInThicket,
      imagePath: 'assets/images/backgrounds/event/cries_in_thicket.png',
      titleKey:  'travelEventCriesInThicket',
      descKey:   'travelEventCriesInThicketDesc',
    ),
    TravelEventType.feralTerritory: const TravelEvent(
      type:      TravelEventType.feralTerritory,
      imagePath: 'assets/images/backgrounds/event/feral_territory.png',
      titleKey:  'travelEventFeralTerritory',
      descKey:   'travelEventFeralTerritoryDesc',
    ),
    TravelEventType.wanderingAmbush: const TravelEvent(
      type:      TravelEventType.wanderingAmbush,
      imagePath: 'assets/images/backgrounds/event/wandering_ambush.png',
      titleKey:  'travelEventWanderingAmbush',
      descKey:   'travelEventWanderingAmbushDesc',
    ),
    TravelEventType.facelessGoddess: const TravelEvent(
      type:      TravelEventType.facelessGoddess,
      imagePath: 'assets/images/backgrounds/event/faceless_goddess.png',
      titleKey:  'travelEventFacelessGoddess',
      descKey:   'travelEventFacelessGoddessDesc',
    ),
    TravelEventType.madmanChessboard: const TravelEvent(
      type:      TravelEventType.madmanChessboard,
      imagePath: 'assets/images/backgrounds/event/madman_chessboard.png',
      titleKey:  'travelEventMadmanChessboard',
      descKey:   'travelEventMadmanChessboardDesc',
    ),
    TravelEventType.wanderingSmuggler: const TravelEvent(
      type:      TravelEventType.wanderingSmuggler,
      imagePath: 'assets/images/backgrounds/event/wandering_smuggler.png',
      titleKey:  'travelEventWanderingSmuggler',
      descKey:   'travelEventWanderingSmugglerDesc',
    ),
    TravelEventType.theConfessor: const TravelEvent(
      type:      TravelEventType.theConfessor,
      imagePath: 'assets/images/backgrounds/event/the_confessor.png',
      titleKey:  'travelEventTheConfessor',
      descKey:   'travelEventTheConfessorDesc',
    ),
    TravelEventType.fogAnomaly: const TravelEvent(
      type:      TravelEventType.fogAnomaly,
      imagePath: 'assets/images/backgrounds/event/fog_anomaly.png',
      titleKey:  'travelEventFogAnomaly',
      descKey:   'travelEventFogAnomalyDesc',
    ),
  };

  /// Trả về [TravelEvent] tương ứng với [type].
  static TravelEvent forType(TravelEventType type) => _registry[type]!;

  /// Roll sự kiện ngẫu nhiên theo bảng xác suất.
  ///
  /// | Sự kiện            | Tỷ lệ |
  /// |--------------------|-------|
  /// | breathOfSilence    | 36.0% |
  /// | shatteredCarriage  | 10.5% |
  /// | hangedMan          | 10.5% |
  /// | blackBloodRain     |  7.5% |
  /// | criesInThicket     |  7.5% |
  /// | feralTerritory     |  7.5% |
  /// | wanderingAmbush    |  7.5% |
  /// | facelessGoddess    |  2.5% |
  /// | madmanChessboard   |  2.5% |
  /// | wanderingSmuggler  |  2.5% |
  /// | theConfessor       |  2.5% |
  /// | fogAnomaly         |  3.0% |
  static TravelEventType rollEvent(Random rng) {
    final double roll = rng.nextDouble();
    double c = 0;
    c += 0.360; if (roll < c) return TravelEventType.breathOfSilence;
    c += 0.105; if (roll < c) return TravelEventType.shatteredCarriage;
    c += 0.105; if (roll < c) return TravelEventType.hangedMan;
    c += 0.075; if (roll < c) return TravelEventType.blackBloodRain;
    c += 0.075; if (roll < c) return TravelEventType.criesInThicket;
    c += 0.075; if (roll < c) return TravelEventType.feralTerritory;
    c += 0.075; if (roll < c) return TravelEventType.wanderingAmbush;
    c += 0.025; if (roll < c) return TravelEventType.facelessGoddess;
    c += 0.025; if (roll < c) return TravelEventType.madmanChessboard;
    c += 0.025; if (roll < c) return TravelEventType.wanderingSmuggler;
    c += 0.025; if (roll < c) return TravelEventType.theConfessor;
    return TravelEventType.fogAnomaly; // 3.0%
  }
}
