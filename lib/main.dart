import 'package:flutter/material.dart';
import 'package:gravity_2body_simplified/simul.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: simulGravity2bodySimplified(),
      ),
    );
  }
}
