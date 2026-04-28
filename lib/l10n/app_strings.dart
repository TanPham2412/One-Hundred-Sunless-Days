/// Bộ truy cập chuỗi ngôn ngữ đơn giản.
/// Nội dung được giữ đồng bộ với các file ARB trong cùng thư mục.
/// Thay thế bằng flutter_localizations + gen-l10n khi sẵn sàng.
class AppStrings {
  AppStrings._();

  /// Ngôn ngữ hiện tại. Mặc định tiếng Anh.
  static String _locale = 'en';

  /// Ngôn ngữ hiện đang dùng.
  static String get locale => _locale;

  /// Đặt ngôn ngữ. Cần gọi setState trên widget gốc sau khi đổi.
  static void setLocale(String locale) => _locale = locale;

  /// Lấy chuỗi theo [key]. Fallback: EN rồi VI nếu không tìm thấy.
  static String get(String key) {
    final Map<String, String>? map = switch (_locale) {
      'vi' => _vi,
      'en' => _en,
      'zh' => _zh,
      'zh_TW' => _zhTW,
      'ko' => _ko,
      'ja' => _ja,
      _ => _en,
    };
    return map?[key] ?? _en[key] ?? _vi[key] ?? key;
  }

  // ── Tiếng Việt ────────────────────────────────────────────────────────────
  static const Map<String, String> _vi = {
    // UI chung
    'hintTapToContinue': '[ nhấn để tiếp tục ]',
    'hintNextSegment': '▼',
    'hintContinue': '[ tiếp tục ]',

    // Màn hình cốt truyện – Ngày 1
    'storyDay1Title': '[ NGÀY 1: TỈNH GIẤC NƠI MỘ TRỐNG ]',
    'storyDay1Seg1':
        'Mùi khét của xương tủy cháy xộc thẳng vào mũi đánh thức bạn. Mí mắt nặng trĩu.',
    'storyDay1Seg2':
        'Xung quanh là những bức tường đá đổ nát của một thánh đường đã bị lãng quên. '
            'Ánh sáng duy nhất đến từ một đống lửa nhỏ đang thoi thóp ở trung tâm.',
    'storyDay1Seg3':
        'Bên kia đống lửa, một bóng người gầy gò, khoác áo choàng rách rưới đang ngồi '
            'bất động. Hốc mắt lão trống rỗng, sâu hoắm.',
    // Cảnh 2 – Kẻ Mù trao đồ
    'storyDay1WatcherName': 'Kẻ Mù',
    'storyDay1WatcherLine1':
        '"Lại một kẻ nữa bị vực thẳm nhổ ra... Ngươi không nhớ mình là ai, phải không? '
            'Đừng cố. Ở Kỷ Nguyên Tro Tàn này, tên tuổi là thứ vô dụng nhất."',
    'storyDay1WatcherAction':
        'Lão ho khùng khục, ném về phía bạn một vật phẩm lạnh lẽo. '
            'Đó là một chiếc lồng đèn làm từ xương sọ chưa hoàn thiện.',
    'storyDay1WatcherLine2':
        '"Cầm lấy Lồng Đèn Xương. Lửa là sự sống, là ký ức, là sức mạnh. '
            'Đi nhặt nhạnh bất cứ thứ gì có thể đốt được để duy trì ngọn lửa này. '
            'Và nhớ lấy... bóng tối ngoài kia đang đói."',
    'storyDay1SystemNotice':
        '• Bạn đã nhận được [Lồng Đèn Xương].\n'
            '• Mở khóa khu vực: Nhà Thờ Bỏ Hoang (Safehouse).\n'
            '• Mở khóa chức năng: Tập Luyện & Khám Phá.',

    // Màn hình start
    'startBtnNew': 'BẮT ĐẦU MỚI',
    'startBtnContinue': 'TIẾP TỤC',
    'startBtnSettings': 'CÀI ĐẶT',
    'startBtnQuit': 'THOÁT',

    // Màn hình đền thờ – hub chính
    'templeTitle': 'NHÀ THỜ BỎ HOANG',
    'templeStatHp': 'MÁU',
    'templeStatStamina': 'THỂ LỰC',
    'templeStatHunger': 'ĐỘ NO',
    'templeActionExplore': 'KHÁM PHÁ',
    'templeActionTrain': 'TẬP LUYỆN',
    'templeActionRest': 'NGHỈ NGƠI',

    // Bảng cài đặt
    'settingsTitle': 'CÀI ĐẶT',
    'settingsLanguage': 'NGÔN NGỮ',
    'settingsSave': 'LƯU GAME',
    'settingsNewGame': 'BẮT ĐẦU LẠI',
    'settingsSound': 'ÂM THANH',
    'settingsSoundOn': 'BẬT',
    'settingsSoundOff': 'TẮT',
    'settingsQuit': 'THOÁT',
    'close': 'ĐÓNG',

    // Bảng nhân vật
    'charPanelTitle': 'NHÂN VẬT',
    'charTabEquip': 'TRANG BỊ',
    'charTabBag': 'BALO',
    'charTabStats': 'CHỈ SỐ',
    'charTabSkills': 'KỸ NĂNG',
    'charEquipWeapon': 'VŨ KHÍ',
    'charEquipArmor': 'GIÁP',
    'charEquipAccessory': 'PHỤ KIỆN',
    'charEquipEmpty': '[ trống ]',
    'charSkillsEmpty': 'Chưa học được\nkỹ năng nào.',

    // Nhóm chỉ số
    'charGroupVitals': 'SINH TỒN',
    'charGroupPrimary': 'CHỈ SỐ CƠ BẢN',
    'charGroupHidden': 'THUỘC TÍNH ẨN',
    'charGroupNotes': 'CHÚ THÍCH',

    // Tên chỉ số
    'charStatStr': 'Sức Mạnh',
    'charStatVit': 'Bền Bỉ',
    'charStatAgi': 'Nhanh Nhẹn',
    'charStatWill': 'Ý Chí',
    'charStatHumanity': 'Nhân Tính',
    'charStatSanity': 'Độ Tỉnh Táo',
    'charStatRealm': 'Cảnh Giới',
    'charStatEmbers': 'Tro Tàn',

    // Giá trị Cảnh Giới
    'charRealmRank1': 'Cấp 1 – Kẻ Nhặt Rác',
    'charRealmRank2': 'Cấp 2 – Chiến Binh Tro Tàn',
    'charRealmRank3': 'Cấp 3 – Kẻ Sót Lại',

    // Mô tả chỉ số (Nhóm Sinh Tồn)
    'charDescHp':
        'Nếu về 0, nhân vật chết và hồi sinh tại Đống Lửa.\nMáu tối đa tăng theo chỉ số Bền Bỉ.',
    'charDescStamina':
        'Dùng cho mọi hành động (Tập luyện, Chiến đấu, Khám phá).\nHồi phục khi Nghỉ ngơi. Tối đa tăng theo chỉ số Ý Chí.',
    'charDescHunger':
        'Giảm dần mỗi khi qua một ngày mới.\nNếu về 0, Máu sẽ bị trừ dần cho đến khi chết hoặc được ăn.',

    // Mô tả chỉ số (Nhóm Cơ Bản)
    'charDescStr': 'Ảnh hưởng đến lực đánh vật lý.\nCao hơn = sát thương mỗi đòn lớn hơn.',
    'charDescVit': 'Ảnh hưởng đến lượng Máu tối đa.\nMỗi điểm tăng thêm +10 Máu tối đa.',
    'charDescAgi': 'Ảnh hưởng đến tốc độ ra đòn và tỉ lệ né tránh.\nCao hơn = ra đòn trước và bỏ chạy dễ hơn.',
    'charDescWill': 'Ảnh hưởng đến Thể Lực tối đa và kháng hiệu ứng xấu.\nMỗi điểm tăng thêm +5 Thể Lực tối đa.',

    // Mô tả chỉ số (Nhóm Ẩn)
    'charDescHumanity':
        'Quyết định bạn là "Người" hay "Quỷ" trong mắt của người khác.\nẢnh hưởng đến nhiều nhiệm vụ và kết thúc cốt truyện.',
    'charDescSanity':
        'Giảm khi gặp sự kiện kinh dị hoặc ở trong bóng tối quá lâu.\nDưới ngưỡng 30, các ảo giác sẽ xuất hiện khi chiến đấu.',
    'charDescRealm':
        'Phản ánh mức độ giác ngộ và sức mạnh tiềm ẩn của bạn.\nCảnh Giới cao hơn mở khóa những đường lối và bí mật riêng.',
  };

