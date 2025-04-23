class Parada {
  final String id;
  final String nombre;
  final double lat;
  final double lng;

  Parada({
    required this.id,
    required this.nombre,
    required this.lat,
    required this.lng,
  });

  // Método para convertir de Map a Parada
  factory Parada.fromMap(Map<String, dynamic> data) {
    return Parada(
      id: data['id'] ?? '',
      nombre: data['nombre'] ?? '',
      lat: data['lat'] ?? 0.0,
      lng: data['lng'] ?? 0.0,
    );
  }
}
