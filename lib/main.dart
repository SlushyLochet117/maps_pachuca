import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:maps_pachuca/screens/home_screen.dart';
import 'package:maps_pachuca/screens/login_screen.dart';
import 'package:maps_pachuca/screens/reset_password_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Movilidad',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(), // Pantalla inicial
      routes: {
        '/home': (context) => const HomeScreen(), // Ruta configurada
        '/register_screen': (context) => ResetPasswordScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
