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

    // HUD ngày + đèn
    'hudDay': 'NGÀY',
    'hudLantern': 'LỒNG ĐÈN',

    // Màn hình kết quả nghỉ ngơi
    'restTitleDay': 'NGÀY %d',
    'restStaminaFull': 'ĐẦY ĐỦ',
    'restStaminaHalf': 'Nửa (Bị TẤN CÔNG)',
    'restStaminaHalfFog': 'Nửa (SƯƠNG ĐỘC)',
    'restStarvation': 'CHẾT ĐÓI',
    'restFoodStolen': 'Bị ĐÁNH CẮP',
    'restEmberThiefStole': 'Chuột Than cắp',
    'restTapToContinue': '[ Chạm để tiếp tục ]',
    'restTapToCombat': '[ CHUẨN BỊ CHIẾN ĐẤU → ]',
    'restBlindWhisperBonus': 'Khám Phá ngày mai',

    // Sự kiện đêm
    'nightEventDeepSleepTitle': 'GIẤC NGỦ SÂU',
    'nightEventDeepSleepDesc': 'Đêm trôi qua tĩnh lặng. Không có gì cản trở quá trình hồi phục của bạn.',
    'nightEventNightmareTitle': 'ÁC MỘNG TỪ VỰC THẲM',
    'nightEventNightmareDesc': 'Lửa chập chờn sinh ra những cái bóng quái dị. Bạn mơ thấy mình đang nhai ngấu nghiến thi thể đồng loại. Bạn tỉnh dậy, mồ hôi ướt đẫm, lồng ngực đánh thình thịch.',
    'nightEventBlindWhisperTitle': 'TIẾNG THÌ THẦM CỦA KẺ MÙ',
    'nightEventBlindWhisperDesc': 'Trong cơn mơ màng, hơi ấm của đống lửa làm bạn an lòng. Bạn nghe thấy Kẻ Mù lẩm bẩm về một nơi cất giấu đồ đạc trước khi sương mù ập tới.',
    'nightEventEmberThiefTitle': 'KẺ TRỘM TRO TÀN',
    'nightEventEmberThiefDesc': 'Có tiếng sột soạt ở góc tường. Một con Chuột Than đã lẻn vào lúc bạn không để ý.',
    'nightEventNightRaidTitle': 'ĐỘT KÍCH BẤT NGỜ',
    'nightEventNightRaidDesc': 'Bóng tối che khuất tầm nhìn. Bạn bị đánh thức bởi tiếng đổ vỡ rợn người. Cánh cửa nhà thờ bị xé toạc, một con quái vật lao vào!',

    'nightEventSadMemoryTitle': 'HỒI ỨC U BUỒN',
    'nightEventSadMemoryDesc': 'Trong màn đêm tĩnh lặng, bạn mơ thấy một đoạn ký ức đẹp đẽ của những ngày thế giới chưa lụi tàn. Bạn choàng tỉnh, khóe mắt cay cay. Nỗi buồn vô tận ập đến khi nhận ra thực tại tàn khốc, nhưng sâu thẳm bên trong, bạn thấy mình vẫn còn là một con người.',
    'nightEventOutsidePleaTitle': 'LỜI CẦU CỨU NGOÀI CỬA',
    'nightEventOutsidePleaDesc': 'Giữa đêm, bạn nghe thấy tiếng gõ cửa yếu ớt và giọng nói thều thào vang lên: "Làm ơn... cho tôi một chút lửa... tôi lạnh quá...". Bạn nằm im không dám đáp lời, chờ đợi cho đến khi âm thanh đó chìm hẳn vào hư vô.',
    'nightEventToxicFogTitle': 'CƠN BÃO SƯƠNG ĐỘC',
    'nightEventToxicFogDesc': 'Đêm nay, gió rít từng hồi qua những khe hở của Nhà Thờ. Sương mù đặc quánh và độc hại luồn lách vào tận nơi bạn nằm. Không khí trở nên đặc nghẹt, bóp nghẹt buồng phổi khiến bạn ho sặc sụa suốt đêm.',
    'nightEventVaultSongTitle': 'KHÚC HÁT TỪ RƯỜNG CỘT',
    'nightEventVaultSongDesc': 'Từ trên mái vòm tối tăm của Nhà Thờ, một giai điệu xa xăm, u sầu như tiếng hát ru cất lên. Âm thanh đó mơn trớn tâm trí, khiến bạn rã rời buông xuôi và chìm vào một giấc ngủ sâu đến mức quên cả việc tiếp lửa cho lồng đèn.',
    'nightEventAshFlareTitle': 'SỰ SOI RỌI CỦA TRO TÀN',
    'nightEventAshFlareDesc': 'Đống tro tàn trong Lồng Đèn Xương đột nhiên bùng lên một ngọn lửa vàng rực rỡ một cách bất thường. Hơi ấm của nó xua tan mọi hàn khí, thắp sáng cả một vùng không gian và mang lại cảm giác bình yên đến lạ kỳ.',
    'nightEventInvisibleWatcherTitle': 'KẺ DÒM NGÓ VÔ HÌNH',
    'nightEventInvisibleWatcherDesc': 'Bạn có một giấc ngủ bình thường, nhưng khi tỉnh dậy, bạn phát hiện ra vô số những vết cào xước mới toanh quanh chỗ mình nằm, cùng với những dấu chân dính đầy bùn đen. Một thứ gì đó đã đứng nhìn bạn ngủ suốt cả đêm mà không hề tấn công.',

    // Kết quả nghỉ ngơi – sự kiện mới
    'restSadMemoryHumanity': 'Nhân Tính',
    'restSadMemoryStamina': 'Nỗi Buồn (Thể Lực sáng mai)',
    'restOutsidePleaLoot': 'Lục lọi xác',
    'restOutsidePleaHumanity': 'Tội Lỗi Cắn Rứt (Nhân Tính)',
    'restToxicFogStatus': '[Tức Ngực] +5 TL / hành động',
    'restVaultSongExtraHp': 'Ngủ quá say (HP thêm)',
    'restVaultSongExtraLantern': 'Bỏ quên ngọn lửa (Đèn)',
    'restAshFlareLantern': 'Lửa Vàng Kỳ Diệu (Đèn)',
    'restAshFlareSanity': 'Bình Yên (Tỉnh Táo hồi đầy)',
    'restAshFlareStatus': '[Được Che Chở] ngày hôm nay',
    'restInvisibleWatcherStatus': '[Bị Rình Rập] 80% gặp quái',

    // Màn hình chiến đấu (placeholder)
    'combatTitle': 'CHIẾN ĐẤU',
    'combatGroggyWarning': '[Ngái Ngủ] – Bạn bị đánh thức đột ngột!\nMất lượt đánh đầu tiên. Thể Lực chỉ hồi được 50%.',
    'combatComingSoon': '[ Hệ thống chiến đấu đang được xây dựng ]',
    'combatFlee': '[ RÚT LUI ]',

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

    // Phòng thủ – chỉ số tổng hợp
    'charStatDef': 'Phòng Thủ',
    'charDescDef':
        'Giảm sát thương nhận vào trong chiến đấu.\nKHÔNG thể nâng qua điểm chỉ số thông thường.\nChỉ tăng thông qua: Trang Bị, Kỹ Năng hoặc Cảnh Giới cao hơn.',

    // Mô tả chỉ số (Nhóm Ẩn)
    'charDescHumanity':
        'Quyết định bạn là "Người" hay "Quỷ" trong mắt của người khác.\nẢnh hưởng đến nhiều nhiệm vụ và kết thúc cốt truyện.',
    'charDescSanity':
        'Giảm khi gặp sự kiện kinh dị hoặc ở trong bóng tối quá lâu.\nDưới ngưỡng 30, các ảo giác sẽ xuất hiện khi chiến đấu.',
    'charDescRealm':
        'Phản ánh mức độ giác ngộ và sức mạnh tiềm ẩn của bạn.\nCảnh Giới cao hơn mở khóa những đường lối và bí mật riêng.',

    // ── Vật phẩm – Tên ──────────────────────────────────────────────────────
    'item_rotten_meat_name': 'Thịt Dai Mục Nát',
    'item_mold_bread_name': 'Bánh Mì Mốc Tím',
    'item_soldier_ration_name': 'Lương Khô Tử Trận',
    'item_sorrow_soup_name': 'Súp Rễ Cây U Sầu',
    'item_sacrificial_meat_name': 'Thịt Nướng Tế Thần',
    'item_dirty_bandage_name': 'Băng Gạc Bẩn',
    'item_ember_blood_name': 'Chiết Xuất Huyết Tinh',
    'item_weeping_resin_name': 'Nhựa Cây Sầu Muộn',
    'item_fallen_tears_name': 'Nước Mắt Thánh Nữ',
    'item_flesh_parasite_name': 'Ký Sinh Trùng Khâu Nhục',
    'item_soothing_herb_name': 'Cỏ Khô An Thần',
    'item_polluted_water_name': 'Nước Suối Ô Nhiễm',
    'item_skull_moonshine_name': 'Rượu Đầu Lâu',
    'item_lost_incense_name': 'Tro Xông Hương',
    'item_ash_vial_name': 'Lọ Tro Mù',
    'item_bleeding_pitch_name': 'Dầu Hắc Ín Rỉ Máu',
    'item_madman_blood_name': 'Máu Loãng Kẻ Điên',
    'item_shattered_amulet_name': 'Bùa Hộ Mệnh Vỡ Nát',
    'item_ember_core_name': 'Lõi Lửa Cơ Bản',
    'item_wrathful_heart_name': 'Trái Tim Oán Hận',

    // ── Vật phẩm – Mô tả ────────────────────────────────────────────────────
    'item_rotten_meat_desc':
        'Chẳng ai biết nó là thịt người hay thú, nhưng mùi ôi thiu của nó đủ để dạ dày bạn ngừng kêu réo.',
    'item_mold_bread_desc':
        'Lớp nấm mốc tím phát sáng nhẹ trong bóng tối. Nhai nó mang lại cảm giác lạo xạo và những ảo giác rùng rợn.',
    'item_soldier_ration_desc':
        'Bánh quy quân đội được cạy ra từ lớp áo giáp rỉ sét của một cái xác. Khô khốc và nhạt nhẽo, nhưng cực kỳ an toàn.',
    'item_sorrow_soup_desc':
        'Rễ cây mọc trên những nấm mồ tập thể. Nước súp đen kịt, nuốt xuống mang theo âm vang tiếng khóc than của người chết.',
    'item_sacrificial_meat_desc':
        'Lấy từ các bàn thờ tà thần vô danh. Mùi thịt thơm lừng một cách bất thường, có vị ngòn ngọt khiến kẻ ăn phải rùng mình.',
    'item_dirty_bandage_desc':
        'Những dải vải xé từ quần áo xác chết, vẫn còn bám mùi gỉ sắt và đất ẩm.',
    'item_ember_blood_desc':
        'Dung dịch đỏ thẫm luyện từ tro tàn và máu quái vật. Nó ép cơ thể liền sẹo bằng cách biến đổi một phần nội tạng của bạn.',
    'item_weeping_resin_desc':
        'Nhựa đặc quánh bóp ra từ những thân cây khô héo. Tác dụng chậm nhưng chữa lành một cách êm ái.',
    'item_fallen_tears_desc':
        'Giọt sương trong chiếc lọ nứt. Nó xoa dịu nỗi đau thể xác, nhưng mang lại sự thanh thản u buồn khiến bạn chỉ muốn gục xuống buông xuôi.',
    'item_flesh_parasite_desc':
        'Một con nhộng rỉ máu. Phải nuốt sống để nó nhả tơ khâu lại nội tạng từ bên trong. Giải pháp tuyệt vọng nhất.',
    'item_soothing_herb_desc':
        'Nhai loại cỏ này làm tê liệt hệ thần kinh, giúp bạn tạm thời phớt lờ những tiếng thì thầm trong bóng tối.',
    'item_polluted_water_desc':
        'Nước đục ngầu có vị đắng nồng của lưu huỳnh, bóp nghẹt cổ họng nhưng đánh thức cơ bắp.',
    'item_skull_moonshine_desc':
        'Loại rượu ủ cực mạnh, thứ chất lỏng của những kẻ không còn gì để mất trước trận tử chiến.',
    'item_lost_incense_desc':
        'Mùi hương u ám gợi nhớ về những ngày yên bình, một liều an thần mang màu sắc hoài niệm.',
    'item_ash_vial_desc':
        'Thủy tinh vỡ nát giải phóng đám mây tro đậm đặc, che mắt những sinh vật khát máu.',
    'item_bleeding_pitch_desc':
        'Dầu nhờn nhụa bắt lửa cực mạnh, đủ nóng để làm tan chảy cả lưỡi kiếm của chính bạn.',
    'item_madman_blood_desc':
        'Mùi thối rữa nồng nặc che giấu hơi người, nhưng sự điên loạn của chủ nhân cũ sẽ từ từ ngấm vào da thịt bạn.',
    'item_shattered_amulet_desc':
        'Mảnh kim loại khắc hình đôi mắt nhắm nghiền, kỷ vật cuối cùng của một hiệp sĩ vô danh đã ngã xuống.',
    'item_ember_core_desc':
        'Viên đá nóng rẫy chứa đựng tinh túy của lửa, bứt ra từ lồng ngực của quái thú tàn bạo.',
    'item_wrathful_heart_desc':
        'Trái tim vẫn còn đập thình thịch. Khi ném vào lồng đèn, nó phát ra thứ ánh sáng đỏ quạch rợn người.',

    // Lồng Đèn Xương
    'item_bone_lantern_name': 'Lồng Đèn Xương',
    'item_bone_lantern_desc':
        'Một chiếc đèn kỳ dị ghép từ xương người. Nó không thể bị phá hủy, không thể bị bỏ rơi. Cứ cháy, mãi cháy – cho đến khi anh không còn dầu để đốt.',
    'itemRarityUnique': 'ĐỘC NHẤT',

    // ── HUD Lồng Đèn & Hoảng Loạn ─────────────────────────────────────────
    'lanternPanic': 'Hoảng loạn – độ tỉnh táo đang giảm',
    'lanternPanelTitle': 'TIẾP NHIÊN LIỆU',
    'lanternBrightnessLabel': 'Độ Sáng',
    'lanternRefuelCost': 'Tro Tàn',
    'lanternFull': '[ Đèn đang cháy đủ đầy ]',
    'lanternNoEmbers': '[ Không đủ Tro Tàn ]',

    // Mức độ sáng
    'lanternBright': 'Giấc ngủ an bình',
    'lanternDim': 'Giấc ngủ chập chờn',
    'lanternDark': 'Bóng đè',
    'lanternOut': 'Đêm kinh hoàng',
    'bagConsumables': 'Vật Phẩm Tiêu Hao',
    'bagEquipment': 'Trang Bị & Vật Liệu',
    'bagEmpty': '[ Trống ]',
    'bagBack': 'Quay lại',
    'itemUse': 'SỬ DỤNG',
    'itemOnlyInCombat': '* Chỉ dùng được trong chiến đấu.',
    'itemStatAlreadyFull': '[ Đã đầy – không có tác dụng ]',
    'itemEffectHealFull': 'Hồi 100% Máu',
    'itemEffectDrainStamina': 'Thể Lực về 0',
    'itemFlagNoTurnCost': 'Không tốn lượt trong chiến đấu',
    'itemFlagPassive': 'Bị động – tự kích hoạt',
    'itemFlagCombatOnly': 'Chỉ dùng trong chiến đấu',
    'itemFlagBlockLethal': 'Chặn 1 đòn chí mạng, giữ lại 1 Máu',
    'itemFlagNoNightRaid': 'Không bị tập kích ban đêm (khi dùng trước khi Ngủ)',
    'groupFood': 'Lương Thực',
    'groupMedical': 'Y Tế',
    'groupMental': 'Tinh Thần',
    'groupCombat': 'Tác Chiến',
    'groupCore': 'Năng Lượng',
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

    // HUD day + lantern
    'hudDay': 'DAY',
    'hudLantern': 'LANTERN',

    // Rest result screen
    'restTitleDay': 'DAY %d',
    'restStaminaFull': 'FULLY RESTORED',
    'restStaminaHalf': 'HALF (NIGHT RAID)',
    'restStaminaHalfFog': 'HALF (TOXIC FOG)',
    'restStarvation': 'STARVATION',
    'restFoodStolen': 'STOLEN',
    'restEmberThiefStole': 'Ash Rat stole',
    'restTapToContinue': '[ Tap to continue ]',
    'restTapToCombat': '[ PREPARE TO FIGHT → ]',
    'restBlindWhisperBonus': 'Tomorrow\'s Explore',

    // Night events
    'nightEventDeepSleepTitle': 'DEEP SLEEP',
    'nightEventDeepSleepDesc': 'The night passes in silence. Nothing hinders your recovery.',
    'nightEventNightmareTitle': 'NIGHTMARE FROM THE ABYSS',
    'nightEventNightmareDesc': 'The flickering flame conjures grotesque shadows. You dream of devouring the flesh of your kin. You wake drenched in sweat, heart hammering.',
    'nightEventBlindWhisperTitle': 'WHISPER OF THE BLIND MAN',
    'nightEventBlindWhisperDesc': 'In the depths of sleep, the fire\'s warmth soothes you. You hear the Blind Man murmuring of a hidden cache before the fog rolls in.',
    'nightEventEmberThiefTitle': 'THE EMBER THIEF',
    'nightEventEmberThiefDesc': 'A scratching sound in the corner. An Ash Rat has crept in while you weren\'t watching.',
    'nightEventNightRaidTitle': 'SUDDEN NIGHT RAID',
    'nightEventNightRaidDesc': 'Darkness blinds you. A horrifying crash wrenches you awake. The cathedral doors are ripped open — a monster lunges in!',

    'nightEventSadMemoryTitle': 'MELANCHOLY MEMORY',
    'nightEventSadMemoryDesc': 'In the still darkness, you dream of a beautiful memory from before the world ended. You wake with tears at the corner of your eyes. Endless sorrow floods in — but deep within, you feel you are still human.',
    'nightEventOutsidePleaTitle': 'A PLEA FROM OUTSIDE',
    'nightEventOutsidePleaDesc': 'In the dead of night, a faint knock at the door. A thin voice whispers: "Please... just a little fire... I\'m so cold...". You lie still, not daring to answer, until the sound fades into nothing.',
    'nightEventToxicFogTitle': 'TOXIC FOG STORM',
    'nightEventToxicFogDesc': 'Wind howls through every crack in the Cathedral. Dense, poisonous fog seeps into where you sleep. The air grows thick and suffocating, making you cough violently through the entire night.',
    'nightEventVaultSongTitle': 'SONG FROM THE RAFTERS',
    'nightEventVaultSongDesc': 'From the dark vault above, a distant, mournful melody rises like a lullaby. The sound coaxes your mind to surrender, pulling you into a deep sleep so complete you forget to tend the lantern\'s flame.',
    'nightEventAshFlareTitle': 'ASHEN ILLUMINATION',
    'nightEventAshFlareDesc': 'The embers within the Bone Lantern suddenly blaze with an unnaturally brilliant golden flame. Its warmth banishes all cold, lights the space around you, and brings an uncanny sense of peace.',
    'nightEventInvisibleWatcherTitle': 'THE UNSEEN WATCHER',
    'nightEventInvisibleWatcherDesc': 'You sleep without incident — but upon waking, you find fresh scratch marks all around where you lay, and footprints caked in black mud. Something stood watching you sleep all night, and chose not to attack.',

    // Rest results – new events
    'restSadMemoryHumanity': 'Humanity',
    'restSadMemoryStamina': 'Lingering Grief (Stamina next morn)',
    'restOutsidePleaLoot': 'Looted the body',
    'restOutsidePleaHumanity': 'Guilt (Humanity)',
    'restToxicFogStatus': '[Chest Tightness] +5 ST / action',
    'restVaultSongExtraHp': 'Deep Slumber (extra HP)',
    'restVaultSongExtraLantern': 'Unattended Flame (Lantern)',
    'restAshFlareLantern': 'Golden Flame Miracle (Lantern)',
    'restAshFlareSanity': 'Serenity (Sanity fully restored)',
    'restAshFlareStatus': '[Sheltered] today',
    'restInvisibleWatcherStatus': '[Being Stalked] 80% monster rate',

    // Combat screen (placeholder)
    'combatTitle': 'COMBAT',
    'combatGroggyWarning': '[Groggy] — You were woken violently!\nYou lose the first turn. Stamina recovered only 50%.',
    'combatComingSoon': '[ Combat system is under construction ]',
    'combatFlee': '[ FLEE ]',

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

    // Defense – composite stat
    'charStatDef': 'Defense',
    'charDescDef':
        'Reduces damage received in combat.\nCANNOT be raised via normal stat points.\nOnly increases through: Equipment, Skills, or a higher Realm.',

    // Stat descriptions (Hidden)
    'charDescHumanity':
        'Determines whether you are seen as \'Human\' or \'Demon\'.\nAffects quests and story endings.',
    'charDescSanity':
        'Decreases from horror events or prolonged darkness.\nBelow 30, hallucinations appear in combat.',
    'charDescRealm':
        'Reflects your level of awakening and latent power.\nHigher Realm unlocks unique paths and secrets.',

    // ── Items – Names ────────────────────────────────────────────────────────
    'item_rotten_meat_name': 'Rotten Tough Meat',
    'item_mold_bread_name': 'Purple Mold Bread',
    'item_soldier_ration_name': "Dead Soldier's Ration",
    'item_sorrow_soup_name': 'Sorrow-root Soup',
    'item_sacrificial_meat_name': 'Sacrificial Charred Meat',
    'item_dirty_bandage_name': 'Dirty Bandage',
    'item_ember_blood_name': 'Ember Blood Extract',
    'item_weeping_resin_name': 'Weeping Tree Resin',
    'item_fallen_tears_name': 'Tears of the Fallen',
    'item_flesh_parasite_name': 'Flesh-weaving Parasite',
    'item_soothing_herb_name': 'Dried Soothing Herb',
    'item_polluted_water_name': 'Polluted Spring Water',
    'item_skull_moonshine_name': 'Skull Moonshine',
    'item_lost_incense_name': 'Incense of the Lost',
    'item_ash_vial_name': 'Blinding Ash Vial',
    'item_bleeding_pitch_name': 'Bleeding Pitch',
    'item_madman_blood_name': "Madman's Thin Blood",
    'item_shattered_amulet_name': 'Shattered Amulet',
    'item_ember_core_name': 'Basic Ember Core',
    'item_wrathful_heart_name': 'Wrathful Heart',

    // ── Items – Descriptions ─────────────────────────────────────────────────
    'item_rotten_meat_desc':
        "No one knows if it came from man or beast, but its putrid stench is enough to silence your growling stomach.",
    'item_mold_bread_desc':
        'The purple mold glows faintly in the dark. Chewing it brings a gritty sensation and horrifying hallucinations.',
    'item_soldier_ration_desc':
        "Military biscuits pried from the rusted armor of a corpse. Dry and tasteless, but remarkably safe.",
    'item_sorrow_soup_desc':
        "Roots grown from mass graves. The pitch-black broth carries the echoes of the dead's lament.",
    'item_sacrificial_meat_desc':
        'Taken from altars of nameless dark gods. Unnaturally fragrant, its sweet taste makes the eater shudder.',
    'item_dirty_bandage_desc':
        "Strips of cloth torn from a corpse's garments, still reeking of rust and damp earth.",
    'item_ember_blood_desc':
        'A dark-crimson solution forged from embers and monster blood. It forces your body to mend by transforming part of your organs.',
    'item_weeping_resin_desc':
        'Thick sap squeezed from withered trunks. Slow to work, but heals with a quiet gentleness.',
    'item_fallen_tears_desc':
        'A single dewdrop in a cracked vial. It soothes all physical pain, but brings a melancholic peace that makes you want to simply lie down and let go.',
    'item_flesh_parasite_desc':
        'A blood-weeping larva. Must be swallowed alive so it can spin silk to suture your organs from within. The most desperate of measures.',
    'item_soothing_herb_desc':
        'Chewing this grass numbs your nervous system, letting you briefly ignore the whispers in the dark.',
    'item_polluted_water_desc':
        'Murky water with a bitter sulfur bite that constricts the throat but awakens the muscles.',
    'item_skull_moonshine_desc':
        "An intensely brewed liquor — the drink of those with nothing left to lose before their final battle.",
    'item_lost_incense_desc':
        'A somber fragrance that evokes days of peace — a nostalgic sedative with melancholic hues.',
    'item_ash_vial_desc':
        'Shattered glass releases a dense cloud of ash, blinding the blood-hungry creatures.',
    'item_bleeding_pitch_desc':
        'Viscous oil that ignites violently — hot enough to melt even your own blade.',
    'item_madman_blood_desc':
        "A foul stench masks your human scent, but the madness of its former owner will slowly seep into your flesh.",
    'item_shattered_amulet_desc':
        'A metal shard engraved with closed eyes — the last keepsake of a nameless knight who fell in darkness.',
    'item_ember_core_desc':
        'A scorching stone containing the essence of fire, torn from the chest of a brutal beast.',
    'item_wrathful_heart_desc':
        'The heart still beats. When cast into the lantern, it radiates a blood-red, unsettling light.',

    // Bone Lantern
    'item_bone_lantern_name': 'Bone Lantern',
    'item_bone_lantern_desc':
        'A strange lantern assembled from human bones. It cannot be destroyed, cannot be discarded. It burns on — until you have no more fuel to give.',
    'itemRarityUnique': 'UNIQUE',

    // ── Lantern HUD & Panic ─────────────────────────────────────────────
    'lanternPanic': 'Panic – sanity draining',
    'lanternPanelTitle': 'REFUEL',
    'lanternBrightnessLabel': 'Brightness',
    'lanternRefuelCost': 'Embers',
    'lanternFull': '[ Lantern is already full ]',
    'lanternNoEmbers': '[ Not enough Embers ]',

    // Brightness levels
    'lanternBright': 'Peaceful sleep',
    'lanternDim': 'Restless sleep',
    'lanternDark': 'Sleep paralysis',
    'lanternOut': 'Night terror',
    'bagConsumables': 'Consumables',
    'bagEquipment': 'Equipment & Materials',
    'bagEmpty': '[ Empty ]',
    'bagBack': 'Back',
    'itemUse': 'USE',
    'itemOnlyInCombat': '* Can only be used in combat.',
    'itemStatAlreadyFull': '[ Already full – no effect ]',
    'itemEffectHealFull': 'Restore 100% HP',
    'itemEffectDrainStamina': 'Stamina drops to 0',
    'itemFlagNoTurnCost': 'No turn cost in combat',
    'itemFlagPassive': 'Passive – auto-activates',
    'itemFlagCombatOnly': 'Combat use only',
    'itemFlagBlockLethal': 'Block 1 lethal hit, survive at 1 HP',
    'itemFlagNoNightRaid': 'No night raid (use before Sleep)',
    'groupFood': 'Food',
    'groupMedical': 'Medical',
    'groupMental': 'Mental',
    'groupCombat': 'Combat',
    'groupCore': 'Core',
  };
}