  // ── Tiếng Anh ─────────────────────────────────────────────────────────────
  static const Map<String, String> _en = {
    // UI chung
    'hintTapToContinue': '[ tap to continue ]',
    'hintNextSegment': '▼',
    'hintContinue': '[ continue ]',

    // Story screen – Day 1
    'storyDay1Title': '[ DAY 1: AWAKENING IN AN EMPTY TOMB ]',
    'storyDay1Seg1':
        'The stench of burning marrow shoots straight into your nostrils, jolting you awake. '
            'Your eyelids are heavy as stone.',
    'storyDay1Seg2':
        'Around you stand the crumbling walls of a long-forgotten cathedral. '
            'The only light comes from a small, dying fire at its center.',
    'storyDay1Seg3':
        'Across the flames, a gaunt figure in a tattered cloak sits motionless. '
            'Its eye sockets are hollow and impossibly deep.',
    // Scene 2 – The Watcher handover
    'storyDay1WatcherName': 'The Watcher',
    'storyDay1WatcherLine1':
        '"Another soul spat out by the abyss... You don\'t remember who you are, do you? '
            'Don\'t try. In the Age of Embers, names are the most useless thing there is."',
    'storyDay1WatcherAction':
        'The old figure lets out a rattling cough and tosses something cold in your direction. '
            'It is a lantern fashioned from an unfinished skull.',
    'storyDay1WatcherLine2':
        '"Take the Bone Lantern. Fire is life, memory, and strength. '
            'Scavenge anything that can burn to keep this flame alive. '
            'And remember... the dark outside is hungry."',
    'storyDay1SystemNotice':
        '• You received [Bone Lantern].\n'
            '• Location unlocked: Abandoned Cathedral (Safehouse).\n'
            '• Functions unlocked: Training & Exploration.',

    // Start screen
    'startBtnNew': 'NEW GAME',
    'startBtnContinue': 'CONTINUE',
    'startBtnSettings': 'SETTINGS',
    'startBtnQuit': 'QUIT',

    // Temple screen – main hub
    'templeTitle': 'ABANDONED CATHEDRAL',
    'templeStatHp': 'HP',
    'templeStatStamina': 'Stamina',
    'templeStatHunger': 'Hunger',
    'templeActionExplore': 'EXPLORE',
    'templeActionTrain': 'TRAIN',
    'templeActionRest': 'REST',

    // Settings panel
    'settingsTitle': 'SETTINGS',
    'settingsLanguage': 'LANGUAGE',
    'settingsSave': 'SAVE GAME',
    'settingsNewGame': 'NEW GAME',
    'settingsSound': 'SOUND',
    'settingsSoundOn': 'ON',
    'settingsSoundOff': 'OFF',
    'settingsQuit': 'QUIT',
    'close': 'CLOSE',

    // Character panel
    'charPanelTitle': 'CHARACTER',
    'charTabEquip': 'EQUIP',
    'charTabBag': 'BAG',
    'charTabStats': 'STATS',
    'charTabSkills': 'SKILLS',
    'charEquipWeapon': 'WEAPON',
    'charEquipArmor': 'ARMOR',
    'charEquipAccessory': 'ACCESSORY',
    'charEquipEmpty': '[ empty ]',
    'charSkillsEmpty': 'No skills\nlearned yet.',

    // Stat groups
    'charGroupVitals': 'VITALS',
    'charGroupPrimary': 'PRIMARY STATS',
    'charGroupHidden': 'HIDDEN STATS',
    'charGroupNotes': 'NOTES',

    // Stat names
    'charStatStr': 'Strength',
    'charStatVit': 'Vitality',
    'charStatAgi': 'Agility',
    'charStatWill': 'Willpower',
    'charStatHumanity': 'Humanity',
    'charStatSanity': 'Sanity',
    'charStatRealm': 'Realm',
    'charStatEmbers': 'Embers',

    // Realm rank names
    'charRealmRank1': 'Rank 1 – Scavenger',
    'charRealmRank2': 'Rank 2 – Ember Knight',
    'charRealmRank3': 'Rank 3 – The Remnant',

    // Stat descriptions (Vitals)
    'charDescHp':
        'Reaches 0: die and respawn at the Bonfire.\nMax HP increases with Vitality.',
    'charDescStamina':
        'Used for all actions (Train, Fight, Explore).\nRecovers on Rest. Max increases with Willpower.',
    'charDescHunger':
        'Decreases every day.\nAt 0, HP drains until you eat or die.',

    // Stat descriptions (Primary)
    'charDescStr': 'Affects physical attack damage.\nHigher = bigger hits.',
    'charDescVit': 'Affects max HP.\nEvery point adds +10 max HP.',
    'charDescAgi':
        'Affects attack speed and dodge chance.\nHigher = act first and flee more easily.',
    'charDescWill':
        'Affects max Stamina and resistance to debuffs.\nEvery point adds +5 max Stamina.',

    // Stat descriptions (Hidden)
    'charDescHumanity':
        'Determines whether you are seen as \'Human\' or \'Demon\'.\nAffects quests and story endings.',
    'charDescSanity':
        'Decreases from horror events or prolonged darkness.\nBelow 30, hallucinations appear in combat.',
    'charDescRealm':
        'Reflects your level of awakening and latent power.\nHigher Realm unlocks unique paths and secrets.',
  };

