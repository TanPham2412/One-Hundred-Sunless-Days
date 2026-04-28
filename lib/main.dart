import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one_hundred_sunless_days/screens/start_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Ẩn toàn bộ thanh hệ thống (status bar, navigation bar) – chế độ toàn màn hình
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'One Hundred Sunless Days',
      debugShowCheckedModeBanner: false,
      home: StartScreen(),
    );
  }
}
