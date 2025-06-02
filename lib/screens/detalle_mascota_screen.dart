import 'package:app_vet/screens/agregar_historial_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import 'editar_diagnostico_screen.dart';

class DetalleMascotaScreen extends StatelessWidget {
  final String mascotaId;
  final String mascotaNombre;

  const DetalleMascotaScreen({
    super.key,
    required this.mascotaId,
    required this.mascotaNombre,
  });

  void _editarDiagnostico(BuildContext context, DocumentSnapshot visita) {
    final data = visita.data() as Map<String, dynamic>;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditarDiagnosticoScreen(
          mascotaId: mascotaId,
          visitaId: visita.id,
          diagnosticoActual: data['diagnostico'],
          veterinarioActual: data['veterinario'],
        ),
      ),
    );
  }

  void _confirmarEliminacion(BuildContext context, String visitaId) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de eliminar este registro médico?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      final firestore = Provider.of<FirestoreService>(context, listen: false);
      try {
        await firestore.eliminarDiagnostico(
          mascotaId: mascotaId,
          visitaId: visitaId,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro eliminado correctamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestore = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Historial de $mascotaNombre')),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.obtenerHistorial(mascotaId),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final visitas = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: visitas.length,
            itemBuilder: (context, index) {
              final visita = visitas[index];
              final data = visita.data() as Map<String, dynamic>;
              final fecha = data['fecha'].toDate();
              final fechaFormateada = DateFormat('dd/MM/yyyy - HH:mm').format(fecha);

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  title: Text(
                    data['diagnostico'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text('Veterinario: ${data['veterinario']}'),
                      Text('Fecha: $fechaFormateada'),
                      if (data['ultimaEdicion'] != null)
                        Text(
                          'Última edición: ${DateFormat('dd/MM/yyyy - HH:mm').format(data['ultimaEdicion'].toDate())}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        onPressed: () => _editarDiagnostico(context, visita),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
                        onPressed: () => _confirmarEliminacion(context, visita.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AgregarHistorialScreen(mascotaId: mascotaId),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}