import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgregarResenaScreen extends StatefulWidget {
  final String paradaId;

  const AgregarResenaScreen({super.key, required this.paradaId});

  @override
  State<AgregarResenaScreen> createState() => _AgregarResenaScreenState();
}

class _AgregarResenaScreenState extends State<AgregarResenaScreen> {
  int _estrellas = 3;
  final TextEditingController _comentarioController = TextEditingController();
  final TextEditingController _usuarioController = TextEditingController();

  void guardarResena() async {
    final comentario = _comentarioController.text.trim();
    final usuario = _usuarioController.text.trim().isEmpty
        ? "Anónimo"
        : _usuarioController.text.trim();

    await FirebaseFirestore.instance
        .collection('paradas')
        .doc(widget.paradaId)
        .collection('resenas')
        .add({
      'autor': usuario, // 👈 Nombre alineado con el modelo Resena
      'comentario': comentario,
      'estrellas': _estrellas,
      'paradaId': widget.paradaId,
      'fecha': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dejar Reseña'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Calificación:', style: TextStyle(fontSize: 16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return IconButton(
                  onPressed: () => setState(() => _estrellas = i + 1),
                  icon: Icon(
                    i < _estrellas ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 30,
                  ),
                );
              }),
            ),
            TextField(
              controller: _usuarioController,
              decoration:
                  const InputDecoration(labelText: 'Tu nombre (opcional)'),
            ),
            TextField(
              controller: _comentarioController,
              decoration: const InputDecoration(labelText: 'Comentario'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: guardarResena,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Guardar Reseña'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
