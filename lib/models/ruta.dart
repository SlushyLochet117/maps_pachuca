import 'package:cloud_firestore/cloud_firestore.dart';

import 'parada.dart';

class Ruta {
  final String id;
  final String nombre;
  final List<Parada> paradas;

  Ruta({
    required this.id,
    required this.nombre,
    required this.paradas,
  });

  // Método para convertir de Firestore a Ruta
  factory Ruta.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    var paradas = <Parada>[];

    // Asegúrate de que las paradas se estén obteniendo correctamente
    if (data['paradas'] != null) {
      paradas = List<Parada>.from(
          data['paradas'].map((item) => Parada.fromMap(item)));
    }

    return Ruta(
      id: doc.id,
      nombre: data['nombre'],
      paradas: paradas,
    );
  }
}
