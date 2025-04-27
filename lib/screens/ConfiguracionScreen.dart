import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';
import '../screens/perfil_screen.dart'; // <--- Agrega esta importación

class ConfiguracionScreen extends StatefulWidget {
  final void Function(bool)? toggleTheme;

  const ConfiguracionScreen({Key? key, this.toggleTheme}) : super(key: key);

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  bool _notificaciones = true;
  bool _modoOscuro = false;
  String _idioma = 'Español';

  @override
  void initState() {
    super.initState();
  }

  void _cambiarIdioma() {
    setState(() {
      _idioma = _idioma == 'Español' ? 'Inglés' : 'Español';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Idioma cambiado a $_idioma')),
    );
  }

  void _actualizarNotificaciones(bool value) {
    setState(() {
      _notificaciones = value;
    });
    if (value) {
      FirebaseMessaging.instance.subscribeToTopic('all');
    } else {
      FirebaseMessaging.instance.unsubscribeFromTopic('all');
    }
  }

  void _cambiarModoOscuro(bool value) {
    setState(() {
      _modoOscuro = value;
    });
    widget.toggleTheme?.call(value);
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
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Colors.blue[800],
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Notificaciones'),
            value: _notificaciones,
            onChanged: _actualizarNotificaciones,
            secondary: const Icon(Icons.notifications),
          ),
          SwitchListTile(
            title: const Text('Modo oscuro'),
            value: _modoOscuro,
            onChanged: _cambiarModoOscuro,
            secondary: const Icon(Icons.dark_mode),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Idioma'),
            subtitle: Text(_idioma),
            onTap: _cambiarIdioma,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Configuración de cuenta'),
            subtitle: const Text('Cambiar contraseña o eliminar cuenta'),
            onTap: _irAPerfil, // <-- Manda al PerfilScreen
          ),
        ],
      ),
    );
  }
}
