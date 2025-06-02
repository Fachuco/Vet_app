import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_state.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../screens/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    final authState = Provider.of<AuthState>(context);

    if (authState.user == null) {
      return MaterialApp(
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Veterinaria App'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Iniciar Sesión'),
                  Tab(text: 'Registrarse'),
                ],
              ),
            ),
            body: const TabBarView(
              children: [
                LoginScreen(),
                RegisterScreen(),
              ],
            ),
          ),
        ),
      );
    } else {
      return const HomeScreen();
    }
  }
}