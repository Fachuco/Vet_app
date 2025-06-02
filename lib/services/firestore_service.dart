import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Añadir registro
  Future<void> agregarHistorial({
    required String mascotaId,
    required String diagnostico,
    required String veterinario,
  }) async {
    await _firestore
        .collection('mascotas_historial')
        .doc(mascotaId)
        .collection('visitas')
        .add({
          'fecha': FieldValue.serverTimestamp(),
          'diagnostico': diagnostico,
          'veterinario': veterinario,
        });
  }

  // Obtener historial
  Stream<QuerySnapshot> obtenerHistorial(String mascotaId) {
    return _firestore
        .collection('mascotas_historial')
        .doc(mascotaId)
        .collection('visitas')
        .orderBy('fecha', descending: true)
        .snapshots();
  }

  // Editar diagnóstico
  Future<void> editarDiagnostico({
    required String mascotaId,
    required String visitaId,
    required String nuevoDiagnostico,
    required String nuevoVeterinario,
  }) async {
    await _firestore
        .collection('mascotas_historial')
        .doc(mascotaId)
        .collection('visitas')
        .doc(visitaId)
        .update({
          'diagnostico': nuevoDiagnostico,
          'veterinario': nuevoVeterinario,
          'ultimaEdicion': FieldValue.serverTimestamp(),
        });
  }

  // Eliminar diagnóstico
  Future<void> eliminarDiagnostico({
    required String mascotaId,
    required String visitaId,
  }) async {
    await _firestore
        .collection('mascotas_historial')
        .doc(mascotaId)
        .collection('visitas')
        .doc(visitaId)
        .delete();
  }
}