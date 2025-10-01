import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart/screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  if (kIsWeb) {
    // Firebase i web'te calistirabilmek icin gerekli bagımliliklar, asagidaki keyleri firebase uzerinden alınır
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCz608a4XG90Os1VVCnPhiIL045rVRvxNg",
        authDomain: "smartfeedback-62990.firebaseapp.com",
        projectId: "smartfeedback-62990",
        storageBucket: "smartfeedback-62990.firebasestorage.app",
        messagingSenderId: "967589434863",
        appId: "1:967589434863:web:98bd505b086539ac99921a",
      ),
    );
  } else {
    // Mobil emulatorde calistirmak icin klasik firebase baslatma kodu
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Uygulamanin ismi burada verilir
      title: 'Smart FeedBack',
      // Uygulamanın sag ust kisimda yer alan "debug" yazisini kaldırır
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      // Uygulamanin rotalarini belirler calistirikdiginde ilk hangi sayfayi acacagi burada belirlenir
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}
