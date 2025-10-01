import 'dart:async';
// import 'dart:math';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 10))
          ..repeat();

    Timer(Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Siyah arka plan
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.asset(
            'assets/img/splash5.png',
            fit: BoxFit.cover,
          )),
          // Center(
          //   child: Padding(
          //     padding: const EdgeInsets.fromLTRB(0, 550, 0, 0),
          //     child: SizedBox(
          //       width: 75,
          //       height: 75,
          //       child: AnimatedBuilder(
          //         animation: _controller,
          //         builder: (_, child) {
          //           return Transform.rotate(
          //             angle: _controller.value * 2 * pi,
          //             child: child,
          //           );
          //         },
          //         child: CustomPaint(
          //           painter: CircularTextPainter('  Smart Feed Back  '),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
