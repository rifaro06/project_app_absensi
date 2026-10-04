import 'package:flutter/material.dart';

import '../views/auth/login_page.dart';
import '../views/auth/register_page.dart';
import '../views/main_wrapper_page.dart';
import '../views/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginPage(),
      register: (context) => const RegisterPage(),
      home: (context) => const MainWrapperPage(),
    };
  }
}
