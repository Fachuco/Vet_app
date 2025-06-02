import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final _supabase = Supabase.instance.client;
  

  // Autenticación
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp(String email, String password) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;

  // Operaciones CRUD para Mascotas
  Future<List<Map<String, dynamic>>> getMascotas() async {
    return await _supabase.from('mascotas').select();
  }

  Future<Map<String, dynamic>> insertMascota(Map<String, dynamic> mascota) async {
    return await _supabase.from('mascotas').insert(mascota).select().single();
  }

  Future<Map<String, dynamic>> updateMascota(String id, Map<String, dynamic> mascota) async {
    return 
    await _supabase.from('mascotas').update(mascota).eq('id', id).select().single();
  }

  Future<void> deleteMascota(String id) async {
    await _supabase.from('mascotas').delete().eq('id', id);
  }

  // Operaciones CRUD para Citas
  Future<List<Map<String, dynamic>>> getCitas() async {
    return await _supabase.from('citas').select('''
      *, 
      mascotas: mascota_id (*)
    ''');
  }

  Future<Map<String, dynamic>> insertCita(Map<String, dynamic> cita) async {
    return await _supabase.from('citas').insert(cita).select().single();
  }

  Future<Map<String, dynamic>> updateCita(String id, Map<String, dynamic> cita) async {
    return await _supabase.from('citas').update(cita).eq('id', id).select().single();
  }

  Future<void> deleteCita(String id) async {
    await _supabase.from('citas').delete().eq('id', id);
  }
  
  Future<AuthResponse> registerUser({
  required String email,
  required String password,
  required String fullName,
  String? phone,
}) async {

  final authResponse = await _supabase.auth.signUp(
    email: email,
    password: password,
  );


  if (authResponse.user != null) {
    await _supabase.from('users').insert({
      'id': authResponse.user!.id, 
      'email': email,
      'full_name': fullName,
      'phone': phone,
    });
  }

  return authResponse;
}
}