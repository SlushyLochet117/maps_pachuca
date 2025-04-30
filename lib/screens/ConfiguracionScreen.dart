import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../screens/perfil_screen.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({Key? key}) : super(key: key);

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  bool _notificaciones = true;

  void _actualizarNotificaciones(bool value) {
    setState(() => _notificaciones = value);
    if (value) {
      FirebaseMessaging.instance.subscribeToTopic('all');
    } else {
      FirebaseMessaging.instance.unsubscribeFromTopic('all');
    }
  }

  void _irAPerfil() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PerfilScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildGradientBackground(),
          SafeArea(
            child: Column(
              children: [
                // Botón regresar y título
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Configuración',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildSwitchTile(
                        icon: Icons.notifications,
                        title: 'Notificaciones',
                        value: _notificaciones,
                        onChanged: _actualizarNotificaciones,
                      ),
                      const Divider(color: Colors.white38),
                      _buildListTile(
                        icon: Icons.person,
                        title: 'Configuración de cuenta',
                        subtitle: 'Cambiar contraseña o eliminar cuenta',
                        onTap: _irAPerfil,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Card(
      color: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: SwitchListTile(
        activeColor: Colors.greenAccent,
        secondary: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.white70)) : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: onTap,
      ),
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