import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/img/harita10.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  reverse: true,
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 24,
                          right: 24,
                          top: 24,
                          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 40),
                            SizedBox(
                              height: 200,
                              width: 200,
                              child: CircularTextAnimation(),
                            ),
                            SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLogin = true;
                                    });
                                  },
                                  child: Text(
                                    "GİRİŞ YAP",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: _isLogin
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: _isLogin
                                          ? const Color.fromRGBO(
                                              247, 203, 202, 1)
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLogin = false;
                                    });
                                  },
                                  child: Text(
                                    "KAYIT OL",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: !_isLogin
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: !_isLogin
                                          ? const Color.fromRGBO(
                                              247, 203, 202, 1)
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 32),
                            _isLogin ? _buildLoginForm() : _buildRegisterForm(),
                            Spacer(), // Bu satır ekranın altına kadar esnetir
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hintText, bool obscureText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
        decoration: InputDecoration(
            hintText: hintText,
            enabledBorder: OutlineInputBorder(
              // borderSide: BorderSide(color: Colors.lightGreen, width: 2.0),
              borderRadius: BorderRadius.circular(45),
            ),
            focusedBorder: OutlineInputBorder(
              // borderSide: BorderSide(color: Colors.lightGreen, width: 2.0),
              borderRadius: BorderRadius.circular(45),
            ),
            filled: true,
            fillColor: const Color.fromRGBO(241, 247, 247, 1),
            hintStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color.fromARGB(153, 0, 0, 0).withOpacity(0.5),
        borderRadius: BorderRadius.circular(45),
        border: Border.all(width: 0.3, color: Colors.white),
      ),
      child: Column(
        children: [
          _buildTextField(
            _loginEmailController,
            "Email",
            false,
          ),
          _buildTextField(_loginPasswordController, "Şifre", true),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color:
                  const Color.fromARGB(255, 0, 0, 0), // Kartın arka plan rengi
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 0, 0, 0).withOpacity(1),
                  spreadRadius: 7,
                  blurRadius: 20,
                  offset: Offset(0, 0), // Gölge pozisyonu (x, y)
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: _loginEmailController.text.trim(),
                    password: _loginPasswordController.text.trim(),
                  );
                  Navigator.pushNamed(context, '/home');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Giriş hatası: ${e.toString()}")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(247, 203, 202, 1),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: const Color.fromRGBO(247, 203, 203, 1),
                        width: 3.0),
                    borderRadius: BorderRadius.circular(45)),
              ),
              child: Text(
                "Giriş Yap",
                style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
        borderRadius: BorderRadius.circular(45),
        border: Border.all(width: 0.3, color: Colors.white),
      ),
      child: Column(
        children: [
          _buildTextField(_registerNameController, "Ad Soyad", false),
          _buildTextField(_registerEmailController, "Email", false),
          _buildTextField(_registerPasswordController, "Şifre", true),
          _buildTextField(_registerConfirmController, "Şifre Onayla", true),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.black, // Kartın arka plan rengi
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 0, 0, 0).withOpacity(1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: Offset(0, 0), // Gölge pozisyonu (x, y)
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () async {
                if (_registerPasswordController.text !=
                    _registerConfirmController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Şifreler uyuşmuyor!")),
                  );
                  return;
                }
                try {
                  UserCredential userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: _registerEmailController.text.trim(),
                    password: _registerPasswordController.text.trim(),
                  );
                  String name = _registerNameController.text.trim();
                  await userCredential.user!.updateDisplayName(name);
                  Navigator.pushNamed(context, '/login');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Kayıt hatası: ${e.toString()}")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(247, 203, 202, 1),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: const Color.fromRGBO(247, 203, 202, 1),
                        width: 3.0),
                    borderRadius: BorderRadius.circular(45)),
              ),
              child: Text(
                "Hesap Oluştur",
                style: TextStyle(color: const Color.fromARGB(255, 2, 2, 2)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CircularTextAnimation extends StatefulWidget {
  @override
  _CircularTextAnimationState createState() => _CircularTextAnimationState();
}

class _CircularTextAnimationState extends State<CircularTextAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 10))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String text = '  Smart Feed Back  ';
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * pi,
          child: child,
        );
      },
      child: CustomPaint(
        painter: CircularTextPainter(text),
      ),
    );
  }
}

class CircularTextPainter extends CustomPainter {
  final String text;

  CircularTextPainter(this.text);

  @override
  void paint(Canvas canvas, Size size) {
    double radius = size.width / 3.5;
    final anglePerChar = 2 * pi / text.length;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final angle = i * anglePerChar;
      final offset = Offset(
        radius * cos(angle) + size.width / 2,
        radius * sin(angle) + size.height / 2,
      );

      textPainter.text = TextSpan(
        text: char,
        style: GoogleFonts.delius(
          fontSize: 30,
          color: const Color.fromRGBO(241, 247, 247, 1),
          fontWeight: FontWeight.bold,
        ),
      );

      textPainter.layout();
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.rotate(angle + pi / 2);
      textPainter.paint(
          canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
