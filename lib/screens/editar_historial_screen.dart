// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../services/firestore_service.dart';

// class EditarHistorialScreen extends StatefulWidget {
//   final String mascotaId;
//   final String visitaId;
//   final String diagnostico;
//   final String veterinario;

//   const EditarHistorialScreen({
//     super.key,
//     required this.mascotaId,
//     required this.visitaId,
//     required this.diagnostico,
//     required this.veterinario,
//   });

//   @override
//   State<EditarHistorialScreen> createState() => _EditarHistorialScreenState();
// }

// class _EditarHistorialScreenState extends State<EditarHistorialScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late final _diagnosticoController = TextEditingController(text: widget.diagnostico);
//   late final _veterinarioController = TextEditingController(text: widget.veterinario);

//   @override
//   Widget build(BuildContext context) {
//     final firestore = Provider.of<FirestoreService>(context);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Editar Registro')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _diagnosticoController,
//                 decoration: const InputDecoration(labelText: 'Diagnóstico'),
//                 validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
//               ),
//               TextFormField(
//                 controller: _veterinarioController,
//                 decoration: const InputDecoration(labelText: 'Veterinario'),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (_formKey.currentState!.validate()) {
//                     await firestore.editarVisita(
//                       mascotaId: widget.mascotaId,
//                       visitaId: widget.visitaId,
//                       diagnostico: _diagnosticoController.text,
//                       veterinario: _veterinarioController.text,
//                     );
//                     Navigator.pop(context);
//                   }
//                 },
//                 child: const Text('Guardar Cambios'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }