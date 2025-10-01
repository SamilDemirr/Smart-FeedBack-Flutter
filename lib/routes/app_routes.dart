// import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';

// uygulama routelarını burada belirledim
class AppRoutes {
  static final routes = {
    '/login': (context) =>
        LoginScreen(), // uygulamamız ilk açılırken bu ekran gösterilecek
    '/home': (context) =>
        HomeScreen(), // daha sonra ilgili işlemler neticesinde bu ekrana geçilecek
    '/profile': (context) => ProfileScreen(), // kullanıcı profili ekranı
  };
}
