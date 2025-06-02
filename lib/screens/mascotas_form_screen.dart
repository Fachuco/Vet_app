import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MascotaFormScreen extends StatefulWidget {
  const MascotaFormScreen({super.key, this.mascota});

  final Map<String, dynamic>? mascota;

  @override
  _MascotaFormScreenState createState() => _MascotaFormScreenState();
}

class _MascotaFormScreenState extends State<MascotaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _especieController = TextEditingController();
  final _razaController = TextEditingController();
  final _edadController = TextEditingController();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.mascota != null) {
      _nombreController.text = widget.mascota?['nombre'] ?? '';
      _especieController.text = widget.mascota?['especie'] ?? '';
      _razaController.text = widget.mascota?['raza'] ?? '';
      _edadController.text = widget.mascota?['edad']?.toString() ?? '';
    }
  }
  

  Future<void> _guardarMascota() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);
  
  try {
   
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Usuario no autenticado');
    }

    final mascotaData = {
      'nombre': _nombreController.text,
      'especie': _especieController.text,
      'raza': _razaController.text,
      'edad': int.tryParse(_edadController.text) ?? 0,
      'dueño_id': userId, 
    };

    if (widget.mascota == null) {
     
      final response = await _supabase
          .from('mascotas')
          .insert(mascotaData)
          .select()
          .single();
      
      debugPrint('Mascota creada: ${response['id']}');
    } else {
      
      final response = await _supabase
          .from('mascotas')
          .update(mascotaData)
          .eq('id', widget.mascota!['id'])
          .select()
          .single();
      
      debugPrint('Mascota actualizada: ${response['id']}');
    }
    
    if (mounted) Navigator.pop(context, true);
  } on PostgrestException catch (e) {
    debugPrint('Error de Supabase: ${e.message}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error de base de datos: ${e.message}')),
    );
  } catch (e) {
    debugPrint('Error inesperado: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mascota == null ? 'Agregar Mascota' : 'Editar Mascota'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) => value!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _especieController,
                  decoration: const InputDecoration(labelText: 'Especie'),
                  validator: (value) => value!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _razaController,
                  decoration: const InputDecoration(labelText: 'Raza (opcional)'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _edadController,
                  decoration: const InputDecoration(labelText: 'Edad'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Requerido';
                    if (int.tryParse(value) == null) return 'Número inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _guardarMascota,
                          child: const Text('Guardar'),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}