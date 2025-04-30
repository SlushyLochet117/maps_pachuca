import 'package:flutter/material.dart';
import '../models/ruta.dart';
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
      body: Stack(
        children: [
          _buildGradientBackground(),
          SafeArea(
            child: Column(
              children: [
                // Botón y título
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
                          'Rutas con Paradas',
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
                  child: FutureBuilder<List<Ruta>>(
                    future: rutas,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('No se encontraron rutas.', style: TextStyle(color: Colors.white70)),
                        );
                      }

                      final rutas = snapshot.data!;

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: rutas.length,
                        itemBuilder: (context, index) {
                          final ruta = rutas[index];
                          return Card(
                            color: Colors.white10,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(
                                ruta.nombre,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Paradas: ${ruta.paradas.length}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
                              onTap: () {
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
                ),
              ],
            ),
          ),
        ],
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