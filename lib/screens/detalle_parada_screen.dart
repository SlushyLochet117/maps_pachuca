import 'package:flutter/material.dart';
import '../models/resena.dart';
import '../services/firebase_service.dart';
import 'agregar_resena_screen.dart';

class DetalleParadaScreen extends StatelessWidget {
  final String paradaId;
  final String paradaNombre;

  const DetalleParadaScreen({
    super.key,
    required this.paradaId,
    required this.paradaNombre,
  });

  Future<List<Resena>> obtenerResenas() async {
    return await FirebaseService.obtenerResenasPorParada(paradaId);
  }

  Future<double> obtenerPromedio() async {
    final resenas = await FirebaseService.obtenerResenasPorParada(paradaId);
    if (resenas.isEmpty) return 0.0;

    final total = resenas.fold<int>(0, (sum, resena) => sum + resena.estrellas);
    return total / resenas.length;
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
                // Encabezado con botón de regreso
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      Expanded(
                        child: Text(
                          paradaNombre,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                FutureBuilder<double>(
                  future: obtenerPromedio(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '⭐ Promedio: ${snapshot.data!.toStringAsFixed(1)} / 5',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: FutureBuilder<List<Resena>>(
                    future: obtenerResenas(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
                      }

                      final resenas = snapshot.data!;

                      if (resenas.isEmpty) {
                        return const Center(
                          child: Text('No hay reseñas aún.', style: TextStyle(color: Colors.white70)),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: resenas.length,
                        itemBuilder: (context, index) {
                          final r = resenas[index];
                          return Card(
                            color: Colors.white10,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const Icon(Icons.person, color: Colors.white),
                              title: Text(
                                r.autor,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.comentario, style: const TextStyle(color: Colors.white70)),
                                  const SizedBox(height: 4),
                                  Text('⭐ ${r.estrellas} estrellas', style: const TextStyle(color: Colors.amber)),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.rate_review, color: Colors.black),
                      label: const Text(
                        'Agregar Reseña',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AgregarResenaScreen(paradaId: paradaId),
                          ),
                        ).then((_) {
                          // Recarga la pantalla al volver
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetalleParadaScreen(
                                paradaId: paradaId,
                                paradaNombre: paradaNombre,
                              ),
                            ),
                          );
                        });
                      },
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
