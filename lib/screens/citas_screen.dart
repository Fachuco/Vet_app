import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  @override
  _CitasScreenState createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _citas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  Future<void> _cargarCitas() async {
    setState(() => _isLoading = true);
    
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    
    final response = await _supabase
        .from('citas')
        .select('''
          *,
          mascotas: mascota_id (nombre, especie)
        ''')
        .eq('usuario_id', userId)
        .order('fecha', ascending: true);
    
    if (mounted) {
      setState(() {
        _citas = response;
        _isLoading = false;
      });
    }
  }

  Future<void> _eliminarCita(String id) async {
    try {
      setState(() => _isLoading = true);
      
      final response = await _supabase
          .from('citas')
          .delete()
          .eq('id', id);
      
      if (response.error != null) throw Exception(response.error!.message);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cita eliminada correctamente')),
        );
        _cargarCitas();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Citas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final actualizado = await Navigator.pushNamed(context, '/citas/agregar');
              if (actualizado == true) _cargarCitas();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _citas.isEmpty
              ? const Center(child: Text('No tienes citas programadas'))
              : ListView.builder(
                  itemCount: _citas.length,
                  itemBuilder: (context, index) {
                    final cita = _citas[index];
                    final mascota = cita['mascotas'] ?? {};
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(mascota['nombre'] ?? 'Mascota no especificada'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fecha: ${cita['fecha'].toString().split('T')[0]}'),
                            Text('Hora: ${cita['hora']}'),
                            Text('Motivo: ${cita['motivo']}'),
                            if (cita['veterinario'] != null) 
                              Text('Veterinario: ${cita['veterinario']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final actualizado = await Navigator.pushNamed(
                                  context,
                                  '/citas/editar',
                                  arguments: cita,
                                );
                                if (actualizado == true) _cargarCitas();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _eliminarCita(cita['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}