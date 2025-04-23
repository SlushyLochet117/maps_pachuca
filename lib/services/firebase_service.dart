import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ruta.dart';
import '../models/parada.dart';
import '../models/resena.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtener todas las rutas desde Firestore
  static Future<List<Ruta>> getRutas() async {
    final snapshot = await _firestore.collection('rutas').get();
    return snapshot.docs.map((doc) => Ruta.fromFirestore(doc)).toList();
  }

  /// Obtener una ruta específica por ID
  static Future<Ruta?> getRutaById(String id) async {
    final doc = await _firestore.collection('rutas').doc(id).get();
    if (!doc.exists) return null;
    return Ruta.fromFirestore(doc);
  }

  /// Guardar una reseña en una parada específica
  static Future<void> guardarResena(Resena resena) async {
    await _firestore
        .collection('paradas')
        .doc(resena.paradaId)
        .collection('resenas')
        .add({
      'paradaId': resena.paradaId,
      'comentario': resena.comentario,
      'estrellas': resena.estrellas,
      'autor': resena.autor,
      'fecha': FieldValue.serverTimestamp(),
    });
  }

  /// Obtener todas las reseñas asociadas a una parada específica
  static Future<List<Resena>> obtenerResenasPorParada(String paradaId) async {
    try {
      final snapshot = await _firestore
          .collection('paradas')
          .doc(paradaId)
          .collection('resenas')
          .orderBy('fecha', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No hay reseñas para la parada $paradaId');
        return [];
      }

      return snapshot.docs
          .map((doc) => Resena.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error al obtener reseñas para la parada $paradaId: $e');
      return [];
    }
  }
}
