import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';

class EditarDiagnosticoScreen extends StatefulWidget {
  final String mascotaId;
  final String visitaId;
  final String diagnosticoActual;
  final String veterinarioActual;

  const EditarDiagnosticoScreen({
    super.key,
    required this.mascotaId,
    required this.visitaId,
    required this.diagnosticoActual,
    required this.veterinarioActual,
  });

  @override
  State<EditarDiagnosticoScreen> createState() => _EditarDiagnosticoScreenState();
}

class _EditarDiagnosticoScreenState extends State<EditarDiagnosticoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _diagnosticoController;
  late TextEditingController _veterinarioController;

  @override
  void initState() {
    super.initState();
    _diagnosticoController = TextEditingController(text: widget.diagnosticoActual);
    _veterinarioController = TextEditingController(text: widget.veterinarioActual);
  }

  @override
  Widget build(BuildContext context) {
    final firestore = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Diagnóstico')),
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
                maxLines: 3,
              ),
              TextFormField(
                controller: _veterinarioController,
                decoration: const InputDecoration(labelText: 'Veterinario'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await firestore.editarDiagnostico(
                      mascotaId: widget.mascotaId,
                      visitaId: widget.visitaId,
                      nuevoDiagnostico: _diagnosticoController.text,
                      nuevoVeterinario: _veterinarioController.text,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}