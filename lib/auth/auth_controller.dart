import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'dart:io'; // Para SocketException
import 'dart:async'; // Para TimeoutException

class AuthController {
  final supabase.SupabaseClient _supabase;
  final InternetConnectionChecker _connectionChecker;

  AuthController()
      : _supabase = supabase.Supabase.instance.client,
        _connectionChecker = InternetConnectionChecker();

  Future<supabase.User?> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return response.user;
    } on supabase.AuthException catch (e) {
      throw _handleSupabaseError(e);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  Future<supabase.User?> register(String email, String password, String nombre) async {
    try {
      // 1. Verificar conexión a internet
      final hasConnection = await _connectionChecker.hasConnection;
      if (!hasConnection) {
        throw const SocketException('No internet connection');
      }

      // 2. Registrar en Supabase con timeout
      final authResponse = await _supabase.auth
          .signUp(
            email: email.trim(),
            password: password,
            data: {'nombre': nombre},
          )
          .timeout(const Duration(seconds: 15));

      if (authResponse.user == null) {
        throw Exception('No se pudo crear el usuario');
      }

      // 3. Guardar datos adicionales en tabla dueños
      final response = await _supabase.from('dueños')
          .insert({
            'id': authResponse.user!.id,
            'nombre': nombre,
            'email': email,
          })
          .timeout(const Duration(seconds: 10));

      if (response.error != null) {
        throw Exception('Error en Supabase: ${response.error!.message}');
      }

      return authResponse.user;
    } on SocketException {
      throw 'Sin conexión a internet. Verifica tu red';
    } on TimeoutException {
      throw 'El servidor no respondió a tiempo';
    } on supabase.AuthException catch (e) {
      throw _handleSupabaseError(e);
    } catch (e) {
      throw 'Error al registrar: $e';
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  String _handleSupabaseError(supabase.AuthException e) {
    switch (e.statusCode) {
      case '400':
        return 'Credenciales inválidas';
      case '422':
        return 'Datos de registro inválidos';
      case '500':
        return 'Error del servidor';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }

  supabase.User? get currentUser => _supabase.auth.currentUser;
  Stream<supabase.User?> get authStateChanges => _supabase.auth.onAuthStateChange.map((event) => event.session?.user);
}