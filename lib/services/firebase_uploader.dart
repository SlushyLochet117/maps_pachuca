import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> subirRutasTest() async {
  final rutas = [
    {
      'nombre': 'Ruta Centro - Zona Plateada',
      'paradas': [
        {'nombre': 'Centro', 'lat': 20.123, 'lng': -98.734},
        {'nombre': 'Niños Héroes', 'lat': 20.124, 'lng': -98.736},
        {'nombre': 'Zona Plateada', 'lat': 20.127, 'lng': -98.740},
      ]
    },
    {
      'nombre': 'Ruta Tuzobús',
      'paradas': [
        {'nombre': 'Estación Central', 'lat': 20.121, 'lng': -98.732},
        {'nombre': 'Estación Universidad', 'lat': 20.125, 'lng': -98.738},
      ]
    },
  ];

  for (var ruta in rutas) {
    await FirebaseFirestore.instance.collection('rutas').add(ruta);
  }

  print('✅ Rutas subidas correctamente');
}
