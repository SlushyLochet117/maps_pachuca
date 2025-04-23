import 'package:cloud_firestore/cloud_firestore.dart';

class Resena {
  final String id; // ID del documento de la reseña en Firestore
  final String paradaId;
  final String comentario;
  final int estrellas;
  final String autor;
  final DateTime? fecha;

  Resena({
    required this.id,
    required this.paradaId,
    required this.comentario,
    required this.estrellas,
    required this.autor,
    this.fecha,
  });

  /// Crear una reseña desde un mapa (usado al leer de Firestore)
  factory Resena.fromMap(String id, Map<String, dynamic> data) {
    return Resena(
      id: id,
      paradaId: data['paradaId'] ?? '',
      comentario: data['comentario'] ?? '',
      estrellas: (data['estrellas'] ?? 0).toInt(),
      autor: data['autor'] ?? 'Anónimo',
      fecha:
          data['fecha'] != null ? (data['fecha'] as Timestamp).toDate() : null,
    );
  }

  /// Convertir una reseña a un mapa (útil si la quieres guardar desde un objeto)
  Map<String, dynamic> toMap() {
    return {
      'paradaId': paradaId,
      'comentario': comentario,
      'estrellas': estrellas,
      'autor': autor,
      'fecha': fecha,
    };
  }
}