  // ── Tiếng Trung giản thể ────────────────────────────────────────────────────────────
  static const Map<String, String> _zh = {
    'hintTapToContinue': '[ 点击继续 ]',
    'hintNextSegment': '▼',
    'hintContinue': '[ 继续 ]',
    'startBtnNew': '新游戏',
    'startBtnContinue': '继续',
    'startBtnSettings': '设置',
    'startBtnQuit': '退出',
    'templeTitle': '荒废大教堂',
    'templeStatHp': '血量',
    'templeStatStamina': '体力',
    'templeStatHunger': '饥饿',
    'templeActionExplore': '探索',
    'templeActionTrain': '训练',
    'templeActionRest': '休息',
    'settingsTitle': '设置',
    'settingsLanguage': '语言',
    'settingsSave': '保存游戏',
    'settingsNewGame': '新游戏',
    'settingsSound': '音效',
    'settingsSoundOn': '开',
    'settingsSoundOff': '关',
    'settingsQuit': '退出',
    'close': '关闭',
    'charPanelTitle': '角色',
    'charTabEquip': '装备',
    'charTabBag': '背包',
    'charTabStats': '属性',
    'charTabSkills': '技能',
    'charEquipWeapon': '武器',
    'charEquipArmor': '护甲',
    'charEquipAccessory': '饰品',
    'charEquipEmpty': '[ 空 ]',
    'charSkillsEmpty': '尚未学到\n任何技能。',
    'charGroupVitals': '生命属性',
    'charGroupPrimary': '基础属性',
    'charGroupHidden': '隐藏属性',
    'charGroupNotes': '备注',
    'charStatStr': '力量',
    'charStatVit': '体质',
    'charStatAgi': '敏捷',
    'charStatWill': '意志',
    'charStatHumanity': '人性',
    'charStatSanity': '理智',
    'charStatRealm': '境界',
    'charStatEmbers': '余烬',
    'charRealmRank1': '第1级 – 拾垓者',
    'charRealmRank2': '第2级 – 烬火战士',
    'charRealmRank3': '第3级 – 幸存者',
  };

