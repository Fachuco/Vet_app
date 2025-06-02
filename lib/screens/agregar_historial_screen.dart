import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/firestore_service.dart';

class AgregarHistorialScreen extends StatefulWidget {
  final String mascotaId;

  const AgregarHistorialScreen({super.key, required this.mascotaId});

  @override
  State<AgregarHistorialScreen> createState() => _AgregarHistorialScreenState();
}

class _AgregarHistorialScreenState extends State<AgregarHistorialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosticoController = TextEditingController();
  final _veterinarioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final firestore = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Registro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _diagnosticoController,
                decoration: const InputDecoration(labelText: 'Diagnóstico'),
                validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _veterinarioController,
                decoration: const InputDecoration(labelText: 'Veterinario'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await firestore.agregarHistorial(
                      mascotaId: widget.mascotaId,
                      diagnostico: _diagnosticoController.text,
                      veterinario: _veterinarioController.text,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}