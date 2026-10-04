import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';

import 'core/network/dio_client.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier<ThemeMode>(
  ThemeMode.light,
);

/// Fungsi untuk beralih mode terang/gelap secara manual & menyimpan preferensi
Future<void> toggleAppTheme() async {
  final isDark = themeNotifier.value == ThemeMode.dark;
  final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
  themeNotifier.value = newMode;
  await StorageService.setDarkMode(!isDark);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi local storage
  await StorageService.init();
  await initializeDateFormatting('id_ID', null);

  // Memuat preferensi tema yang tersimpan (default ke Mode Terang)
  final isDark = await StorageService.isDarkMode();
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  // Setup handler sesi 401: Otomatis redirect ke login
  DioClient.onUnauthorized = () {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Presensi Digital PPKD',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          initialRoute: AppRoutes.splash,
          routes: AppRoutes.getRoutes(),
        );
      },
    );
  }
}