  // ── Tiếng Trung phồn thể ────────────────────────────────────────────────────────────
  static const Map<String, String> _zhTW = {
    'hintTapToContinue': '[ 點擊繼續 ]',
    'hintNextSegment': '▼',
    'hintContinue': '[ 繼續 ]',
    'startBtnNew': '新遊戲',
    'startBtnContinue': '繼續',
    'startBtnSettings': '設定',
    'startBtnQuit': '退出',
    'templeTitle': '荒廢大教堂',
    'templeStatHp': '血量',
    'templeStatStamina': '體力',
    'templeStatHunger': '飢餓',
    'templeActionExplore': '探索',
    'templeActionTrain': '訓練',
    'templeActionRest': '休息',
    'settingsTitle': '設定',
    'settingsLanguage': '語言',
    'settingsSave': '儲存遊戲',
    'settingsNewGame': '新遊戲',
    'settingsSound': '音效',
    'settingsSoundOn': '開',
    'settingsSoundOff': '關',
    'settingsQuit': '退出',
    'close': '關閉',
    'charPanelTitle': '角色',
    'charTabEquip': '裝備',
    'charTabBag': '背包',
    'charTabStats': '屬性',
    'charTabSkills': '技能',
    'charEquipWeapon': '武器',
    'charEquipArmor': '護甲',
    'charEquipAccessory': '飾品',
    'charEquipEmpty': '[ 空 ]',
    'charSkillsEmpty': '尚未習得\n任何技能。',
    'charGroupVitals': '生命屬性',
    'charGroupPrimary': '基礎屬性',
    'charGroupHidden': '隱藏屬性',
    'charGroupNotes': '備註',
    'charStatStr': '力量',
    'charStatVit': '體質',
    'charStatAgi': '敏捷',
    'charStatWill': '意志',
    'charStatHumanity': '人性',
    'charStatSanity': '理智',
    'charStatRealm': '境界',
    'charStatEmbers': '餘燼',
    'charRealmRank1': '第1級 – 抾垓者',
    'charRealmRank2': '第2級 – 燼火戰士',
    'charRealmRank3': '第3級 – 幸存者',
  };

