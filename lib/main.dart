import 'package:flutter/material.dart';
import 'package:telecommande/screens/welcome_screen.dart';

void main() {
  runApp(const TelecommandeApp());
}

class TelecommandeApp extends StatelessWidget {
  const TelecommandeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Télécommande Voiture',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false,
      ),
      home: const WelcomeScreen(),
    );
  }
}
