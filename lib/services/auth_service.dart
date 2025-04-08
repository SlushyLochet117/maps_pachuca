import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;

  // Login
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Error al iniciar sesión";
    }
  }

  // Registro
  Future<User?> register(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await userCredential.user?.sendEmailVerification();
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Error al registrar";
    }
  }

  // Enviar OTP (usando Phone Auth como workaround)
  Future<void> sendOTP(String email) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '+52XXXXXXXXXX', // Reemplaza con número real
      verificationCompleted: (_) {},
      verificationFailed: (e) => throw e.message ?? "Error OTP",
      codeSent: (verificationId, _) => _verificationId = verificationId,
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  // Cambiar contraseña con OTP
  Future<void> verifyOTPAndResetPassword(String otp, String newPassword) async {
    try {
      AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      await _auth.currentUser?.updatePassword(newPassword);
    } catch (e) {
      throw "Código inválido";
    }
  }

  // Verificar si el correo está confirmado
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }
}
