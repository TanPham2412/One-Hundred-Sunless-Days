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

    // Màn hình Khám Phá
    'exploreSearchQuestion': 'Bạn muốn tìm kiếm gì?',
    'exploreCatFood':        'Lương Thực',
    'exploreCatMedical':     'Y Tế',
    'exploreCatMental':      'Tinh Thần',
    'exploreCatCombat':      'Tác Chiến',
    'exploreCatEquipment':   'Trang Bị',
    'exploreAreaQuestion':   'Bạn muốn khám phá khu vực nào?',
    'exploreAreaQuarry':     'Hẻm Núi Đào Bới',
    'exploreAreaForest':     'Rừng Thú Hoang',
    'exploreAreaBattlefield':'Chiến Trường Vùi Lấp',
    'exploreBack':           '← QUAY LẠI',

    // Di chuyển đến khu vực
    'exploreTravelStep':           'Lượt di chuyển',
    'exploreTravelChance':         'Xác suất đến nơi',
    'exploreTravelCostPer':        'Chi phí mỗi lượt',
    'exploreTravelCostStamina':    'Thể Lực',
    'exploreTravelCostLantern':    'Độ Sáng',
    'exploreTravelCurrentStamina': 'Thể Lực hiện tại',
    'exploreTravelCurrentLantern': 'Độ Sáng hiện tại',
    'exploreTravelAdvance':        'TIẾN LÊN',
    'exploreTravelNoStamina':      'Không đủ Thể Lực để tiếp tục.',
    'exploreTravelArrived':        'ĐÃ ĐẾN NƠI!',
    'exploreTravelExplore':        'KHÁM PHÁ KHU VỰC',
    'exploreTravelReturnHub':      '← QUAY VỀ ĐỀN THỜ BỎ HOANG',

    // Sự kiện di chuyển
    'travelEventContinue':              'TIẾP TỤC',
    'travelEventBreathOfSilence':       'Khoảng Không Tĩnh Lặng',
    'travelEventBreathOfSilenceDesc':   'Tiếng gió rít qua những tán lá khô bỗng nhiên ngừng bặt. Sương mù loãng ra một chút, hé lộ những vệt nắng nhạt nhòa le lói chiếu xuống thảm rêu xanh thẫm. Bầu không gian yên ắng lạ thường, một sự bình yên hiếm hoi nhưng lại khiến sự cảnh giác trong bạn dâng cao đến tột độ.',
    'travelEventShatteredCarriage':     'Cỗ Xe Ngựa Gãy Nát',
    'travelEventShatteredCarriageDesc': 'Một cỗ xe gỗ nằm lật nhào bên vệ đường mòn, lớp bạt phủ đã bị xé toạc nham nhở. Xung quanh là những thùng hàng vỡ vụn và vết cào xé sâu hoắm trên thân gỗ. Một mùi tanh nồng của rỉ sét, hòa lẫn với thứ mùi ngòn ngọt của thịt thối bốc ra từ khoang tối đen như mực.',
    'travelEventHangedMan':             'Kẻ Treo Cổ Giữa Rừng',
    'travelEventHangedManDesc':         'Lủng lẳng trên cành sồi già cỗi vặn vẹo là một thi thể mặc giáp da đẫm máu. Dây thừng siết chặt lấy cổ họng đã tím tái. Bầy quạ đen kêu quang quác, kiên nhẫn mổ từng mảng thịt thối rữa tơi tả rớt xuống nền đất nhão nhoét dưới chân bạn.',
    'travelEventBlackBloodRain':        'Cơn Mưa Máu Đen',
    'travelEventBlackBloodRainDesc':    'Bầu trời sương đục đột ngột tối sầm. Những giọt chất lỏng đặc quánh, hôi thối mùi tử khí bắt đầu trút xuống rào rào. Từng giọt đen ngòm nện xuống mặt đất, xèo xèo ăn mòn cả ánh sáng leo lét của chiếc lồng đèn xương mà bạn đang nắm chặt.',
    'travelEventCriesInThicket':        'Tiếng Khóc Trong Bụi Rậm',
    'travelEventCriesInThicketDesc':    'Từ sâu trong lùm gai rậm rạp mà tầm nhìn không thể xuyên thấu, tiếng nức nở thê lương của một đứa trẻ vang lên ngắt quãng. Âm thanh ấy sắc lẹm, cào xé vào phần người còn sót lại trong tâm trí, mồi chài những kẻ tò mò bước chân vào cõi chết.',
    'travelEventFeralTerritory':        'Lãnh Địa Dã Thú',
    'travelEventFeralTerritoryDesc':    'Không khí đặc quánh mùi bùn, mùi lông lá ẩm ướt và máu tươi. Trong làn sương đục ngầu phía trước, những cặp mắt vàng khè rực sáng. Tiếng gầm gừ gằn từng nhịp phát ra từ những cái mõm đầy dãi, cảnh cáo bạn đã bước nhầm vào bàn tiệc tàn bạo của chúng.',
    'travelEventWanderingAmbush':       'Kẻ Đi Săn Lang Thang',
    'travelEventWanderingAmbushDesc':   'Làn sương mù đặc quánh bị xé toạc bởi một luồng sát khí lạnh buốt. Một bóng đen quái dị với hình thù vặn vẹo lao vụt ra khỏi màn đêm. Tiếng xương khớp kêu răng rắc và tiếng móng vuốt cọ xát vào nhau vang lên chát chúa ngay trước khi kẻ đi săn vồ lấy nhịp thở của bạn.',
    'travelEventFacelessGoddess':       'Tượng Nữ Thần Vô Diện',
    'travelEventFacelessGoddessDesc':   'Một bức tượng đá xanh tạc hình nữ thần đứng trơ trọi giữa tàn tích, nhưng khuôn mặt đã bị ai đó đập nát không thương tiếc. Đôi bàn tay nứt nẻ của bức tượng chìa ra một chiếc đĩa cân bằng đồng trống rỗng. Dường như thứ thế lực này đòi hỏi không phải là lời cầu nguyện, mà là máu thịt để trao đổi.',
    'travelEventMadmanChessboard':      'Bàn Cờ Của Kẻ Điên',
    'travelEventMadmanChessboardDesc':  'Ngay giữa lối đi tăm tối là một bàn cờ mục nát. Lại gần, bạn nhận ra các quân cờ được gọt đẽo một cách bệnh hoạn từ xương ngón tay và những hộp sọ chim tí hon. Một ván cờ tàn đang dang dở, tĩnh lặng chờ đợi một kẻ điên rồ khác liều mạng đi nước cờ tiếp theo.',
    'travelEventWanderingSmuggler':     'Thương Nhân Lưu Vong',
    'travelEventWanderingSmugglerDesc': 'Dưới ánh nến xanh lè leo lét, một bóng người còng rạp xuống vì sức nặng của chiếc balo khổng lồ kêu lóc cóc. Kẻ trùm áo choàng vá víu nhếch mép cười, để lộ hàm răng đen kịt. Hắn không màng đến những đồng tiền vàng vô giá trị của thế giới cũ; thứ hắn thèm khát là máu thịt, sắt vụn và những bí mật điên rồ mà bạn đang giấu kín trong tuyệt vọng.',
    'travelEventTheConfessor':          'Tu Sĩ Xưng Tội',
    'travelEventTheConfessorDesc':      'Quỳ rạp giữa vũng bùn lầy lội là một bóng người run rẩy, hai tay bị quấn chặt bởi những đoạn xích sắt hoen rỉ đầy gai nhọn. Đó là một tu sĩ với bộ lễ phục đã rách tươm. Giọng hắn khản đặc và cuồng loạn, van nài được nghe những tội lỗi đẫm máu của bạn để dâng lên một đấng siêu nhiên nào đó đã từ lâu nhắm mắt làm ngơ.',
    'travelEventFogAnomaly':            'Biến Cố Sương Mù',
    'travelEventFogAnomalyDesc':        'Bất chợt, thực tại xung quanh bạn bị bẻ cong một cách tàn bạo. Sương mù không còn trôi lơ lửng mà vặn vẹo cuộn trào như những bó cơ khổng lồ đang co giật. Cảm giác nghẹt thở ập đến khi những quy luật vật lý của thế giới này sụp đổ hoàn toàn, nhường chỗ cho sự hiện diện của một cơn ác mộng nguyên thủy vĩ đại vừa vươn vòi chạm vào tâm trí bạn.',

    // Lựa chọn sự kiện – Khoảng Không Tĩnh Lặng
    'choiceBreathLanternOff':           'Dập tắt lồng đèn để tiết kiệm dầu',
    'choiceBreathSleep':                'Ngả lưng ngủ chợp mắt',
    'choiceBreathSearch':               'Lục lọi quanh gốc cây cổ thụ',
    'choiceBreathSearchCost':           '−3 Thể Lực',
    'choiceBreathPray':                 'Cầu nguyện dưới vệt nắng',
    'choiceBreathContinue':             'Tiếp tục đi',

    // Kết quả lựa chọn – Dập tắt lồng đèn
    'outcomeBreathLanternSuccessTitle': '[Thành Công]',
    'outcomeBreathLanternSuccessDesc':  'Vệt nắng kéo dài đủ lâu. Bạn tiết kiệm được 15% Dầu lồng đèn. Cơ thể hấp thụ hơi ấm tự nhiên, dần dần hồi lại sức lực.',
    'outcomeBreathLanternPanicTitle':   '[Mây Mù Che Khuất]',
    'outcomeBreathLanternPanicDesc':    'Bạn vừa tắt lửa, bầu trời đột ngột xám xịt. Vệt nắng biến mất, bóng tối vùng vẫy lao đến. Bạn hoảng loạn bật lại lồng đèn. Không tiết kiệm được gì, cơn đau tim ngắn ngủi bào mòn tỉnh táo của bạn.',
    'outcomeBreathLanternAmbushTitle':  '[Kẻ Thù Sợ Ánh Sáng]',
    'outcomeBreathLanternAmbushDesc':   'Ngọn lửa vừa tắt, một con quái vật nhút nhát vốn đang nấp trong bóng râm lân cận lập tức lao ra vồ lấy bạn. Chuẩn bị chiến đấu — kẻ địch sẽ ra đòn trước.',

    // Nhãn hiệu ứng
    'effectLabelLantern':               'Độ Sáng',
    'effectLabelStamina':               'Thể Lực',
    'effectLabelSanity':                'Tỉnh Táo',
    'effectLabelCombat':                '⚔ Chiến Đấu! Kẻ địch ra đòn trước.',
    'effectLabelHp':                    'Máu',
    'effectLabelMaxHp':                 'Max Máu (vĩnh viễn)',
    'effectLabelPoison':                '☠ Nhiễm Độc',
    'effectLabelBleeding':              '🩸 Chảy Máu',
    'effectLabelBloodlust':             '🔥 Cuồng Huyết',
    'effectLabelMaterial':              'Nguyên Liệu Ngẫu Nhiên',
    'effectLabelEpicMaterial':          '✦ Nguyên Liệu Hiếm Ngẫu Nhiên',
    'effectLabelSanityFull':            '✦ Hồi Đầy Tỉnh Táo',
    'effectLabelTurns':                 'lượt',

    // Sự kiện breathOfSilence – Kết quả Lựa Chọn 2: Nghỉ Ngơi
    'outcomeBreathSleepPeacefulTitle':  'GIẤC NGỦ BÌNH YÊN',
    'outcomeBreathSleepPeacefulDesc':   'Bạn gối đầu lên tay, nhắm mắt giữa vùng đất chết. Không có gì quấy rầy bạn. Khi tỉnh dậy, cơ thể và tâm trí đều nhẹ nhàng hơn.',
    'outcomeBreathSleepParasitesTitle': 'KÍ SINH MỘT ĐÊM',
    'outcomeBreathSleepParasitesDesc':  'Bạn ngủ được, nhưng khi tỉnh dậy, những vết ngứa rát nổi dọc cánh tay. Thứ gì đó đã dùng bạn làm vật chủ suốt đêm.',
    'outcomeBreathSleepProphecyTitle':  'LỜI TIÊN TRI TRONG MÊ',
    'outcomeBreathSleepProphecyDesc':   'Bạn chìm vào một giấc mơ kỳ lạ. Một giọng nói vô hình thì thầm về cái chết và sự tái sinh. Khi tỉnh dậy, bạn thấy trong lòng bàn tay mình một thứ quý giá không rõ nguồn gốc.',

    // Sự kiện breathOfSilence – Kết quả Lựa Chọn 3: Tìm Kiếm
    'outcomeBreathScavengeSuccessTitle': 'ĐÀO BỚI THÀNH CÔNG',
    'outcomeBreathScavengeSuccessDesc':  'Bạn bới lật đống đổ nát xung quanh và tìm thấy một số nguyên liệu hữu ích nằm lẫn trong bụi tro.',
    'outcomeBreathScavengeDespairTitle': 'TRẮNG TAY',
    'outcomeBreathScavengeDespairDesc':  'Bạn tìm kiếm mãi mà không thấy gì đáng giá. Chỉ có xương vụn và kỷ niệm người chết. Sự vô vọng bắt đầu gặm nhấm tâm trí bạn.',
    'outcomeBreathScavengeTrapTitle':    'BẪY ẨN',
    'outcomeBreathScavengeTrapDesc':     'Tay bạn kéo lên một thanh kim loại và "BỐC!" – Bẫy nổ kích hoạt. Máu chảy đỏ cả vạt áo.',

    // Sự kiện breathOfSilence – Kết quả Lựa Chọn 4: Cầu Nguyện
    'outcomeBreathPraySolaceTitle':      'AN ỦI TỪ THINH KHÔNG',
    'outcomeBreathPraySolaceDesc':       'Bạn quỳ gối và cầu nguyện trong im lặng. Không có ai nghe. Nhưng kỳ lạ thay, nỗi lo lắng tự tan biến. Đầu óc bạn trở nên trong sáng.',
    'outcomeBreathPrayDespairTitle':     'TRẢ LỜI CỦA THINH KHÔNG',
    'outcomeBreathPrayDespairDesc':      'Bạn cầu nguyện và chờ đợi. Không có gì xảy ra. Sự im lặng tuyệt đối xé nát tâm trí bạn hơn bất kỳ lời đáp nào.',
    'outcomeBreathPrayDarkgodTitle':     'ĐÁP LỜI CỦA CỔ THẦN',
    'outcomeBreathPrayDarkgodDesc':      'Điều gì đó đáp lại tiếng cầu nguyện của bạn – không phải Thần Sáng. Huyết quản bạn bốc nhiệt, cơn cuồng huyết đang ủ trong xương. Nhưng một phần máu thịt bạn đã trở thành lễ vật.',

    'hudDay': 'NGÀY',
    'hudLantern': 'LỒNG ĐÈN',

    // Màn hình kết quả nghỉ ngơi
    'restResultTitle': 'KẾT QUẢ NGHỈ NGƠI',
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
    'nightEventSuddenDeathDoorTitle': 'RANH GIỚI ĐỘT TỬ',
    'nightEventSuddenDeathDoorDesc': 'Bóng tối đặc quánh ngấm qua da thịt. Bạn tỉnh giấc trong giật mình, tim đập loạn, miệng khô khấc. Chỉ có đúng một nhịp đập yếu ớt mà tất cả cơ thể bạn vấn đề vào. Niềm kinh hoàng của đêm nay sẽ không dễ dàng buông tha bạn trong ngày mai.',

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

    // Màn hình chiến đấu (placeholder)
    'combatTitle': 'CHIẾN ĐẤU',
    'combatGroggyWarning': '[Ngái Ngủ] – Bạn bị đánh thức đột ngột!\nMất lượt đánh đầu tiên. Thể Lực chỉ hồi được 50%.',
    'combatComingSoon': '[ Hệ thống chiến đấu đang được xây dựng ]',
    'combatFlee': '[ RÚT LUI ]',
    'combatPrepFight': '[ CHIẾN ĐẤU ]',

    // Thông tin quái vật
    'monsterMimickingCorpseName':     'THI THỂ NHẠI TIẾNG',
    'monsterMimickingCorpseSubtitle': 'The Mimicking Corpse',
    'monsterMimickingCorpseDesc':
        'Khi cánh cửa gỗ vừa hé mở, thứ đứng bên ngoài không phải là một con người đang co ro. '
        'Lớp áo choàng rách rưới trượt xuống, để lộ một cái xác chết cóng. '
        'Cổ họng nó bị rạch toạc, nơi một cụm ký sinh trùng bằng rễ cây tà ác đang cắm chặt '
        'vào dây thanh quản để nhại lại tiếng người. '
        'Ngay khi thấy ánh sáng lồng đèn, cụm rễ đó bung ra thành những xúc tu sắc nhọn và lao thẳng vào bạn.',

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
    'charDescStr': 'Ảnh hưởng đến sát thương vật lý.',
    'charDescVit': 'Ảnh hưởng đến lượng Máu tối đa.',
    'charDescAgi': 'Ảnh hưởng đến tốc độ ra đòn và tỷ lệ né tránh.',
    'charDescWill': 'Ảnh hưởng đến Thể Lực tối đa và kháng hiệu ứng xấu.',

    // Phòng thủ – chỉ số tổng hợp
    'charStatDef': 'Phòng Thủ',
    'charDescDef':
        'Giảm sát thương nhận vào trong chiến đấu.\nTăng qua: Luyện tập Khuân Vác (+1/cấp), Trang Bị, Kỹ Năng.',

    // Tấn Công – chỉ số tổng hợp
    'charStatAttack': 'Tấn Công',
    'charDescAttack':
        'Tổng sức tấn công = Sức Mạnh + bonus Vũ Khí.\nTăng cấp Sức Mạnh hoặc trang bị vũ khí tốt hơn.',
    'charDescDefTotal':
        'Phòng Thủ cơ bản + bonus Áo Giáp.\nTăng cấp Thể Chất hoặc trang bị giáp tốt hơn.',

    // Mô tả chỉ số (Nhóm Ẩn)
    'charDescHumanity':
        'Quyết định bạn là "Người" hay "Quỷ" trong mắt của người khác.\nẢnh hưởng đến nhiều nhiệm vụ và kết thúc cốt truyện.',
    'charDescSanity':
        'Giảm khi gặp sự kiện kinh dị hoặc ở trong bóng tối quá lâu.\nDưới ngưỡng 30, các ảo giác sẽ xuất hiện khi chiến đấu.',
    'charDescRealm':
        'Phản ánh mức độ giác ngộ và sức mạnh tiềm ẩn của bạn.\nCảnh Giới cao hơn mở khóa những đường lối và bí mật riêng.',

    // ── Vật phẩm – Tên ──────────────────────────────────────────────────────

    // ── Vật phẩm – Mô tả ────────────────────────────────────────────────────

    // Lồng Đèn Xương
    'item_bone_lantern_name': 'Lồng Đèn Xương',
    'item_bone_lantern_desc':
        'Một chiếc đèn kỳ dị ghép từ xương người. Nó không thể bị phá hủy, không thể bị bỏ rơi. Cứ cháy, mãi cháy – cho đến khi anh không còn dầu để đốt.',
    // ── Vật liệu chế tạo ─────────────────────────────────────────────────

    // Tier 1 – Thường
    'item_rough_iron_scrap_name': 'Mảnh Sắt Thô',
    'item_rough_iron_scrap_desc':
        'Một vóc kim loại méo mó, xỉn màu. Bề mặt sần sùi chằng chịt những vết xước cạn và các cạnh viền thì mẻ răng cưa lởm chởm.',
    'item_rusty_nail_name': 'Đinh Sắt Gỉ',
    'item_rusty_nail_desc':
        'Một thanh kim loại thô kệch với phần đầu bị tán bẹt, xiêu vẹo. Xuyên suốt thân đinh là bề mặt rỗ nát, sần lên những mảng rỉ sét sẫm màu.',

    // Tier 2 – Ít Gặp
    'item_old_grindstone_name': 'Đá Mài Cũ',
    'item_old_grindstone_desc':
        'Một khối đá xám hình bầu dục thô ráp. Phần viền ngoài sứt mẻ nhiều chỗ, nhưng chính giữa lại mòn lõm hẳn xuống, bóng loáng và hằn rõ những vết xước mờ đan chéo nhau.',
    'item_broken_armor_piece_name': 'Mảnh Giáp Vỡ',
    'item_broken_armor_piece_desc':
        'Một phiến kim loại cong vênh, rách toạc ở mép. Trên bề mặt nhấp nhô còn bám lại vài chiếc đinh tán mòn vẹt và một vết cắt sâu hoắm vắt ngang.',

    // Tier 3 – Hiếm
    'item_iron_chains_name': 'Dây Xích Sắt',
    'item_iron_chains_desc':
        'Một đoạn xích ngắn gồm những mắt xích to bản, cục mịch móc nối vào nhau. Bề mặt đóng một lớp cặn dày, xỉn đen và đặc quánh cảm giác nặng nề.',
    'item_steel_ore_name': 'Quặng Thép',
    'item_steel_ore_desc':
        'Một khối vật chất góc cạnh, lởm chởm. Xuyên qua lớp đá bao bọc thô ráp là những mảng tinh thể kim loại trơ lì, ánh lên sắc lạnh và đặc cứng.',
    'item_blast_powder_jar_name': 'Bột Đá Nổ',
    'item_blast_powder_jar_desc':
        'Một chiếc hũ gốm nhỏ, xù xì, được bịt chặt bằng một nút bần sần sùi. Bên ngoài vỏ hũ hằn lên một dấu chữ ‘X’ được vạch ra đầy nghuệch ngoạc.',

    // Tier 4 – Sử Thi
    'item_pure_silver_ore_name': 'Quặng Bạc Nguyên Chất',
    'item_pure_silver_ore_desc':
        'Một cụm tinh thể nhọn hoắt đâm tua tủa ra từ nền đá đen ngòm. Bề mặt của chúng nhẵn thín, bắt sáng cực sắc và bóng loáng đến mức hoàn toàn đối lập với lớp vỏ thô lởm chởm bên ngoài.',
    'item_mechanical_components_name': 'Linh Kiện Cơ Khí',
    'item_mechanical_components_desc':
        'Một cụm chi tiết cực nhỏ gọn với những bánh răng cưa sắc lẹm đan khít vào nhau. Từng vòng xoắn ốc của chiếc lò xo đính kèm đều tăm tắp, lạnh lẽo và chính xác đến từng li.',

    // Tier 5 – Huyền Thoại
    'item_rare_steel_ore_name': 'Quặng Thép Hiếm',
    'item_rare_steel_ore_desc':
        'Một khối kim loại đặc, đen bóng và nhẵn mịn như mặt kính. Ẩn sâu dưới bề mặt tĩnh lặng đó là những đường vân chìm cuộn xoắn vào nhau, tạo cảm giác về một cấu trúc dồn nén đến đặc kịt.',
    'item_pure_gold_block_name': 'Vàng Khối',
    'item_pure_gold_block_desc':
        'Một thỏi kim loại hình chữ nhật đúc khuôn vuông vức. Bề mặt trơn láng hoàn hảo không lưu lại lấy một vết xước, với các cạnh viền được cắt gọt sắc sảo, phẳng phiu đến mức dị thường.',

    // ── Nguyên liệu hữu cơ & sinh học ───────────────────────────────────────

    // Tier 1 – Thường
    'item_raw_animal_hide_name': 'Da Thú Thô',
    'item_raw_animal_hide_desc':
        'Một tấm da nhăn nheo, mỏng quẹt và xỉn màu. Phần rìa ngoài rách rưới lởm chởm, bề mặt lùng nhùng vẫn còn vương lại vài sợi lông tơ xơ xác và những vết lột thô bạo.',
    'item_thorny_rope_coil_name': 'Dây Thừng Gai',
    'item_thorny_rope_coil_desc':
        'Một cuộn dây đục màu được quấn chặt nịt thành bó. Từng sợi bện vào nhau thô ráp, cứng cáp và tua tủa những cọng gai xơ xác, li ti châm chích khi chạm vào.',
    'item_animal_fat_name': 'Mỡ Động Vật',
    'item_animal_fat_desc':
        'Một khối vón cục lổn nhổn, nhờn rít và ngả màu nhờ nhờ đục. Bề mặt nhày nhụa, ướt át, luôn bọc trong một lớp váng bóng nhẫy, sền sệt mỡ đông chực chờ trơn tuột khỏi tay.',
    'item_mud_and_leaves_name': 'Bùn và Lá Cây',
    'item_mud_and_leaves_desc':
        'Một đống nhão nhoét, bết dính với tông màu nâu đen mục rữa. Lớp đất ẩm ướt quánh đặc, bóp nghẹt lấy những mảnh xác lá dập nát, héo úa rũ rượi và tơi tả gân xơ.',

    // Tier 2 – Ít Gặp
    'item_thick_warm_fur_name': 'Lông Thú Giữ Ấm',
    'item_thick_warm_fur_desc':
        'Một mảng lông thú dày cộm và nặng trĩu. Lớp lông tơ bên dưới đan kết đặc nghẹt, trong khi phần bề mặt thì xù xì, bờm xờm và hơi bết lại thành từng lọn tối màu.',
    'item_resin_name': 'Nhựa Cây',
    'item_resin_desc':
        'Một loại chất lỏng đặc quánh, sẫm đen đựng trong một chiếc bát gỗ mẻ. Bề mặt nó sền sệt, nhầy nhụa màng keo dính và nổi lấm tấm vài bọt khí vẩn đục kẹt lại bên trong.',
    'item_leather_strap_name': 'Dây Đai Da',
    'item_leather_strap_desc':
        'Một dải da hẹp, thuôn dài được cắt xén thẳng thớm. Bề mặt nhẵn bóng, dai dẳng nhưng hằn rõ những nếp gấp thời gian, dọc theo thân đục sẵn vài lỗ nhỏ có phần mép sờn rách.',
    'item_hard_oak_wood_name': 'Gỗ Sồi Cứng',
    'item_hard_oak_wood_desc':
        'Một khúc gỗ nguyên khối mộc mạc, nặng trịch và đặc nịch. Bề mặt nhám ráp nổi rõ những đường vân sẫm màu, gợn sóng chạy dài dọc thân xen lẫn vài mắt gỗ lồi lõm, sần sùi cứng như tảng đá.',
    'item_beast_blood_vial_name': 'Máu Quái Thú',
    'item_beast_blood_vial_desc':
        'Một chất lỏng sền sệt, đặc quánh và sẫm màu đến mức gần như đen kịt. Bề mặt nó lờ đờ nổi lên những mảng váng nhớt nháp, bám dính dai dẳng lấy thành lọ và bốc lên cảm giác ẩm ướt, tanh tưởi dù chỉ nhìn bằng mắt.',

    // Tier 3 – Hiếm
    'item_sticky_tar_name': 'Hắc Ín',
    'item_sticky_tar_desc':
        'Một vũng chất đặc quánh, đen kịt và sền sệt như bóng tối lỏng. Bề mặt lờ đờ, dẻo quẹo và bám dính tàn bạo, kéo dãn thành những sợi keo dai nhách, rũ rượi mỗi khi bị bóc tách hay chạm vào.',
    'item_mutated_beast_tendon_name': 'Gân Thú Biến Dị',
    'item_mutated_beast_tendon_desc':
        'Một dải mô xám xịt, cuộn xoắn vặn vẹo với những thớ thịt nhợt nhạt căng bần bật. Cấu trúc gân guốc dị hợm, luôn trong trạng thái co rút tàn bạo và bóng nhẫy một lớp màng nhầy rũ rượi bao phủ bên ngoài.',
    'item_beast_horn_name': 'Sừng Quái Thú',
    'item_beast_horn_desc':
        'Một đoạn gai vuốt cong vút, lởm chởm và nhọn hoắt. Bề mặt sừng nhám xám, nứt nẻ chằng chịt những rãnh sâu hoắm dã man, dọc theo gốc nanh vẫn còn đóng cục những mảng bám đen ngòm, thô ráp.',
    'item_beast_bone_remnant_name': 'Xương Quái Thú',
    'item_beast_bone_remnant_desc':
        'Một mảng tàn tích trắng bệch, nham nhở vết cắn xé. Cấu trúc xốp rỗng, mủn ra lấm tấm tạo thành một lớp bụi vụn vỡ mờ đục, lả tả rơi rụng từ những đường rạn nứt sâu hoắm trên thân xương.',

    // Tier 4 – Sử Thi
    'item_elite_monster_hide_name': 'Da Thú Tinh Anh',
    'item_elite_monster_hide_desc':
        'Một phiến da ngoại cỡ, dày cộm và đặc cứng như một lớp áo giáp tự nhiên. Bề mặt sần sùi dập nổi những đường vân gồ ghề, dấu hằn sâu vô số vết sẹo chằng chịt cày xới nhưng tuyệt nhiên không có dấu hiệu bị xuyên thủng.',
    'item_blood_crystal_name': 'Huyết Tinh Quái Thú',
    'item_blood_crystal_desc':
        'Một khối tinh thể góc cạnh vỡ vụn với những mặt cắt trơn nhẵn, sắc lẹm. Ẩn sâu bên dưới lớp vỏ ngoài bóng loáng, lạnh lẽo ấy là những đường vân tối đặc quánh, cuộn trào và đông cứng lại tựa như những mạch máu hóa thạch.',
    'item_wraith_hair_name': 'Sợi Tóc Oan Hồn',
    'item_wraith_hair_desc':
        'Một búi tơ mỏng manh, lơ lửng và mờ ảo tựa như sương khói đọng lại. Từng sợi li ti mang màu xám tro nhợt nhạt, trôi dạt vô định trong không trung, uốn lượn êm ái mà lạnh toát, chực chờ tan biến ngay khi chạm ánh nhìn.',

    // Tier 4 – Sử Thi (tiếp)
    'item_broken_holy_relic_name': 'Thánh Giá Gãy',
    'item_broken_holy_relic_desc':
        'Một biểu tượng tôn giáo bằng đồng xỉn màu, bị bẻ gập và vỡ nát thảm hại. Bề mặt bám đầy nhọ nồi cùng rêu phong mục rữa, nhưng từ vết nứt gãy thẳm sâu vẫn len lỏi một vầng sáng leo lét, nhợt nhạt như một lời cầu nguyện cuối cùng chưa kịp tắt.',
    'item_broken_silver_chalice_name': 'Chén Thánh Gãy',
    'item_broken_silver_chalice_desc':
        'Một chiếc ly bạc xám xịt bị bóp méo, miệng chén sứt mẻ và thân in hằn những vết vuốt cào man rợ. Lòng chén khô khốc, đóng vẩy những lớp cặn sẫm màu, tỏa ra thứ hàn khí buốt giá đặc trưng của cõi âm.',
    'item_dream_incense_powder_name': 'Bột Xông Mộng Mị',
    'item_dream_incense_powder_desc':
        'Một nắm bột nhuyễn lấp lánh như tro tàn của những vì sao chết. Khi nằm lặng im, chúng vón lại như thứ cát mục nát, nhưng chỉ cần một luồng hơi thở xẹt qua, lớp bột ngay lập tức cuộn lên, tan biến thành những ảo ảnh khói sương mờ mịt lơ lửng trong không trung.',

    // Tier 5 – Huyền Thoại
    'item_nightmare_fruit_name': 'Trái Ác Mộng',
    'item_nightmare_fruit_desc':
        'Một khối thực vật kỳ dị đập thình thịch theo nhịp của một trái tim thối rữa. Vỏ ngoài đen sần sùi, chằng chịt những rễ gân phồng rộp ôm chặt lấy một thứ ánh sáng đỏ quạch quái gở rỉ ra từ bên trong, gây cảm giác buồn nôn và gai ốc.',
    'item_cleansing_tear_name': 'Nước Mắt Thanh Tẩy',
    'item_cleansing_tear_desc':
        'Một giọt chất lỏng bềnh bồng lơ lửng, trong vắt đến mức gần như vô hình. Nó hoàn toàn miễn nhiễm với bụi bặm và sự ô uế xung quanh, tản mát ra một vầng hào quang trắng tinh khiết, dịu nhẹ và cô độc giữa bóng tối.',
    'item_quartz_clockwork_parts_name': 'Bộ Chân Kính Thạch Anh',
    'item_quartz_clockwork_parts_desc':
        'Một cụm vi mạch cơ khí tinh xảo rực sáng dưới lớp vỏ thạch anh vỡ nát. Từng khớp nối đồng thau siêu nhỏ đan xen vào những thấu kính lăng trụ, chớp tắt những tia lửa lạnh lẽo, hoàn mỹ đến mức không giống vật do bàn tay phàm nhân tạo ra.',
    'item_bone_lantern_fire_name': 'Lửa Từ Lồng Đèn Xương',
    'item_bone_lantern_fire_desc':
        'Một ngọn lửa xanh lè, u ám cháy lặng lẽ trên một mảnh xương mục. Nó không tỏa ra chút nhiệt lượng nào, không nhấp nháy trước gió, mà chỉ lạnh lẽo thiêu đốt không gian bằng thứ ánh sáng ma trơi rùng rợn và vĩnh cửu.',
    'item_broken_royal_sword_name': 'Lưỡi Kiếm Vương Quyền Gãy',
    'item_broken_royal_sword_desc':
        'Một đoạn gươm khổng lồ vỡ gập, lưỡi thép mẻ nát đục ngầu sự hoang tàn. Chuôi kiếm bọc lớp mạ vàng bong tróc tả tơi, viên ngọc khảm giữa cán đã mờ đục hoàn toàn vì ngâm mình quá lâu trong màn sương mù nguyền rủa.',
    'item_rusted_king_armor_name': 'Áo Giáp Vua Gỉ Sét',
    'item_rusted_king_armor_desc':
        'Một thân giáp ngực đồ sộ bị thời gian và tà khí cắn xé thê thảm. Các phiến thép chồng lên nhau đã chết cứng bởi rỉ sét đỏ quạch, móp méo bởi vô số đòn chí mạng, vương vất sự nặng trịch và tuyệt vọng của một vương triều sụp đổ.',
    'item_petrified_root_name': 'Rễ Cây Hóa Thạch',
    'item_petrified_root_desc':
        'Một đoạn rễ cây sần sùi nhưng lại đặc cứng như một tảng đá lửa ngàn năm. Bề mặt nó xám ngoét, đan chéo những vết nứt nẻ khô cằn, tủy rễ bên trong ánh lên tàn dư của thứ nhựa cây đã kết tinh thành khoáng thạch sắc lẹm.',
    'item_weeping_bow_frame_name': 'Khung Cung Than Khóc',
    'item_weeping_bow_frame_desc':
        'Một thân cung làm từ loại vật liệu nửa giống gỗ tàn, nửa giống xương người trắng dã. Cấu trúc vặn vẹo, cong vênh như một thân xác đang quằn quại đau đớn, dọc theo viền đục vô số hốc nhỏ, rít lên những âm thanh nức nở man rợ mỗi khi gió luồn qua.',
    'item_goliath_ruined_armor_name': 'Khối Giáp Nát Của Goliath',
    'item_goliath_ruined_armor_desc':
        'Một mảng kim loại siêu trọng, thô kệch và to bằng cả phiến đá tảng. Bề mặt lồi lõm, nham nhở dấu búa tạ nện xuống vỡ vụn, mang theo cảm giác áp bức nghẹt thở ngay cả khi nó chỉ nằm bất động.',
    'item_gold_dusted_shield_fragment_name': 'Mảnh Khiên Bám Bụi Vàng',
    'item_gold_dusted_shield_fragment_desc':
        'Một góc vỡ nát thảm thương của chiếc khiên đồ sộ. Bề mặt nhám xịt ngập trong bụi bẩn và tăm tối, nhưng sâu trong những kẽ nứt lại rỉ ra thứ bột vàng chói lọi, ngoan cường tỏa sáng bất chấp màn đêm đặc quánh.',

    // Tier 6 – Thần Thoại
    'item_evil_god_chain_name': 'Xích Sắt Khóa Tà Thần',
    'item_evil_god_chain_desc':
        'Một đoạn xích khổng lồ đen đặc, dường như đang nuốt chửng mọi ánh sáng lọt vào. Từng mắt xích đều được đúc chìm những văn tự cấm kỵ sắc lẹm rực lửa, không ngừng rên rỉ tiếng kim loại nghiến vào nhau như đang tuyệt vọng kìm hãm một cơn thịnh nộ không đáy.',
    'item_abyssal_shroud_fragment_name': 'Mảnh Vải Khâm Liệm Từ Vực Thẳm',
    'item_abyssal_shroud_fragment_desc':
        'Một mảng vải tơi tả, mỏng manh nhưng tăm tối hơn cả chính bóng đêm. Nó như một thực thể sống đang rũ xuống, không ngừng rỉ ra một thứ sương mù u ám, mang theo cái lạnh thấu xương và hơi thở hoang vu của sự kết thúc chôn vùi.',
    'item_players_own_blood_name': 'Máu Của Chính Người Chơi',
    'item_players_own_blood_desc':
        'Một giật chất lỏng lơ lừng, đỏ thẫm và rực rỡ đến đau đớn. Nó cuộn xoáy mãnh liệt, sôi sục hơi nóng của sinh mệnh, tỏa ra cảm giác nhói buốt, nặng nề và thiêng liêng tột độ — như chính một mảnh linh hồn vừa bị tàn nhẫn xé toạc ra khỏi lồng ngực.',

    'itemRarityUnique': 'ĐỘC NHẤT',
    'itemRarityCommon': 'THƯỜNG',
    'itemRarityUncommon': 'Ít Thấy',
    'itemRarityRare': 'HIẾM',
    'itemRarityEpic': 'SỬ THI',
    'itemRarityLegendary': 'HUYỀN THOẠI',
    'itemRarityMythic': 'THẦN THOẠI',

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
    'itemUse': 'SỬ DỤNG',    'itemEquip': 'TRANG BỊ',
    'itemUnequip': 'THÁO RA',
    'itemEquipped': 'Đã trang bị',    'itemOnlyInCombat': '* Chỉ dùng được trong chiến đấu.',
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
    'groupWeapon': 'Vũ Khí',
    'groupArmor': 'Áo Giáp',
    'groupMaterial': 'Vật Liệu',
    // Buff: Khám Phá
    'statusTomorrowExploreBonus':     'Khám Phá Ngày Mai',
    'statusTomorrowExploreBonusDesc': 'Tăng tỷ lệ nhặt được vật phẩm trong lần khám phá tiếp theo.',
    // Buff: Khám Phá & Chiến Đấu
    'statusShielded':                 'Được Che Chở',
    'statusShieldedDesc':             'Miễn nhiễm toàn bộ debuff trong quá trình khám phá và chiến đấu.',
    // Debuff: Khám Phá & Tập Luyện
    'statusRacingHeart':              'Tim Đập Mạnh',
    'statusRacingHeartDesc':          'Mọi hành động tiêu hao Thể Lực khi Khám Phá và Tập Luyện đều tốn gấp đôi. Mất sau 1 ngày.',
    'statusTightChest':               'Tức Ngực',
    'statusTightChestDesc':           'Mọi hành động tiêu hao Thể Lực khi Khám Phá và Tập Luyện đều tốn thêm +5. Mất sau 1 ngày.',
    // Debuff: Chiến Đấu
    'statusSleepy':                   'Ngái Ngủ',
    'statusSleepyDesc':               'Kẻ thù luôn đánh lượt đầu tiên trong trận chiến này.',

    // ── Trạng Thái ──────────────────────────────────────────────────────────────────────────────
    'statusBleeding':          'Chảy Máu',
    'statusBleedingDesc':       'Trong chiến đấu, mất 2 Máu đầu mỗi hiệp. Khi thám hiểm, mỗi bước tiến hoặc lùi trừ thêm 1 Máu.',
    'statusInfection':          'Nhiễm Trùng',
    'statusInfectionDesc':      'Giới hạn Máu tối đa bị trừ 5 điểm. Nếu ngủ qua đêm đang mặc Giáp Da Rách, mất thêm 1 Máu mỗi đêm.',
    'statusPoisoned':           'Nhiễm Độc',
    'statusPoisonedDesc':       'Trong chiến đấu, mất 3 Máu đầu mỗi hiệp. Sát thương gây ra cho địch giảm 10%.',
    'statusFear':               'Sợ Hãi',
    'statusFearDesc':           'Kỹ năng Đặc biệt bị khóa hoàn toàn. Tỷ lệ đánh trúng mục tiêu giảm 20%.',
    'statusExhausted':          'Kiệt Sức',
    'statusExhaustedDesc':      'Thể lực tối đa bị chia đôi (−50%). Hạn chế nghiêm trọng hoạt động thám hiểm và tập luyện.',
    'statusBurning':            'Thiêu Đốt',
    'statusBurningDesc':        'Trong chiến đấu, mất 5 Máu đầu mỗi hiệp. Ngoài chiến đấu, mỗi hành động tốn thời gian trừ thêm 1 Máu.',
    'statusDislocated':         'Trật Khớp',
    'statusDislocatedDesc':     'Thanh chờ hành động bị kéo dài. Nhân vật ra đòn rất chậm, quái vật có thể tấn công nhiều hiệp liên tiếp trước khi đến lượt bạn.',
    'statusBlurredVision':      'Mờ Mắt',
    'statusBlurredVisionDesc':  'Mỗi lần vung vũ khí, tỷ lệ đánh trúng bị trừ ngẫu nhiên 5–15%. Tỷ lệ đánh trượt rất cao.',
    'statusSluggish':           'Trì Trệ',
    'statusSluggishDesc':       'Thể lực tối đa bị trừ cố định 5 điểm.',
    'statusPainSensitive':      'Nhạy Cảm Nỗi Đau',
    'statusPainSensitiveDesc':  'Khi bị mất Máu, Độ Tỉnh Táo cũng bị trừ đi đúng lượng Máu vừa mất.',
    'statusCursedAnxiety':      'Lời Nguyền Bất An',
    'statusCursedAnxietyDesc':  'Độ Tỉnh Táo tối đa bị khóa ở 80%. Không thể đạt trạng thái Minh Mẫn (100% Tỉnh Táo).',
    'statusSuddenDeath':        'Đột Tử',
    'statusSuddenDeathDesc':    'Bỏ qua mọi Phòng thủ, áo giáp và miễn nhiễm tử vong. Máu của nhân vật ngay lập tức tụt về 0.',

    // ── Buff ──────────────────────────────────────────────────────────────────────────────────────────
    'statusBloodthirst':           'Khát Máu',
    'statusBloodthirstDesc':       'Tỷ lệ Tấn công Chí mạng được cộng thêm 50% trong suốt trận chiến.',
    'statusRegeneration':          'Hồi Phục Liên Tục',
    'statusRegenerationDesc':      'Tự động hồi 5 Máu ở đầu mỗi hiệp đánh trong giao tranh.',
    'statusImmortal':              'Bất Tử',
    'statusImmortalDesc':          'Máu không thể xuống dưới 1 dù nhận bất kỳ sát thương nào.',
    'statusEnergized':             'Sức Lực Tràn Trề',
    'statusEnergizedDesc':         'Sát thương vật lý gây ra cho kẻ địch được nhân thêm 20%.',
    'statusIronSkin':              'Da Sắt',
    'statusIronSkinDesc':          'Mọi sát thương nhận vào bị trừ 5 điểm (tối thiểu 0).',
    'statusFogImmunity':           'Miễn Nhiễm Sương Mù',
    'statusFogImmunityDesc':       'Bước tiến vào sương mù không trừ % độ sáng Lồng Đèn.',
    'statusTirelessStep':          'Bước Chân Nhẹ',
    'statusTirelessStepDesc':      'Bước tiến trong sương mù không trừ 5 Thể Lực.',
    'statusNightVision':           'Dạ Nhãn',
    'statusNightVisionDesc':       'Không bị trừ Độ Tỉnh Táo khi thám hiểm lúc Lồng Đèn dưới 70%.',
    'statusImmunity':              'Kháng Trạng Thái',
    'statusImmunityDesc':          'Chặn hoàn toàn mọi lệnh gán debuff từ quái vật lên người chơi.',
    'statusPhantomStep':           'Bóng Ma Sương Mù',
    'statusPhantomStepDesc':       'Xác suất gặp sự kiện “Chạm trán / Phục kích” khi thám hiểm giảm về 0%.',
    'statusIronStomach':           'Dạ Dày Thép',
    'statusIronStomachDesc':       'Tác dụng phụ của thức ăn Tier 1–2 bị vô hiệu hóa. Chỉ nhận Độ No và buff tích cực.',
    'statusEerieLuck':             'May Mắn Kì Lạ',
    'statusEerieLuckDesc':         'Roll nhặt đồ bỏ qua Pool cơ bản, lấy từ Pool cấp cao hoặc x2 số lượng nhặt được.',
    'statusCultistSense':          'Giác Quan Tà Đạo',
    'statusCultistSenseDesc':      'Tỷ lệ roll sự kiện Tương tác/Cốt truyện đạt tối đa, chèn ép sự kiện nhặt rác thông thường.',
    'statusItemPreservation':      'Bảo Hộ Vật Chất',
    'statusItemPreservationDesc':  'Nếu gục trong sương mù, không bị mất đồ vừa nhặt. Giữ lại 100% tài nguyên trong túi.',

    // ── Tập Luyện ──────────────────────────────────────────────────────────────────────────────
    'trainOptionStrength':      'Vung Vũ Khí',
    'trainOptionStrengthStat':  'Luyện Sức Mạnh / Tấn Công',
    'trainOptionEndurance':     'Khuân Vác Xà Gồ',
    'trainOptionEnduranceStat': 'Luyện Bền Bỉ / Phòng Thủ & Máu',
    'trainOptionMeditation':     'Ngồi Thiền Trước Lửa',
    'trainOptionMeditationStat': 'Luyện Ý Chí / Thể Lực & Tinh Thần',
    'trainNotEnoughResources': 'Không đủ tài nguyên để tập luyện',
    'trainMaxLevel':           'Đã đạt tối đa (Cấp 100) – không tăng EXP',
    'trainExpLabel':           'Kinh nghiệm',
    'trainLevelUp':            'CHỈ SỐ TĂNG!',
    'trainBack':               '← QUAY LẠI',
    'trainResultTitle':        'KẾT QUẢ TẬP LUYỆN',
    'trainResultContinue':     'TIẾP TỤC',
    // ── Sự kiện ngẫu nhiên – Vung Vũ Khí────────────────────────────
    'trainStrEvNormalTitle':     'Buổi tập suôn sẻ',
    'trainStrEvNormalDesc':      'Tiếng gió rít lên sau mỗi nhát chém xé toạc không gian chật hẹp của khu nhà chứa. Cơ bắp bạn đau nhức tột độ, mồ hôi ướt đẫm trán, nhưng bạn có thể cảm nhận được cơ thể mình đang dần thích nghi với sức nặng này.',
    'trainStrEvInjuryTitle':     'Tai nạn trật khớp',
    'trainStrEvInjuryDesc':      '"Rắc!" - Một cơn đau nhói truyền từ vai lên tận óc. Bạn vung vũ khí sai tư thế và tự làm trật khớp chính mình. Thanh sắt tuột khỏi tay, rơi loảng xoảng xuống nền đá. Bạn gục xuống ôm lấy bả vai trong sự đau đớn tột cùng.',
    'trainStrEvTraumaTitle':     'Tiếng cười trong bóng tối',
    'trainStrEvTraumaDesc':      'Sự mệt mỏi sinh ra ảo giác. Trong góc khuất của ánh đèn, bạn thấy những cái bóng đang vặn vẹo. Chúng biến thành hình thù của những kẻ đã khuất, đang thì thầm châm chọc sự yếu ớt và nỗ lực vô vọng của bạn. Bạn buông thõng hai tay, lùi lại, nhịp tim đập loạn xạ vì sợ hãi.',
    'trainStrEvWeaponAccTitle':  'Lưỡi kiếm phản chủ',
    'trainStrEvWeaponAccDesc':   'Thanh vũ khí tàn tạ của bạn không chịu nổi lực vung quá mạnh. Một mảng rỉ sét vỡ vụn, văng đập mạnh vào cột đá rồi bật ngược trở lại, găm thẳng vào cẳng tay bạn. Máu đen bắt đầu rỉ ra qua những kẽ tay.',
    'trainStrEvBreakthruTitle':  'Giác ngộ',
    'trainStrEvBreakthruDesc':   'Đột nhiên, mọi âm thanh xung quanh như tĩnh lại. Bạn vô thức thực hiện một nhát chém hoàn hảo nhất từ trước đến nay. Lực đạo tuôn trào mượt mà qua từng thớ thịt, xua tan đi mọi sự mệt mỏi. Trong khoảnh khắc ngắn ngủi, bạn thấu hiểu một giới hạn mới của sức mạnh cơ bắp.',
    'trainStrEvFindTitle':       'Mảng tường nứt nẻ',
    'trainStrEvFindDesc':        'Nhát chém trật nhịp của bạn sượt qua và đập vỡ một mảng tường mục nát của safehouse. Khi lớp bụi vãn đi, một hốc nhỏ bị lấp kín từ lâu dần lộ ra dưới ánh sáng của Lồng Đèn Xương. Có thứ gì đó đang nằm bên trong...',
    'trainStrEvAbyssTitle':      'Cơn khát máu tà ác',
    'trainStrEvAbyssDesc':       'Mắt bạn tối sầm lại. Ý thức chìm vào một khoảng không lạnh lẽo. Cơ thể bạn đột nhiên tự cử động, vung những nhát chém tàn độc, điên cuồng bằng một thứ thế võ khát máu không thuộc về nhân loại. Khi bừng tỉnh, tay bạn run rẩy. Bạn mạnh hơn, nhưng bạn biết... một phần "con người" trong mình vừa chết đi.',
    'trainStrEvExhausTitle':     'Giới hạn chịu đựng',
    'trainStrEvExhausDesc':      'Bạn cắn răng vung thêm một nhát chém cuối cùng, nhưng sinh lực đã hoàn toàn cạn kiệt. Mắt hoa lên, phổi đau rát như bị xé toạc. Thanh kiếm tuột khỏi tay. Bạn ngã gục úp mặt xuống sàn đá lạnh, không còn sức để nhấc nổi dù chỉ là một ngón tay.',
    'trainStrEvDangerTitle':     'Tiếng ồn chết chóc',
    'trainStrEvDangerDesc':      'Tiếng rít của kim loại xé gió đã vô tình phá vỡ sự tĩnh lặng chết chóc của đêm tối. Từ khe hở ngoài cửa, những luồng sương mù cuộn trào. Hai đốm sáng đỏ rực xuất hiện trong bóng tối kèm theo tiếng gầm gừ thèm khát. Một sinh vật đã đánh hơi thấy bạn!',
    'trainStrEvBleedStatus':     '[Chảy Máu] 2 HP/lượt × 3 lượt',
    'trainStrEvStrainStatus':    '[Căng Cơ] −10 HP',
    'trainStrEvItemFound':       'Vật phẩm rơi ra:',
    'trainStrEvStaminaDrained':  'Thể Lực tụt về 0!',
    'trainStrEvCombatWarning':   'CHIẾN ĐẤU NGAY! →',
    // ── Sự kiện Khuân Vác Xà Gồ ──────────────────────────────────────────────────────────────────────
    'trainEndEvNormalTitle':      'Cơ Thể Chai Sạn',
    'trainEndEvNormalDesc':       'Bạn cắn răng nhấc bổng thanh xà gồ bằng gỗ lim mục nát lên vai, lảo đảo bước đi trong bóng tối. Lớp dằm gỗ và cạnh đá sắc nhọn cứa vào da thịt, rỉ máu. Nhưng sau nhiều vòng lặp lại, nhịp thở của bạn ổn định hơn, và lớp da dường như đã dày thêm một chút để chống lại cái lạnh.',
    'trainEndEvSpinalTitle':      'Tiếng Xương Rạn Nứt',
    'trainEndEvSpinalDesc':       'Bạn đánh giá sai trọng lượng của phiến đá vỡ. Khi cố gắng gồng mình nâng nó lên, một tiếng "rắc" khô khốc vang lên từ cột sống. Cơn đau buốt chạy dọc sống lưng khiến bạn buông thõng tay, phiến đá rơi sầm xuống đất. Bạn khuỵu gối, mồ hôi hột túa ra đầm đìa.',
    'trainEndEvHazardTitle':      'Kẻ Thù Trong Góc Tối',
    'trainEndEvHazardDesc':       'Bạn thò tay xuống dưới tảng đá lớn để tìm điểm tựa. Bất chợt, một cơn đau nhói truyền đến từ ngón tay. Bạn giật nảy mình rút tay lại, chỉ kịp thấy một sinh vật mập mạp, nhiều chân với lớp vỏ nhầy nhụa lẩn khuất vào bóng tối. Vết cắn bắt đầu sưng tấy và rỉ ra thứ mủ màu đen.',
    'trainEndEvPsychTitle':       'Bóng Đè Giữa Cõi Thực',
    'trainEndEvPsychDesc':        'Sức nặng trên vai không chỉ là gỗ và đá. Trong cơn mệt mỏi cùng cực, bạn cảm tưởng như đang gánh vác cả những tội lỗi trong quá khứ và những linh hồn oan khuất chết thảm tại Nhà Thờ này. Trọng lượng vô hình đè bẹp ý chí của bạn, khiến bạn thở dốc và run rẩy trong sự hoảng loạn.',
    'trainEndEvIronWillTitle':    'Ý Chí Vượt Giới Hạn',
    'trainEndEvIronWillDesc':     'Máu từ bả vai rịn ra, thấm đẫm chiếc áo rách nát. Nhưng kỳ lạ thay, cơn đau không còn làm bạn chùn bước. Cơ bắp bạn co rút rồi lại giãn ra một cách hoàn hảo, nâng đỡ sức nặng như một bản năng nguyên thủy. Bạn tìm thấy sự tĩnh lặng giữa tận cùng sự đày đọa thể xác. Da thịt bạn lúc này cứng cáp không kém gì phiến đá bạn đang mang.',
    'trainEndEvCaveTitle':        'Bí Mật Dưới Lớp Đá',
    'trainEndEvCaveDesc':         'Khi bạn lật tung một thanh xà gồ khổng lồ đã nằm im lìm nhiều năm, lớp nấm mốc bên dưới bong ra, để lộ một hốc nhỏ khoét sâu vào nền gạch của Nhà Thờ. Bạn phủi lớp đất tơi xốp và chạm vào một vật thể lạ. Có ai đó đã giấu thứ này ở đây trước khi thời đại tàn lụi.',
    'trainEndEvBloodRockTitle':   'Sự Dung Hợp Tà Ác',
    'trainEndEvBloodRockDesc':    'Bạn ôm chặt lấy thanh xà gồ nhuốm máu của chính mình. Sự tê dại lan tỏa. Lớp gỗ mục như thể đang mọc rễ, găm những xúc tu nhỏ bằng rêu phong thẳng vào mạch máu của bạn. Bạn không đẩy nó ra mà lại khao khát được dung hợp với nó. Cơ thể bạn vặn vẹo, trở nên rắn chắc một cách phi lý, nhưng tâm trí lại chìm sâu thêm một nhịp vào Vực thẳm.',
    'trainEndEvCrushedTitle':     'Sự Sụp Đổ',
    'trainEndEvCrushedDesc':      'Mắt bạn nhòa đi. Đôi chân run rẩy không còn tuân theo sự sai khiến của não bộ. Thanh xà gồ khổng lồ trượt khỏi đôi vai trần, kéo theo cả cơ thể bạn ngã sầm xuống nền đá lạnh giá. Khúc gỗ nặng nề đè gập lên nửa người dưới. Phổi bạn thắt lại, không thể hít lấy một ngụm không khí. Hôm nay đến đây là kết thúc.',
    'trainEndEvCollapseTitle':    'Âm Vang Chết Chóc',
    'trainEndEvCollapseDesc':     'Trong một nỗ lực bất thành, bạn tuột tay làm rơi phiến đá lớn xuống nền gạch vỡ. Tiếng va chạm khô khốc "ĐOÀNG!" vang dội, xé toạc sự im lặng tĩnh mịch của Safehouse và vọng ra ngoài màn sương mù. Lớp sương ngay cửa ra vào bắt đầu cuộn xoắn lại. Những tiếng cào cấu dồn dập vang lên. Có thứ gì đó đang phá cửa xông vào.',
    'trainEndEvDislocStatus':     '[Trật Khớp] – né tránh và tốc độ giảm',
    'trainEndEvInfectionStatus':  '[Nhiễm Trùng] – mất HP thêm hàng ngày',
    // ── Sự kiện Thiền Định ────────────────────────────────────────────────
    'trainMedEvNormalTitle':              'Tâm Trí Tĩnh Lặng',
    'trainMedEvNormalDesc':               'Ngọn lửa bập bùng xua đi cái lạnh của màn sương mù bên ngoài. Bạn nhắm mắt, để hơi thở chậm lại theo từng nhịp nháy của ngọn lửa. Trong khoảnh khắc hiếm hoi đó, tất cả mọi thứ — nỗi sợ, tiếng động bên ngoài, cơn đói trống rỗng — đều tan biến. Chỉ còn lại sự tĩnh lặng.',
    'trainMedEvPsychHallucinationTitle':  'Ảo Ảnh Trong Tro Tàn',
    'trainMedEvPsychHallucinationDesc':   'Ngọn lửa đột nhiên đổi sang màu xanh biếc. Từ trong làn khói, một khuôn mặt méo mó ngước nhìn bạn — rồi tan biến ngay khi bạn chớp mắt. Bạn không chắc mình vừa nhìn thấy gì. Nhưng cảm giác bị nhìn chằm chằm vẫn còn đó, bám chặt vào gáy bạn như một bàn tay vô hình.',
    'trainMedEvBurnInjuryTitle':          'Hơi Nóng Phỏng Da',
    'trainMedEvBurnInjuryDesc':           'Cơn lạnh thấu xương của sương mù đã đánh lừa cảm giác của bạn — bạn ngồi quá gần đống lửa mà không hay biết. Đến khi mùi khét bốc lên, vệt bỏng đỏ ửng đã hằn lên cổ tay. Nhỏ thôi, nhưng đủ để rát buốt mỗi lần bạn cử động.',
    'trainMedEvLanternFlickerTitle':      'Bóng Tối Chực Chờ',
    'trainMedEvLanternFlickerDesc':       'Dù bạn không hề chạm vào, ngọn đèn lồng bắt đầu rung lên rồi tắt phụt trong một giây. Bóng tối ập xuống như một tấm chăn ướt lạnh. Ánh lửa đống sưởi trở nên bé tí tẹo và yếu ớt. Khi đèn bùng sáng trở lại, lượng nhiên liệu bên trong đã hao đi không rõ lý do.',
    'trainMedEvEnlightenmentTitle':       'Tâm Như Minh Cảnh',
    'trainMedEvEnlightenmentDesc':        'Bạn nhắm mắt lại và rơi vào một trạng thái kỳ lạ — không phải giấc ngủ, không phải thức. Từng ký ức, từng vết thương cũ, từng nỗi sợ lần lượt trôi qua như bóng ma không màu. Rồi tất cả im lặng. Khi bạn mở mắt, ngọn lửa vẫn cháy — nhưng bạn đã khác. Rõ ràng hơn. Nhẹ nhõm hơn. Như một mảnh gương vừa được lau sạch.',
    'trainMedEvAncientScriptTitle':       'Cổ Ngữ Trong Ngọn Lửa',
    'trainMedEvAncientScriptDesc':        'Bạn nhìn chằm chằm vào trung tâm ngọn lửa, và trong làn khói cuộn tròn, những nét chữ lạ bắt đầu hiện ra — không phải ảo giác, mà như thể được khắc vào không khí. Bạn không hiểu chúng nghĩa gì. Nhưng khi bạn đứng dậy, tay bạn đang nắm chặt một thứ gì đó mà bạn không nhớ đã nhặt lên.',
    'trainMedEvAbyssCallTitle':           'Lời Thì Thầm Của Cổ Thần',
    'trainMedEvAbyssCallDesc':            'Ngọn lửa vụt tắt. Bóng tối hoàn toàn — trong một giây duy nhất. Và trong giây đó, có thứ gì đó thì thầm vào tai bạn bằng một ngôn ngữ không thuộc về con người. Bạn không hiểu được từng từ, nhưng ý nghĩa thấm vào não bạn như nước thấm vào đất khô: Ngươi đã được nhìn thấy. Ngươi sẽ không còn như trước.',
    'trainMedEvSoulWanderTitle':          'Lạc Bước Cõi Âm',
    'trainMedEvSoulWanderDesc':           'Bạn chìm vào trạng thái thiền quá sâu — sâu đến mức ý thức bạn trôi đi khỏi thể xác. Một thời gian dài sau, bạn giật mình tỉnh lại với cảm giác đã đi một hành trình rất dài, dù thân xác không hề nhúc nhích. Chân tay rã rời. Thể lực hoàn toàn kiệt sức — như thể hồn bạn đã đi quá xa mà cơ thể phải dùng toàn bộ sức lực để kéo nó trở về.',
    'trainMedEvShadowBetrayalTitle':      'Cái Bóng Phản Bội',
    'trainMedEvShadowBetrayalDesc':       'Ngọn lửa vô tình bùng lên mạnh mẽ, chiếu cái bóng của bạn lên bức tường phía sau. Nhưng cái bóng đó không bắt chước động tác của bạn. Nó quay đầu nhìn bạn. Rồi nó bước ra khỏi tường.',
    'trainMedEvBurnStatus':               '[Bỏng Nhẹ] 1 HP/lượt × 3 ngày combat',
    'trainMedEvLanternLoss':              'Bóng Tối Liếm Lửa (Lồng Đèn)',
    // ── Đặc điểm trang bị ─────────────────────────────────────────────────
    'itemStatGlancingHit':       'Đòn Lướt',
    'itemStatBleedOnCrit':       'Gây Chảy Máu khi Chí Mạng',
    'itemStatTrainRisk':         'Tăng rủi ro tai nạn luyện tập',
    'itemStatInfectionDrain':    'Nhiễm Trùng thoát thêm HP',
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

    // Exploration screen
    'exploreSearchQuestion': 'What are you looking for?',
    'exploreCatFood':        'Food',
    'exploreCatMedical':     'Medical',
    'exploreCatMental':      'Mental',
    'exploreCatCombat':      'Combat',
    'exploreCatEquipment':   'Equipment',
    'exploreAreaQuestion':   'Which area do you want to explore?',
    'exploreAreaQuarry':     'Excavation Ravine',
    'exploreAreaForest':     'Wild Beast Forest',
    'exploreAreaBattlefield':'Buried Battlefield',
    'exploreBack':           '← BACK',

    // Travel to area
    'exploreTravelStep':           'Travel steps',
    'exploreTravelChance':         'Arrival chance',
    'exploreTravelCostPer':        'Cost per step',
    'exploreTravelCostStamina':    'Stamina',
    'exploreTravelCostLantern':    'Brightness',
    'exploreTravelCurrentStamina': 'Current Stamina',
    'exploreTravelCurrentLantern': 'Current Brightness',
    'exploreTravelAdvance':        'ADVANCE',
    'exploreTravelNoStamina':      'Not enough Stamina to continue.',
    'exploreTravelArrived':        'ARRIVED!',
    'exploreTravelExplore':        'EXPLORE AREA',
    'exploreTravelReturnHub':      '← RETURN TO ABANDONED TEMPLE',

    // Travel events
    'travelEventContinue':              'CONTINUE',
    'travelEventBreathOfSilence':       'Breath of Silence',
    'travelEventBreathOfSilenceDesc':   'The wind\'s keen whistle through the dry canopy ceases without warning. The fog thins just enough to reveal pale shafts of light drifting down onto a carpet of deep moss. This uncanny stillness is rare, yet it drives the vigilance in your chest to a razor\'s edge.',
    'travelEventShatteredCarriage':     'Shattered Carriage',
    'travelEventShatteredCarriageDesc': 'A wooden wagon lies overturned at the edge of a dirt trail, its canvas cover ripped to ragged shreds. Splintered cargo crates litter the ground, and deep claw-gouges scar the timber. The sharp tang of rust mingles with the cloying sweetness of rot drifting from a hold as black as pitch.',
    'travelEventHangedMan':             'The Hanged Man',
    'travelEventHangedManDesc':         'Swaying from the gnarled limb of an ancient oak is a corpse clad in blood-soaked leather armour. The rope has bitten deep into a throat long since turned violet. A flock of ravens caws steadily, stripping away each putrid strip of flesh that drops onto the mud beneath your feet.',
    'travelEventBlackBloodRain':        'Black Blood Rain',
    'travelEventBlackBloodRainDesc':    'The murky sky above darkens without warning. Thick, rancid drops reeking of death begin to pelt down. Each black globule strikes the earth with a hiss, gnawing at the feeble flicker of the bone lantern you clutch in white-knuckled hands.',
    'travelEventCriesInThicket':        'Cries in the Thicket',
    'travelEventCriesInThicketDesc':    'From deep within a thorn-choked undergrowth that no gaze can penetrate, the broken sobbing of a child rises in fragile bursts. The sound is razor-sharp, tearing at whatever humanity remains in your mind, luring the curious to step willingly into death.',
    'travelEventFeralTerritory':        'Feral Territory',
    'travelEventFeralTerritoryDesc':    'The air is thick with the stench of mud, wet fur and fresh blood. Ahead in the murk, pairs of amber eyes ignite. Low rhythmic snarls roll from foam-dripping maws, warning you that you have stumbled into the middle of a savage feast.',
    'travelEventWanderingAmbush':       'The Wandering Hunter',
    'travelEventWanderingAmbushDesc':   'The cloying fog is torn apart by a wave of killing intent that chills to the bone. A grotesque silhouette with a twisted frame lunges from the dark. The crack of bone and the scrape of claws ring out one heartbeat before the hunter locks onto yours.',
    'travelEventFacelessGoddess':       'The Faceless Goddess',
    'travelEventFacelessGoddessDesc':   'A jade statue of a goddess stands alone amid the ruins, its face ruthlessly smashed beyond recognition. The statue\'s cracked hands protrude a hollow bronze scale. It seems this power demands not prayers, but flesh and blood as the price of exchange.',
    'travelEventMadmanChessboard':      'The Madman\'s Chessboard',
    'travelEventMadmanChessboardDesc':  'Squarely in the centre of the dark passage sits a rotting chessboard. Closer now, you see its pieces grotesquely carved from finger bones and tiny bird skulls. An unfinished endgame waits in silence, patient for the next lunatic willing to risk a move.',
    'travelEventWanderingSmuggler':     'Wandering Smuggler',
    'travelEventWanderingSmugglerDesc': 'By the guttering light of green candles, a hunched figure buckles under the weight of an enormous clinking pack. The patched-cloak wearer curls a smile to reveal teeth blacked with rot. Gold is worthless to him. What he craves is flesh, scrap iron, and the mad secrets you hide in your desperation.',
    'travelEventTheConfessor':          'The Confessor',
    'travelEventTheConfessorDesc':      'Prostrate in a muddy pool is a trembling figure, both hands bound tight by lengths of rusted spike-studded chain. A priest in a tattered cassock. His voice is hoarse and frenzied, begging to hear your blood-soaked sins so he may offer them to some power that has long since looked away.',
    'travelEventFogAnomaly':            'Fog Anomaly',
    'travelEventFogAnomalyDesc':        'Reality wrenches around you without mercy. The fog no longer drifts but writhes and roils like enormous contracting muscles. A suffocating pressure descends as this world\'s physical laws collapse, making way for the presence of a vast primordial nightmare that has just extended a tendril into your mind.',

    // Event choices – Breath of Silence
    'choiceBreathLanternOff':           'Extinguish the lantern to conserve oil',
    'choiceBreathSleep':                'Lie down for a brief rest',
    'choiceBreathSearch':               'Search around the ancient tree roots',
    'choiceBreathSearchCost':           '−3 Stamina',
    'choiceBreathPray':                 'Pray beneath the shaft of light',
    'choiceBreathContinue':             'Keep moving',

    // Outcomes – Extinguish lantern
    'outcomeBreathLanternSuccessTitle': '[Success]',
    'outcomeBreathLanternSuccessDesc':  'The pale shaft of light lasts long enough. You conserve 15% lantern oil and let your body soak in the natural warmth, slowly recovering your strength.',
    'outcomeBreathLanternPanicTitle':   '[Obscured by Cloud]',
    'outcomeBreathLanternPanicDesc':    'The moment you snuff the flame, the sky dims without warning. The shaft of light vanishes and darkness lunges forward. You scramble to relight the lantern in a panic. Nothing saved, and the brief heart-shock gnaws away at your sanity.',
    'outcomeBreathLanternAmbushTitle':  '[Enemy Fears the Light]',
    'outcomeBreathLanternAmbushDesc':   'The instant the flame dies, a timid creature that had been lurking in a nearby shadow lunges straight at you. Prepare to fight — the enemy strikes first.',

    // Effect labels
    'effectLabelLantern':               'Lantern',
    'effectLabelStamina':               'Stamina',
    'effectLabelSanity':                'Sanity',
    'effectLabelCombat':                '⚔ Combat! Enemy strikes first.',
    'effectLabelHp':                    'HP',
    'effectLabelMaxHp':                 'Max HP (permanent)',
    'effectLabelPoison':                '☠ Poisoned',
    'effectLabelBleeding':              '🩸 Bleeding',
    'effectLabelBloodlust':             '🔥 Bloodlust',
    'effectLabelMaterial':              'Random Material',
    'effectLabelEpicMaterial':          '✦ Random Epic Material',
    'effectLabelSanityFull':            '✦ Sanity Fully Restored',
    'effectLabelTurns':                 'turns',

    // breathOfSilence event – Choice 2: Sleep outcomes
    'outcomeBreathSleepPeacefulTitle':  'PEACEFUL REST',
    'outcomeBreathSleepPeacefulDesc':   'You rest your head and close your eyes in the dead land. Nothing disturbs you. You wake feeling lighter in body and mind.',
    'outcomeBreathSleepParasitesTitle': 'OVERNIGHT PARASITES',
    'outcomeBreathSleepParasitesDesc':  'You manage to sleep, but wake to burning welts along your arm. Something used you as a host through the night.',
    'outcomeBreathSleepProphecyTitle':  'PROPHETIC DREAM',
    'outcomeBreathSleepProphecyDesc':   'You drift into a strange dream. A disembodied voice whispers of death and rebirth. When you wake, something valuable of unknown origin rests in your palm.',

    // breathOfSilence event – Choice 3: Scavenge outcomes
    'outcomeBreathScavengeSuccessTitle': 'SUCCESSFUL SCAVENGE',
    'outcomeBreathScavengeSuccessDesc':  'You rummage through the surrounding rubble and find some useful materials buried in the ash.',
    'outcomeBreathScavengeDespairTitle': 'EMPTY-HANDED',
    'outcomeBreathScavengeDespairDesc':  'You search for a long time and find nothing of value. Only bone fragments and dead men\'s memories. Despair begins to gnaw at your mind.',
    'outcomeBreathScavengeTrapTitle':    'HIDDEN TRAP',
    'outcomeBreathScavengeTrapDesc':     'Your hand pulls at a metal rod and — CRACK — a spring trap fires. Blood soaks through your sleeve.',

    // breathOfSilence event – Choice 4: Pray outcomes
    'outcomeBreathPraySolaceTitle':      'SOLACE FROM THE VOID',
    'outcomeBreathPraySolaceDesc':       'You kneel and pray in silence. No one listens. Yet strangely, your anxiety dissolves on its own. Your mind becomes clear.',
    'outcomeBreathPrayDespairTitle':     'THE VOID ANSWERS',
    'outcomeBreathPrayDespairDesc':      'You pray and wait. Nothing happens. The absolute silence shreds your mind more than any answer ever could.',
    'outcomeBreathPrayDarkgodTitle':     'THE ANCIENT GOD ANSWERS',
    'outcomeBreathPrayDarkgodDesc':      'Something answers your prayer — not the God of Light. Your veins burn hot, bloodlust brewing in your bones. But a part of your flesh has become an offering.',

    'hudDay': 'DAY',
    'hudLantern': 'LANTERN',

    // Rest result screen
    'restResultTitle': 'REST RESULT',
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
    'nightEventSuddenDeathDoorTitle': "SUDDEN DEATH'S DOOR",
    'nightEventSuddenDeathDoorDesc': 'The absolute dark seeped through your skin. You jolt awake, heart hammering, mouth parched. Only a single, feeble heartbeat still anchors you to the living. The terror of this night will not easily release its grip on you tomorrow.',

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

    // Combat screen (placeholder)
    'combatTitle': 'COMBAT',
    'combatGroggyWarning': '[Groggy] — You were woken violently!\nYou lose the first turn. Stamina recovered only 50%.',
    'combatComingSoon': '[ Combat system is under construction ]',
    'combatFlee': '[ FLEE ]',
    'combatPrepFight': '[ FIGHT ]',

    // Monster data
    'monsterMimickingCorpseName':     'THE MIMICKING CORPSE',
    'monsterMimickingCorpseSubtitle': 'Thi Thể Nhại Tiếng',
    'monsterMimickingCorpseDesc':
        'As the wooden door creaked open, the figure outside was no human huddled in the cold. '
        'A tattered cloak slipped away to reveal a frozen corpse. '
        'Its throat had been slashed open, where a cluster of parasitic root tendrils '
        'from some wicked growth had burrowed into the vocal cords to mimic human speech. '
        'The moment it sensed the lantern\u2019s light, the root cluster erupted into '
        'razor-sharp tentacles and lunged straight for you.',

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
    'charDescStr': 'Affects physical attack damage.',
    'charDescVit': 'Affects max HP.',
    'charDescAgi': 'Affects attack speed and dodge chance.',
    'charDescWill': 'Affects max Stamina and resistance to debuffs.',

    // Defense – composite stat
    'charStatDef': 'Defense',
    'charDescDef':
        'Reduces damage received in combat.\nIncreases via: Lumber Haul training (+1/level), Equipment, Skills.',

    // Attack – composite stat
    'charStatAttack': 'Attack',
    'charDescAttack':
        'Total attack power = Strength + Weapon bonus.\nLevel up Strength or equip a better weapon.',
    'charDescDefTotal':
        'Base Defense + Armor bonus.\nLevel up Vitality or equip better armor.',

    // Stat descriptions (Hidden)
    'charDescHumanity':
        'Determines whether you are seen as \'Human\' or \'Demon\'.\nAffects quests and story endings.',
    'charDescSanity':
        'Decreases from horror events or prolonged darkness.\nBelow 30, hallucinations appear in combat.',
    'charDescRealm':
        'Reflects your level of awakening and latent power.\nHigher Realm unlocks unique paths and secrets.',

    // ── Items – Names ────────────────────────────────────────────────────────

    // ── Items – Descriptions ─────────────────────────────────────────────────

    // Bone Lantern
    'item_bone_lantern_name': 'Bone Lantern',
    'item_bone_lantern_desc':
        'A strange lantern assembled from human bones. It cannot be destroyed, cannot be discarded. It burns on — until you have no more fuel to give.',
    // ── Crafting Materials ────────────────────────────────────────────────

    // Tier 1 – Common
    'item_rough_iron_scrap_name': 'Rough Iron Scrap',
    'item_rough_iron_scrap_desc':
        'A warped, tarnished lump of metal. The surface is coarse and riddled with shallow scratches, its edges jagged with uneven notches.',
    'item_rusty_nail_name': 'Rusty Nail',
    'item_rusty_nail_desc':
        'A crude metal spike with a flattened, lopsided head. The entire shaft is pitted and eaten through, raised patches of dark rust clinging to every surface.',

    // Tier 2 – Uncommon
    'item_old_grindstone_name': 'Old Grindstone',
    'item_old_grindstone_desc':
        'A rough, oval-shaped grey stone. The outer rim is chipped in many places, while the center has worn into a polished hollow, bright and scored with faint crisscrossing grooves.',
    'item_broken_armor_piece_name': 'Broken Armor Piece',
    'item_broken_armor_piece_desc':
        'A warped metal plate torn apart at the edges. Across its uneven surface cling a few worn rivets and a deep slash cut clean across the middle.',

    // Tier 3 – Rare
    'item_iron_chains_name': 'Iron Chains',
    'item_iron_chains_desc':
        'A short length of chain made from broad, heavy links locked together. The surface is crusted in a thick layer of grime — black, dense, and cold to the touch.',
    'item_steel_ore_name': 'Steel Ore',
    'item_steel_ore_desc':
        'An angular, jagged mass of raw rock. Breaking through the coarse outer shell are patches of dull metal crystal that catch the light with a cold, hard sheen.',
    'item_blast_powder_jar_name': 'Blast Powder Jar',
    'item_blast_powder_jar_desc':
        "A small, rough ceramic jar sealed tight with a coarse cork stopper. A crude 'X' has been scratched into the outer surface with a careless hand.",

    // Tier 4 – Epic
    'item_pure_silver_ore_name': 'Pure Silver Ore',
    'item_pure_silver_ore_desc':
        'A cluster of sharp crystals jutting from a base of pitch-black stone. Their surfaces are glassy and razor-bright — a complete contrast to the rough, cracked shell surrounding them.',
    'item_mechanical_components_name': 'Mechanical Components',
    'item_mechanical_components_desc':
        'A compact cluster of precision parts, its serrated gears meshing tight against one another. Every coil of the attached spring is perfectly even — cold and precise to the last fraction.',

    // Tier 5 – Legendary
    'item_rare_steel_ore_name': 'Rare Steel Ore',
    'item_rare_steel_ore_desc':
        'A dense block of metal, dark and smooth as glass. Beneath its still surface, faint veins twist and spiral inward, hinting at a structure compressed to its absolute limit.',
    'item_pure_gold_block_name': 'Pure Gold Block',
    'item_pure_gold_block_desc':
        'A rectangular ingot cast to perfect dimensions. Not a single scratch marks its flawless surface, and its edges are sheared with a precision that feels almost unnatural.',

    // ── Organic & Biological Materials ────────────────────────────────────

    // Tier 1 – Common
    'item_raw_animal_hide_name': 'Raw Animal Hide',
    'item_raw_animal_hide_desc':
        'A thin, crinkled pelt, dull and washed out. The outer edges are ragged and uneven, the slack surface still clinging to a few tattered wisps of coarse hair and rough scrape marks from a careless flaying.',
    'item_thorny_rope_coil_name': 'Thorny Rope Coil',
    'item_thorny_rope_coil_desc':
        'A dull-colored rope wound tight into a bundle. Each strand is braided coarse and stiff, bristling with tiny, frayed thorns that prick and catch at anything they touch.',
    'item_animal_fat_name': 'Animal Fat',
    'item_animal_fat_desc':
        'A lumpy, greasy mass with a dull, murky off-white color. The surface is slick and wet, perpetually coated in a glossy, semi-congealed film that threatens to slip from your grip at any moment.',
    'item_mud_and_leaves_name': 'Mud and Leaves',
    'item_mud_and_leaves_desc':
        'A soggy, clumped mass of rotted brown-black. The damp earth is thick and cloying, pressing into shredded leaf matter — crushed, wilted, limp, and fibrous.',

    // Tier 2 – Uncommon
    'item_thick_warm_fur_name': 'Thick Warm Fur',
    'item_thick_warm_fur_desc':
        'A heavy, dense mat of animal fur. The undercoat is tightly woven and impenetrable, while the surface is shaggy, tangled, and slightly matted into dark, clumped tufts.',
    'item_resin_name': 'Resin',
    'item_resin_desc':
        'A thick, dark liquid pooled in a chipped wooden bowl. Its surface is viscous and tacky, slick with adhesive film, dotted with small clouded air bubbles trapped just beneath.',
    'item_leather_strap_name': 'Leather Strap',
    'item_leather_strap_desc':
        'A narrow, long-cut strip of leather with clean, straight edges. The surface is smooth and tough, yet deeply creased by time, the shaft pre-punched with small holes whose edges are worn and fraying.',
    'item_hard_oak_wood_name': 'Hard Oak Wood',
    'item_hard_oak_wood_desc':
        'A solid, unworked chunk of timber — heavy and dense. The rough surface shows dark, rippling grain lines running the full length of the shaft, broken up by protruding knots as hard and craggy as stone.',
    'item_beast_blood_vial_name': 'Beast Blood',
    'item_beast_blood_vial_desc':
        'A thick, viscous fluid so dark it is nearly black. Its surface is sluggish, filmed with a slick, persistent layer of murk that clings to the inside of the vial and radiates a damp, putrid feeling even at a glance.',

    // Tier 3 – Rare
    'item_sticky_tar_name': 'Sticky Tar',
    'item_sticky_tar_desc':
        'A pool of dense, pitch-black matter as viscous as liquid shadow. Its surface is sluggish and pliable, clinging with brutal tenacity — stretching into long, limp threads of adhesive whenever it is touched or peeled away.',
    'item_mutated_beast_tendon_name': 'Mutated Beast Tendon',
    'item_mutated_beast_tendon_desc':
        'A grey strip of tissue, coiled and twisted with pale strands pulled taut to breaking point. The grotesque sinew structure is locked in a state of brutal contraction, glazed in a thin, limp membrane of slime.',
    'item_beast_horn_name': 'Beast Horn',
    'item_beast_horn_desc':
        'A curved shard of spike, jagged and razor-sharp. The grey surface is rough and cracked through with savage, deep grooves, while the base is still encrusted in patches of black, coarse sediment.',
    'item_beast_bone_remnant_name': 'Beast Bone Remnant',
    'item_beast_bone_remnant_desc':
        'A pale, irregular fragment of bone, marked by bite and tear. The porous structure is crumbling, shedding a fine, murky dust that drifts loose from the deep fractures running through the shaft.',

    // Tier 4 – Epic
    'item_elite_monster_hide_name': 'Elite Monster Hide',
    'item_elite_monster_hide_desc':
        'An oversized slab of hide, thick and rigid as a natural plate of armor. The textured surface is embossed with coarse ridges, and though countless deep scars have been gouged into it, not a single puncture has broken all the way through.',
    'item_blood_crystal_name': 'Blood Crystal',
    'item_blood_crystal_desc':
        'A fractured, angular crystal with flat, razor-clean faces. Beneath the cold, lustrous exterior, dark veins swirl dense and congealed — like fossilized vessels suspended in solid form.',
    'item_wraith_hair_name': 'Wraith Hair',
    'item_wraith_hair_desc':
        'A frail, hovering wisp of thread, hazy and insubstantial as settling mist. Each strand is a pale ash-grey, drifting aimlessly, curling with a gentle, ice-cold grace — on the verge of dissolving the instant it meets a gaze.',

    // Tier 4 – Epic (continued)
    'item_broken_holy_relic_name': 'Broken Holy Relic',
    'item_broken_holy_relic_desc':
        'A dull-bronze religious symbol, bent and shattered beyond recognition. The surface is caked in soot and rotting moss, yet from within the deep fracture leaks a faint, pallid glow — like a final prayer that has not yet gone out.',
    'item_broken_silver_chalice_name': 'Broken Silver Chalice',
    'item_broken_silver_chalice_desc':
        'A grey, tarnished silver cup crushed out of shape, its rim chipped and its body scored with savage claw marks. The bowl is bone-dry, scaled with layers of dark sediment, radiating the distinctive icy chill of the underworld.',
    'item_dream_incense_powder_name': 'Dream Incense Powder',
    'item_dream_incense_powder_desc':
        'A fine powder that shimmers like the ash of dead stars. When still, it clumps like rotting sand — but the moment a single breath passes over it, it billows upward, dissolving into pale, drifting wisps of illusory smoke that hang suspended in the air.',

    // Tier 5 – Legendary
    'item_nightmare_fruit_name': 'Nightmare Fruit',
    'item_nightmare_fruit_desc':
        'A bizarre plant mass that pulses with the rhythm of a rotting heart. The outer skin is black and pitted, threaded with bloated root-veins gripping a sickly red-brown light seeping from within — nausea-inducing, and raising every hair on the skin.',
    'item_cleansing_tear_name': 'Cleansing Tear',
    'item_cleansing_tear_desc':
        'A single drop of liquid floating still and clear, so transparent it is nearly invisible. It is utterly immune to the dust and corruption around it, radiating a soft, pure white radiance — gentle and solitary in the dark.',
    'item_quartz_clockwork_parts_name': 'Quartz Clockwork Parts',
    'item_quartz_clockwork_parts_desc':
        'A compact cluster of precision mechanisms glowing beneath a cracked quartz shell. Hairline brass joints interlock with prismatic lenses, flickering cold sparks — so perfect they could not have been made by mortal hands.',
    'item_bone_lantern_fire_name': 'Bone Lantern Fire',
    'item_bone_lantern_fire_desc':
        'A pale-blue flame burning silently on a fragment of rotted bone. It gives off no heat, does not flicker in the wind — it simply burns cold, consuming the air around it with a ghastly, eternal spectral light.',
    'item_broken_royal_sword_name': 'Broken Royal Sword',
    'item_broken_royal_sword_desc':
        'A massive broken blade, its steel edge chipped and clouded with ruin. The hilt is wrapped in peeling gold plating, and the gemstone set in the grip has gone completely opaque after soaking too long in a cursed fog.',
    'item_rusted_king_armor_name': 'Rusted King Armor',
    'item_rusted_king_armor_desc':
        'A massive breastplate ravaged by time and malevolent force. Its layered steel plates are locked solid with red-brown rust, dented by countless killing blows, and still carry the suffocating weight and despair of a fallen dynasty.',
    'item_petrified_root_name': 'Petrified Root',
    'item_petrified_root_desc':
        'A gnarled root segment as hard as ancient flint. Its surface is ashen-grey, laced with dry, criss-crossing cracks, while its inner core glints with the residue of sap crystallized into razor-edged mineral.',
    'item_weeping_bow_frame_name': 'Weeping Bow Frame',
    'item_weeping_bow_frame_desc':
        'A bow stave fashioned from material that is half charred wood and half pale human bone. Its structure is warped and bent like a body convulsing in agony, and along its rim countless small hollows keen with savage, sobbing tones whenever the wind passes through.',
    'item_goliath_ruined_armor_name': "Goliath's Ruined Armor",
    'item_goliath_ruined_armor_desc':
        'A slab of super-heavy metal, crude and as broad as a boulder. Its surface is dented and gouged with the marks of sledgehammer blows that shattered it — radiating a crushing, brutish oppression even as it lies perfectly still.',
    'item_gold_dusted_shield_fragment_name': 'Gold-Dusted Shield Fragment',
    'item_gold_dusted_shield_fragment_desc':
        'A pitifully shattered corner of what was once a massive shield. Its rough surface is buried in grime and darkness, yet deep within the cracks seeps a brilliant gold dust that stubbornly glows on against the impenetrable black.',

    // Tier 6 – Mythic
    'item_evil_god_chain_name': 'Evil God\'s Binding Chain',
    'item_evil_god_chain_desc':
        'A massive, pitch-black length of chain that seems to devour any light that falls on it. Every link is smelted with sharp, fire-blazing forbidden script, endlessly grinding and groaning as if desperately restraining a bottomless, ancient rage.',
    'item_abyssal_shroud_fragment_name': 'Abyssal Shroud Fragment',
    'item_abyssal_shroud_fragment_desc':
        'A tattered strip of cloth, frail yet darker than darkness itself. It hangs like a living thing, ceaselessly weeping a dim, murky fog that carries with it bone-deep cold and the desolate breath of a buried end.',
    'item_players_own_blood_name': 'Your Own Blood',
    'item_players_own_blood_desc':
        'A hovering droplet of deep crimson, vivid to the point of pain. It spirals with fierce intensity, seething with the warmth of living essence — radiating a sharp, weighty, and profoundly sacred feeling, as though a fragment of a soul has just been torn violently from the chest.',

    'itemRarityUnique': 'UNIQUE',
    'itemRarityCommon': 'COMMON',
    'itemRarityUncommon': 'UNCOMMON',
    'itemRarityRare': 'RARE',
    'itemRarityEpic': 'EPIC',
    'itemRarityLegendary': 'LEGENDARY',
    'itemRarityMythic': 'MYTHIC',

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
    'itemEquip': 'EQUIP',
    'itemUnequip': 'UNEQUIP',
    'itemEquipped': 'Equipped',
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
    'groupWeapon': 'Weapon',
    'groupArmor': 'Armor',
    'groupMaterial': 'Material',

    // ── Status Effects ─────────────────────────────────────────────────────────────────────
    // Buff: Explore
    'statusTomorrowExploreBonus':     'Tomorrow''s Exploration',
    'statusTomorrowExploreBonusDesc': 'Increases item drop chance during the next exploration.',
    // Buff: Explore & Combat
    'statusShielded':                 'Shielded',
    'statusShieldedDesc':             'Immune to all debuffs during exploration and combat.',
    // Debuff: Explore & Training
    'statusRacingHeart':              'Racing Heart',
    'statusRacingHeartDesc':          'All stamina-costing actions during Exploration and Training cost double. Fades after 1 day.',
    'statusTightChest':               'Tight Chest',
    'statusTightChestDesc':           'All stamina-costing actions during Exploration and Training cost +5 extra. Fades after 1 day.',
    // Debuff: Combat
    'statusSleepy':                   'Drowsy',
    'statusSleepyDesc':               'The enemy always acts first during this battle.',
    'statusBleeding':          'Bleeding',
    'statusBleedingDesc':       'In combat, lose 2 HP at the start of each round. While exploring, each step forward or back costs 1 extra HP.',
    'statusInfection':          'Infection',
    'statusInfectionDesc':      'Max HP reduced by 5. Sleeping with Torn Leather Armor equipped causes 1 additional HP loss per night.',
    'statusPoisoned':           'Poisoned',
    'statusPoisonedDesc':       'In combat, lose 3 HP at the start of each round. Damage dealt to enemies reduced by 10%.',
    'statusFear':               'Fear',
    'statusFearDesc':           'Special skills are completely locked. Hit accuracy reduced by 20%.',
    'statusExhausted':          'Exhausted',
    'statusExhaustedDesc':      'Max stamina halved (−50%). Severely limits exploration and training activities.',
    'statusBurning':            'Burning',
    'statusBurningDesc':        'In combat, lose 5 HP at the start of each round. Outside combat, each time-consuming action costs 1 extra HP.',
    'statusDislocated':         'Dislocated',
    'statusDislocatedDesc':     'Action Value bar extended. The character acts very slowly; monsters may attack multiple rounds before your turn.',
    'statusBlurredVision':      'Blurred Vision',
    'statusBlurredVisionDesc':  'Each attack reduces hit accuracy by a random 5–15%. Very high chance to miss.',
    'statusSluggish':           'Sluggish',
    'statusSluggishDesc':       'Max stamina reduced by a fixed 5 points.',
    'statusPainSensitive':      'Pain Sensitive',
    'statusPainSensitiveDesc':  'Whenever HP is lost, Sanity is reduced by the same amount.',
    'statusCursedAnxiety':      'Cursed Anxiety',
    'statusCursedAnxietyDesc':  'Max sanity capped at 80%. Cannot reach the Lucid state (100% sanity).',
    'statusSuddenDeath':        'Sudden Death',
    'statusSuddenDeathDesc':    'Bypasses all Defense, armor, and death-immunity effects. HP immediately drops to 0.',

    // ── Buff ────────────────────────────────────────────────────────────────────────────────────────
    'statusBloodthirst':           'Bloodthirst',
    'statusBloodthirstDesc':       'Crit Rate increased by 50% throughout the battle.',
    'statusRegeneration':          'Regeneration',
    'statusRegenerationDesc':      'Automatically recover 5 HP at the start of each combat round.',
    'statusImmortal':              'Immortal',
    'statusImmortalDesc':          'HP cannot drop below 1 regardless of damage taken.',
    'statusEnergized':             'Energized',
    'statusEnergizedDesc':         'Physical damage dealt to enemies multiplied by 20%.',
    'statusIronSkin':              'Iron Skin',
    'statusIronSkinDesc':          'All incoming damage reduced by 5 points (minimum 0).',
    'statusFogImmunity':           'Fog Immunity',
    'statusFogImmunityDesc':       'Advancing into the fog does not reduce Lantern brightness.',
    'statusTirelessStep':          'Tireless Step',
    'statusTirelessStepDesc':      'Each step into the fog does not cost 5 Stamina.',
    'statusNightVision':           'Night Vision',
    'statusNightVisionDesc':       'No Sanity penalty while exploring with a Lantern below 70% brightness.',
    'statusImmunity':              'Status Immunity',
    'statusImmunityDesc':          'Completely blocks all debuff inflictions from monsters.',
    'statusPhantomStep':           'Phantom Step',
    'statusPhantomStepDesc':       'Chance of rolling a “Monster Encounter / Ambush” event while exploring drops to 0%.',
    'statusIronStomach':           'Iron Stomach',
    'statusIronStomachDesc':       'Side effects of Tier 1–2 food are nullified. Only receive Hunger and positive buffs.',
    'statusEerieLuck':             'Eerie Luck',
    'statusEerieLuckDesc':         'Loot rolls skip the basic pool; items drawn from high-tier pools or quantity doubled.',
    'statusCultistSense':          'Cultist Sense',
    'statusCultistSenseDesc':      'Roll chance for Interaction/Story events maximized, crowding out ordinary loot events.',
    'statusItemPreservation':      'Item Preservation',
    'statusItemPreservationDesc':  'If downed while exploring, no items are lost. 100% of gathered loot is retained.',

    // ── Training ───────────────────────────────────────────────────────────────────────
    'trainOptionStrength':      'Dry Weapon Swings',
    'trainOptionStrengthStat':  'Train Strength / Attack',
    'trainOptionEndurance':     'Lumber Hauling',
    'trainOptionEnduranceStat': 'Train Endurance / Defense & HP',
    'trainOptionMeditation':     'Fire Meditation',
    'trainOptionMeditationStat': 'Train Willpower / Stamina & Mind',
    'trainNotEnoughResources': 'Not enough resources to train',
    'trainMaxLevel':           'Already at max (Level 100) – no EXP gained',
    'trainExpLabel':           'Experience',
    'trainLevelUp':            'STAT INCREASED!',
    'trainBack':               '← BACK',
    'trainResultTitle':        'TRAINING RESULT',
    'trainResultContinue':     'CONTINUE',

    // ── Strength Training Random Events ──────────────────────────────────
    'trainStrEvNormalTitle':     'NORMAL',
    'trainStrEvNormalDesc':      'A smooth session. Muscles ache, but you feel a little stronger.',
    'trainStrEvInjuryTitle':     'PHYSICAL INJURY',
    'trainStrEvInjuryDesc':      'Wrong form dislocated your shoulder. The pain is searing.',
    'trainStrEvTraumaTitle':     'PSYCHOLOGICAL TRAUMA',
    'trainStrEvTraumaDesc':      'The shadows twist into mocking phantoms, laughing at your weakness.',
    'trainStrEvWeaponAccTitle':  'WEAPON ACCIDENT',
    'trainStrEvWeaponAccDesc':   'The weapon caught and sent a rusted shard straight into your wrist.',
    'trainStrEvBreakthruTitle':  'BREAKTHROUGH',
    'trainStrEvBreakthruDesc':   'You found the perfect form. Energy surges, washing away fatigue.',
    'trainStrEvFindTitle':       'ACCIDENTAL DISCOVERY',
    'trainStrEvFindDesc':        'The swing shattered a crumbling wall, revealing a hidden cache.',
    'trainStrEvAbyssTitle':      'THE ABYSS CALLS',
    'trainStrEvAbyssDesc':       'You black out for a moment, striking with murderous technique that is not yours.',
    'trainStrEvExhausTitle':     'PUSHED TO THE LIMIT',
    'trainStrEvExhausDesc':      'You collapse. Your body completely shuts down. Nothing more today.',
    'trainStrEvDangerTitle':     'DANGER ATTRACTED',
    'trainStrEvDangerDesc':      'The howling swing draws something outside. It charges in!',
    'trainStrEvBleedStatus':     '[Bleeding] 2 HP/turn × 3 turns',
    'trainStrEvStrainStatus':    '[Muscle Strain] −10 HP',
    'trainStrEvItemFound':       'Item revealed:',
    'trainStrEvStaminaDrained':  'Stamina dropped to 0!',
    'trainStrEvCombatWarning':   'COMBAT NOW! →',
    // ── Endurance Training Random Events ──────────────────────────────────────────────────────────────────────
    'trainEndEvNormalTitle':      'Calloused Flesh',
    'trainEndEvNormalDesc':       'You grit your teeth and heave the rotted ironwood beam onto your shoulder, staggering forward through the dark. Splinters and jagged stone edges cut into your skin, drawing blood. But after many repetitions, your breathing steadies, and your skin seems to have grown a little thicker against the cold.',
    'trainEndEvSpinalTitle':      'The Crack of Bone',
    'trainEndEvSpinalDesc':       'You misjudge the weight of the broken slab. Straining to lift it, a dry crack rings out from your spine. A searing pain shoots down your back, forcing your hands to drop — the slab crashes to the floor. You fall to your knees, drenched in cold sweat.',
    'trainEndEvHazardTitle':      'Enemy in the Dark Corner',
    'trainEndEvHazardDesc':       'You reach under the large stone to find a grip. Suddenly, a sharp pain shoots from your finger. You recoil just in time to glimpse a fat, many-legged creature with a slimy shell vanishing into the shadows. The bite begins to swell, oozing black pus.',
    'trainEndEvPsychTitle':       'Waking Nightmare',
    'trainEndEvPsychDesc':        'The weight on your shoulders is not only wood and stone. In the depths of exhaustion, you feel as though you are carrying the weight of past sins and the wronged souls who died horribly in this Church. The invisible burden crushes your will, leaving you gasping and trembling in panic.',
    'trainEndEvIronWillTitle':    'Will Beyond Limits',
    'trainEndEvIronWillDesc':     'Blood seeps from your shoulder, soaking through your tattered shirt. Yet strangely, the pain no longer holds you back. Your muscles contract and release in perfect rhythm, bearing the load like a primal instinct. You find stillness at the far edge of bodily torment. Your flesh is now as hard as the stone you carry.',
    'trainEndEvCaveTitle':        'Secret Beneath the Stone',
    'trainEndEvCaveDesc':         'When you overturn a massive beam that has lain still for years, the mould beneath peels away to reveal a small hollow carved deep into the Church\'s brick floor. You brush aside the loose earth and touch something strange. Someone hid this here before the age fell to ruin.',
    'trainEndEvBloodRockTitle':   'Sinister Symbiosis',
    'trainEndEvBloodRockDesc':    'You clutch the beam stained with your own blood. A numbness spreads. The rotted wood seems to grow roots, driving tiny moss-covered tendrils straight into your veins. You do not push it away — you crave the merging. Your body warps, becoming unnaturally solid, but your mind sinks one beat deeper into the Abyss.',
    'trainEndEvCrushedTitle':     'The Collapse',
    'trainEndEvCrushedDesc':      'Your vision blurs. Your trembling legs no longer obey your mind. The massive beam slips from your bare shoulders, dragging your whole body crashing down onto the cold stone floor. The heavy timber folds across your lower half. Your lungs tighten — you cannot draw a single breath. Today ends here.',
    'trainEndEvCollapseTitle':    'Death\'s Echo',
    'trainEndEvCollapseDesc':     'In a failed effort, you lose your grip and drop the great slab onto the broken brick floor. The dry crash — BOOM! — shatters the Safehouse\'s silence and carries out through the wall of fog. The mist at the entrance begins to coil. Rapid scraping sounds ring out. Something is breaking through the door.',
    'trainEndEvDislocStatus':     '[Dislocated] – reduced dodge and speed',
    'trainEndEvInfectionStatus':  '[Infection] – extra HP drain daily',
    // ── Meditation events ─────────────────────────────────────────────────
    'trainMedEvNormalTitle':              'Still Mind',
    'trainMedEvNormalDesc':               'The crackling fire pushes back the cold seeping through the fog outside. You close your eyes and let your breathing slow to match the rhythm of the flames. In that rare moment, everything — the fear, the noise beyond the door, the hollow hunger — fades away. Only stillness remains.',
    'trainMedEvPsychHallucinationTitle':  'Visions in the Ash',
    'trainMedEvPsychHallucinationDesc':   'The fire suddenly shifts to an unearthly blue. From within the smoke, a twisted face looks up at you — then dissolves the instant you blink. You are not sure what you just saw. But the feeling of being watched lingers, clinging to the back of your neck like an invisible hand.',
    'trainMedEvBurnInjuryTitle':          'The Heat That Burns',
    'trainMedEvBurnInjuryDesc':           'The bone-deep chill of the fog had deceived your senses — you sat too close to the fire without realising. By the time the smell of scorched skin reached you, a red welt had already marked your wrist. Small, but enough to sting with every movement.',
    'trainMedEvLanternFlickerTitle':      'Darkness Waiting',
    'trainMedEvLanternFlickerDesc':       'Though you never touched it, the lantern begins to tremble and then snuffs out for one full second. Darkness falls like a cold wet cloth. The campfire shrinks, looking small and feeble. When the lantern flares back to life, the fuel inside has drained away for no clear reason.',
    'trainMedEvEnlightenmentTitle':       'Mind Like a Clear Mirror',
    'trainMedEvEnlightenmentDesc':        'You close your eyes and sink into a strange state — not quite sleep, not quite waking. Every memory, every old wound, every fear drifts past like colourless ghosts. Then silence. When you open your eyes the fire still burns — but you are changed. Clearer. Lighter. Like a mirror that has just been wiped clean.',
    'trainMedEvAncientScriptTitle':       'Ancient Script in the Flame',
    'trainMedEvAncientScriptDesc':        'You stare into the heart of the fire, and within the curling smoke, strange glyphs begin to appear — not a hallucination, but as though carved into the air itself. You cannot read their meaning. Yet when you stand, your hand is clenched tightly around something you do not remember picking up.',
    'trainMedEvAbyssCallTitle':           'Whisper of the Ancient God',
    'trainMedEvAbyssCallDesc':            'The fire goes out. Total darkness — for one single second. And in that second, something whispers in your ear in a language that does not belong to humankind. You cannot parse each word, but the meaning seeps into your mind like water into dry earth: You have been seen. You will never be as you were.',
    'trainMedEvSoulWanderTitle':          'Lost in the Spirit Realm',
    'trainMedEvSoulWanderDesc':           'You sink into meditation too deep — so deep that your consciousness drifts free of your body. A long time later you jolt awake with the feeling of having completed a vast journey, though your flesh never moved. Every limb is hollow. Your stamina is utterly gone — as though your soul wandered too far and your body spent every last drop of strength to drag it home.',
    'trainMedEvShadowBetrayalTitle':      'The Shadow\'s Betrayal',
    'trainMedEvShadowBetrayalDesc':       'The fire surges unexpectedly, casting your shadow large across the wall behind you. But the shadow does not mimic your movements. It turns its head and looks at you. Then it steps out of the wall.',
    'trainMedEvBurnStatus':               '[Minor Burn] 1 HP/turn × 3 combat days',
    'trainMedEvLanternLoss':              'Darkness Licks the Flame (Lantern)',
    // ── Equipment stat labels ──────────────────────────────────────────────
    'itemStatGlancingHit':       'Glancing Hit',
    'itemStatBleedOnCrit':       'Bleed on Critical Hit',
    'itemStatTrainRisk':         'Increased training accident risk',
    'itemStatInfectionDrain':    'Infection extra HP drain',
  };
}
