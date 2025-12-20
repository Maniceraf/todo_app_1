import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:task_manager/app/entities/category.dart';
import 'package:task_manager/app/entities/task.dart';
import 'package:task_manager/app/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Register adapter sau khi generate
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(TaskAdapter());

  // Open boxes - không dùng generic type
  try {
    if (!Hive.isBoxOpen('categories')) {
      // Mở box không có generic type để tránh conflict
      await Hive.openBox('categories');
    }
    if (!Hive.isBoxOpen('tasks')) {
      await Hive.openBox('tasks');
    }
  } catch (e) {
    // Lỗi khi mở box
    try {
      // Đóng box nếu đang mở
      if (Hive.isBoxOpen('categories')) {
        await Hive.box('categories').close();
      }
      // Xóa box cũ và mở lại
      await Hive.deleteBoxFromDisk('categories');
      await Hive.openBox('categories');
    } catch (e2) {
      rethrow;
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const SplashPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
