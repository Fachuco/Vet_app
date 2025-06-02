import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CitaFormScreen extends StatefulWidget {
  const CitaFormScreen({super.key, this.cita});

  final Map<String, dynamic>? cita;

  @override
  _CitaFormScreenState createState() => _CitaFormScreenState();
}

class _CitaFormScreenState extends State<CitaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _motivoController = TextEditingController();
  final _veterinarioController = TextEditingController();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;
  
  DateTime _fechaSeleccionada = DateTime.now();
  TimeOfDay _horaSeleccionada = TimeOfDay.now();
  String? _mascotaSeleccionadaId;
  List<dynamic> _mascotas = [];

  @override
  void initState() {
    super.initState();
    _cargarMascotas();
    
    if (widget.cita != null) {
      _motivoController.text = widget.cita!['motivo'];
      _veterinarioController.text = widget.cita!['veterinario'] ?? '';
      _fechaSeleccionada = DateTime.parse(widget.cita!['fecha']);
      _horaSeleccionada = _parseHora(widget.cita!['hora']);
      _mascotaSeleccionadaId = widget.cita!['mascota_id'];
    }
  }

  TimeOfDay _parseHora(String hora) {
    final partes = hora.split(':');
    return TimeOfDay(hour: int.parse(partes[0]), minute: int.parse(partes[1]));
  }

  Future<void> _cargarMascotas() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    
    final response = await _supabase
        .from('mascotas')
        .select()
        .eq('dueño_id', userId);
    
    if (mounted) {
      setState(() {
        _mascotas = response;
        if (_mascotaSeleccionadaId == null && _mascotas.isNotEmpty) {
          _mascotaSeleccionadaId = _mascotas.first['id'];
        }
      });
    }
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _fechaSeleccionada) {
      setState(() => _fechaSeleccionada = picked);
    }
  }

  Future<void> _seleccionarHora() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada,
    );
    if (picked != null && picked != _horaSeleccionada) {
      setState(() => _horaSeleccionada = picked);
    }
  }

  Future<void> _guardarCita() async {
    if (!_formKey.currentState!.validate()) return;
    if (_mascotaSeleccionadaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una mascota')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final citaData = {
      'mascota_id': _mascotaSeleccionadaId,
      'fecha': _fechaSeleccionada.toIso8601String(),
      'hora': '${_horaSeleccionada.hour}:${_horaSeleccionada.minute.toString().padLeft(2, '0')}',
      'motivo': _motivoController.text,
      'veterinario': _veterinarioController.text,
      'usuario_id': _supabase.auth.currentUser!.id,
    };

    try {
      if (widget.cita == null) {
        final response = await _supabase
            .from('citas')
            .insert(citaData)
            .select()
            .single();
        
        debugPrint('Cita creada: ${response['id']}');
      } else {
        final response = await _supabase
            .from('citas')
            .update(citaData)
            .eq('id', widget.cita!['id'])
            .select()
            .single();
        
        debugPrint('Cita actualizada: ${response['id']}');
      }
      
      if (mounted) Navigator.pop(context, true);
    } on PostgrestException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cita == null ? 'Agregar Cita' : 'Editar Cita'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _mascotaSeleccionadaId,
                  decoration: const InputDecoration(labelText: 'Mascota'),
                  items: _mascotas.map<DropdownMenuItem<String>>((mascota) {
                    return DropdownMenuItem<String>(
                      value: mascota['id'].toString(),
                      child: Text(mascota['nombre']),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _mascotaSeleccionadaId = value),
                  validator: (value) => value == null ? 'Selecciona una mascota' : null,
                ),
                const SizedBox(height: 20),
                ListTile(
                  title: const Text('Fecha'),
                  subtitle: Text('${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _seleccionarFecha,
                ),
                const SizedBox(height: 10),
                ListTile(
                  title: const Text('Hora'),
                  subtitle: Text(_horaSeleccionada.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: _seleccionarHora,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _motivoController,
                  decoration: const InputDecoration(labelText: 'Motivo de la cita'),
                  validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _veterinarioController,
                  decoration: const InputDecoration(labelText: 'Veterinario (opcional)'),
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _guardarCita,
                          child: const Text('Guardar Cita'),
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