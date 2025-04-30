import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maps_pachuca/screens/login_screen.dart'; // Asegúrate de importar tu LoginScreen

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  Future<void> _signOut() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _customDialog(
        title: '¿Eliminar cuenta?',
        content: 'Esta acción no se puede deshacer. ¿Deseas continuar?',
        confirmText: 'Eliminar',
        confirmColor: Colors.redAccent,
      ),
    );

    if (confirmed != true) return;

    try {
      await user.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta eliminada')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        final success = await _reauthenticateUser();
        if (success) _deleteAccount();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    }
  }

  Future<bool> _reauthenticateUser() async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return false;

    final password = await _askForPassword();
    if (password == null) return false;

    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(cred);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String?> _askForPassword() async {
    final controller = TextEditingController();

    return await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmación requerida', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Contraseña',
            labelStyle: TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Aceptar')),
        ],
      ),
    );
  }

  Future<void> _sendPasswordResetEmail() async {
    final user = _auth.currentUser;
    if (user?.email == null) return;

    try {
      await _auth.sendPasswordResetEmail(email: user!.email!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo de recuperación enviado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar correo: $e')),
      );
    }
  }

  Future<void> _editProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final nameController = TextEditingController(text: user.displayName ?? '');

    await showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Editar perfil', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white10,
                      labelText: 'Nombre',
                      labelStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _uploadProfilePicture,
                    icon: const Icon(Icons.image, color: Colors.black),
                    label: const Text('Cambiar foto', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
                      ),
                      TextButton(
                        onPressed: () async {
                          await user.updateDisplayName(nameController.text.trim());
                          await user.reload();
                          setState(() {});
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Perfil actualizado')),
                          );
                        },
                        child: const Text('Guardar', style: TextStyle(color: Colors.greenAccent)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadProfilePicture() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final ref = FirebaseStorage.instance.ref().child('profile_pictures/${user.uid}.jpg');

    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    await user.updatePhotoURL(url);
    await user.reload();
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Foto actualizada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      body: Stack(
        children: [
          _buildGradientBackground(),
          SafeArea(
            child: Column(
              children: [
                // Botón de regreso
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Regresar',
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: user == null
                        ? const Center(child: Text('No hay usuario autenticado', style: TextStyle(color: Colors.white)))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: user.photoURL != null
                                    ? NetworkImage(user.photoURL!)
                                    : null,
                                backgroundColor: Colors.white10,
                                child: user.photoURL == null
                                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              Text(user.displayName ?? 'Sin nombre',
                                  style: const TextStyle(color: Colors.white, fontSize: 22)),
                              Text(user.email ?? '', style: const TextStyle(color: Colors.white70)),
                              const SizedBox(height: 30),
                              _profileOption(Icons.edit, 'Editar perfil', _editProfile),
                              _profileOption(Icons.lock_reset, 'Recuperar contraseña', _sendPasswordResetEmail),
                              _profileOption(Icons.logout, 'Cerrar sesión', _signOut, color: Colors.orangeAccent),
                              _profileOption(Icons.delete_forever, 'Eliminar cuenta', _deleteAccount, color: Colors.redAccent),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileOption(IconData icon, String label, Function() onTap, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.black),
        label: Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.greenAccent.shade400,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onTap,
      ),
    );
  }

  Widget _customDialog({
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
  }) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      content: Text(content, style: const TextStyle(color: Colors.white70)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: confirmColor),
          child: Text(confirmText),
        ),
      ],
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}