import 'package:app_vet/screens/detalle_mascota_screen.dart';
import 'package:app_vet/screens/mascotas_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MascotasScreen extends StatefulWidget {
  const MascotasScreen({super.key});

  @override
  _MascotasScreenState createState() => _MascotasScreenState();
}

class _MascotasScreenState extends State<MascotasScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _mascotas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarMascotas();
  }

  Future<void> _cargarMascotas() async {
    setState(() => _isLoading = true);
    
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    
    final response = await _supabase
        .from('mascotas')
        .select()
        .eq('dueño_id', userId);
    
    if (mounted) {
      setState(() {
        _mascotas = response;
        _isLoading = false;
      });
    }
  }

  Future<void> _eliminarMascota(String id) async {
   try {

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No estás autenticado')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

     final mascotaResponse = await _supabase
        .from('mascotas')
        .select()
        .eq('id', id)
        .eq('dueño_id', userId)
        .maybeSingle();

         if (mascotaResponse == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mascota no encontrada o no tienes permisos')),
        );
      }
      return;
    }
    

    final citasResponse = await _supabase
        .from('citas')
        .select()
        .eq('mascota_id', id);
    
    if (citasResponse.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se puede eliminar: tiene citas asociadas'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    
    

    final response = await _supabase
        .from('mascotas')
        .delete()
        .eq('id', id);
    
    if (response.error != null) throw Exception(response.error!.message);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mascota eliminada correctamente')),
      );
      _cargarMascotas();
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
        title: const Text('Mis Mascotas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/mascotas/agregar'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _mascotas.isEmpty
              ? const Center(child: Text('No hay mascotas registradas'))
              : ListView.builder(
                  itemCount: _mascotas.length,
                  itemBuilder: (context, index) {
                    final mascota = _mascotas[index];
                    return ListTile(
                      title: Text(mascota['nombre']),
                      subtitle: Text('Edad: ${mascota['edad']} años'),
                         onTap: () => Navigator.push( 
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetalleMascotaScreen(
                          mascotaId: mascota['id'].toString(),
                              mascotaNombre: mascota['nombre'],
                        ),
                      ),
                    ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final actualizado = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MascotaFormScreen(mascota: mascota),
                ),
              );
              
              if (actualizado == true) {
                _cargarMascotas();
              }
            },
          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _eliminarMascota(mascota['id']),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}