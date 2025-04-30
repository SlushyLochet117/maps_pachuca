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
      'autor': usuario,
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
      body: Stack(
        children: [
          _buildGradientBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Botón regresar y título
                  Row(
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
                      const Expanded(
                        child: Text(
                          'Dejar Reseña',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Calificación
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Calificación:',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return IconButton(
                        onPressed: () => setState(() => _estrellas = i + 1),
                        icon: Icon(
                          i < _estrellas ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 16),

                  // Nombre
                  TextField(
                    controller: _usuarioController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Tu nombre (opcional)',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Comentario
                  TextField(
                    controller: _comentarioController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Comentario',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Botón guardar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: guardarResena,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Guardar Reseña',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
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
