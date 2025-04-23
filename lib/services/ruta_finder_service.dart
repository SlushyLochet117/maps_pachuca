import 'package:cloud_firestore/cloud_firestore.dart';

class RutaFinderService {
  static Future<List<Map<String, dynamic>>> buscarRutasConOrigenYDestino(
      String origen, String destino) async {
    final snapshot = await FirebaseFirestore.instance.collection('rutas').get();

    List<Map<String, dynamic>> rutasValidas = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final paradas = List<Map<String, dynamic>>.from(data['paradas']);

      final contieneOrigen = paradas.any((p) =>
          (p['nombre'] as String).toLowerCase().contains(origen.toLowerCase()));
      final contieneDestino = paradas.any((p) => (p['nombre'] as String)
          .toLowerCase()
          .contains(destino.toLowerCase()));

      if (contieneOrigen && contieneDestino) {
        rutasValidas.add(data);
      }
    }

    return rutasValidas;
  }
}