  // ── Tiếng Hàn ────────────────────────────────────────────────────────────────────────
  static const Map<String, String> _ko = {
    'hintTapToContinue': '[ 탭 하여 계속 ]',
    'hintNextSegment': '▼',
    'hintContinue': '[ 계속 ]',
    'startBtnNew': '새 게임',
    'startBtnContinue': '계속하기',
    'startBtnSettings': '설정',
    'startBtnQuit': '종료',
    'templeTitle': '폐허 성당',
    'templeStatHp': 'HP',
    'templeStatStamina': '체력',
    'templeStatHunger': '허기',
    'templeActionExplore': '탐색',
    'templeActionTrain': '훈련',
    'templeActionRest': '휴식',
    'settingsTitle': '설정',
    'settingsLanguage': '언어',
    'settingsSave': '저장',
    'settingsNewGame': '새 게임',
    'settingsSound': '사운드',
    'settingsSoundOn': '켜기',
    'settingsSoundOff': '끄기',
    'settingsQuit': '종료',
    'close': '닫기',
    'charPanelTitle': '캐릭터',
    'charTabEquip': '장비',
    'charTabBag': '가방',
    'charTabStats': '능력치',
    'charTabSkills': '스킬',
    'charEquipWeapon': '무기',
    'charEquipArmor': '방어구',
    'charEquipAccessory': '장신구',
    'charEquipEmpty': '[ 비어있음 ]',
    'charSkillsEmpty': '배운 스킬이\n없습니다.',
    'charGroupVitals': '생존 수치',
    'charGroupPrimary': '기본 능력치',
    'charGroupHidden': '숨겨진 스탯',
    'charGroupNotes': '안내',
    'charStatStr': '힙',
    'charStatVit': '체력',
    'charStatAgi': '민첽',
    'charStatWill': '의지력',
    'charStatHumanity': '인성',
    'charStatSanity': '정신력',
    'charStatRealm': '경지',
    'charStatEmbers': '쟿불',
    'charRealmRank1': '1레벨 – 약탈자',
    'charRealmRank2': '2레벨 – 쟿불 전사',
    'charRealmRank3': '3레벨 – 생존자',
  };

  // ── Tiếng Nhật ────────────────────────────────────────────────────────────────────────
  static const Map<String, String> _ja = {
    'hintTapToContinue': '[ タップして続く ]',
    'hintNextSegment': '▼',
    'hintContinue': '[ 続く ]',
    'startBtnNew': '新規ゲーム',
    'startBtnContinue': '続ける',
    'startBtnSettings': '設定',
    'startBtnQuit': '終了',
    'templeTitle': '廃墙の大聖堂',
    'templeStatHp': 'HP',
    'templeStatStamina': '体力',
    'templeStatHunger': '空腹',
    'templeActionExplore': '探索',
    'templeActionTrain': '訓練',
    'templeActionRest': '休息',
    'settingsTitle': '設定',
    'settingsLanguage': '言語',
    'settingsSave': 'セーブ',
    'settingsNewGame': '新規ゲーム',
    'settingsSound': 'サウンド',
    'settingsSoundOn': 'オン',
    'settingsSoundOff': 'オフ',
    'settingsQuit': '終了',
    'close': '閉じる',
    'charPanelTitle': 'キャラクター',
    'charTabEquip': '装備',
    'charTabBag': 'バッグ',
    'charTabStats': 'ステータス',
    'charTabSkills': 'スキル',
    'charEquipWeapon': '武器',
    'charEquipArmor': '防具',
    'charEquipAccessory': 'アクセサリ',
    'charEquipEmpty': '[ 空欄 ]',
    'charSkillsEmpty': 'まだスキルを\n習得していない。',
    'charGroupVitals': '生命属性',
    'charGroupPrimary': '基本ステータス',
    'charGroupHidden': '隠れた属性',
    'charGroupNotes': '注釈',
    'charStatStr': '力',
    'charStatVit': '体質',
    'charStatAgi': '敏捷',
    'charStatWill': '意志',
    'charStatHumanity': '人間性',
    'charStatSanity': '精神力',
    'charStatRealm': '境地',
    'charStatEmbers': '残り火',
    'charRealmRank1': '第1階 – 拾い集め屋',
    'charRealmRank2': '第2階 – 灰火の戦士',
    'charRealmRank3': '第3階 – 生き残り',
  };
}
