// ────────────────────────────────────────────────────────────────────────────
// Dữ liệu Quái Vật
// ────────────────────────────────────────────────────────────────────────────

/// Thông tin một loại quái vật gặp trong chiến đấu.
class Monster {
  /// Key l10n cho tên chính (tiếng Việt in hoa).
  final String nameKey;

  /// Key l10n cho phụ đề / tên khoa học (tiếng Anh nhỏ hơn).
  final String subtitleKey;

  /// Key l10n cho mô tả lần đầu gặp.
  final String descKey;

  /// Đường dẫn asset ảnh pixel-art của quái vật.
  final String imagePath;

  const Monster({
    required this.nameKey,
    required this.subtitleKey,
    required this.descKey,
    required this.imagePath,
  });
}

// ────────────────────────────────────────────────────────────────────────────
// Danh sách quái vật
// ────────────────────────────────────────────────────────────────────────────

abstract class MonsterRegistry {
  MonsterRegistry._();

  /// Xuất hiện từ sự kiện [Lời Cầu Cứu Ngoài Cửa] – nhánh tấn công (25%).
  static const Monster mimickingCorpse = Monster(
    nameKey:     'monsterMimickingCorpseName',
    subtitleKey: 'monsterMimickingCorpseSubtitle',
    descKey:     'monsterMimickingCorpseDesc',
    imagePath:   'assets/images/monsters/mimicking_corpse.png',
  );

  /// Pool quái vật xuất hiện ngẫu nhiên trong sự kiện ban đêm.
  static const Monster stitchedEyeHound = Monster(
    nameKey:     'monsterStitchedEyeHoundName',
    subtitleKey: 'monsterStitchedEyeHoundSubtitle',
    descKey:     'monsterStitchedEyeHoundDesc',
    imagePath:   'assets/images/monsters/stitched_eye_hound.png',
  );

  static const Monster corruptedCleric = Monster(
    nameKey:     'monsterCorruptedClericName',
    subtitleKey: 'monsterCorruptedClericSubtitle',
    descKey:     'monsterCorruptedClericDesc',
    imagePath:   'assets/images/monsters/corrupted_cleric.png',
  );

  static const Monster lightDevouringSludge = Monster(
    nameKey:     'monsterLightDevouringSludgeName',
    subtitleKey: 'monsterLightDevouringSludgeSubtitle',
    descKey:     'monsterLightDevouringSludgeDesc',
    imagePath:   'assets/images/monsters/light_devouring_sludge.png',
  );

  static const Monster watcherGuise = Monster(
    nameKey:     'monsterWatcherGuiseName',
    subtitleKey: 'monsterWatcherGuiseSubtitle',
    descKey:     'monsterWatcherGuiseDesc',
    imagePath:   'assets/images/monsters/watcher_guise.png',
  );
}
