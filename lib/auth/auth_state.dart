import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_service.dart';

class AuthState extends ChangeNotifier {
  final SupabaseService _supabase = SupabaseService();
  User? _user;

  User? get user => _user;

  AuthState() {

    _user = _supabase.currentUser;
    


    notifyListeners();
  }


  Future<void> _loadCurrentUser() async {
    _user = _supabase.currentUser;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _supabase.signInWithEmail(email, password);
      _user = _supabase.currentUser; 
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      await _supabase.signUp(email, password);
      _user = _supabase.currentUser; 
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _supabase.signOut();
    _user = null;
    notifyListeners();
  }
}