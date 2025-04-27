import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificacionesScreen extends StatelessWidget {
  const NotificacionesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Notificaciones')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notificaciones')
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar notificaciones'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notificaciones = snapshot.data!.docs;

          if (notificaciones.isEmpty) {
            return const Center(child: Text('No hay notificaciones aún.'));
          }

          return ListView.builder(
            itemCount: notificaciones.length,
            itemBuilder: (context, index) {
              final data = notificaciones[index].data() as Map<String, dynamic>;

              return ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(data['titulo'] ?? 'Sin título'),
                subtitle: Text(data['cuerpo'] ?? 'Sin contenido'),
                trailing: Text(
                  (data['fecha'] as Timestamp)
                      .toDate()
                      .toLocal()
                      .toString()
                      .split('.')[0],
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
