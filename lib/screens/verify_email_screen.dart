import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _checkVerification() async {
    setState(() => _isLoading = true);
    await _auth.currentUser?.reload();
    if (_auth.currentUser?.emailVerified ?? false) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificar Email')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Por favor verifica tu correo electrónico'),
                  ElevatedButton(
                    onPressed: _checkVerification,
                    child: const Text('Ya verifiqué mi correo'),
                  ),
                ],
              ),
      ),
    );
  }
}
