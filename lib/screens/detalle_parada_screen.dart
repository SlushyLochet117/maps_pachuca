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
      appBar: AppBar(
        title: Text(paradaNombre),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<List<Resena>>(
        future: obtenerResenas(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final resenas = snapshot.data!;

          return Column(
            children: [
              FutureBuilder<double>(
                future: obtenerPromedio(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Container();
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '⭐ Promedio: ${snapshot.data!.toStringAsFixed(1)} / 5',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
              Expanded(
                child: resenas.isEmpty
                    ? const Center(child: Text('No hay reseñas aún.'))
                    : ListView.builder(
                        itemCount: resenas.length,
                        itemBuilder: (context, index) {
                          final r = resenas[index];
                          return ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(r.autor),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.comentario),
                                Text(
                                  '⭐ ${r.estrellas} estrellas',
                                  style: const TextStyle(color: Colors.amber),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.rate_review),
                  label: const Text('Agregar Reseña'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AgregarResenaScreen(paradaId: paradaId),
                      ),
                    ).then((_) {
                      // Refresca esta pantalla al volver
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
            ],
          );
        },
      ),
    );
  }
}
