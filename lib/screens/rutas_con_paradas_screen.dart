import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ruta.dart';
import '../models/parada.dart';
import '../services/firebase_service.dart';
import 'paradas_de_ruta_screen.dart';

class RutasConParadasScreen extends StatefulWidget {
  const RutasConParadasScreen({super.key});

  @override
  State<RutasConParadasScreen> createState() => _RutasConParadasScreenState();
}

class _RutasConParadasScreenState extends State<RutasConParadasScreen> {
  late Future<List<Ruta>> rutas;

  @override
  void initState() {
    super.initState();
    rutas = FirebaseService.getRutas(); // Cargar rutas desde Firestore
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutas con Paradas'),
      ),
      body: FutureBuilder<List<Ruta>>(
        future: rutas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron rutas.'));
          }

          final rutas = snapshot.data!;

          return ListView.builder(
            itemCount: rutas.length,
            itemBuilder: (context, index) {
              final ruta = rutas[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(ruta.nombre),
                  subtitle: Text('Paradas: ${ruta.paradas.length}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Aquí puedes navegar a la pantalla de paradas para esa ruta
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ParadasDeRutaScreen(ruta: ruta),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
