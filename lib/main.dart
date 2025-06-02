import 'package:app_vet/auth/login_screen.dart';
import 'package:app_vet/firebase_options.dart';
import 'package:app_vet/screens/citas_form_screen.dart';
import 'package:app_vet/screens/citas_screen.dart';
import 'package:app_vet/screens/home_screen.dart';
import 'package:app_vet/screens/mascotas_form_screen.dart';
import 'package:app_vet/screens/mascotas_screen.dart';
import 'package:app_vet/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth/auth_state.dart' as my_app;
import 'auth/auth_wrapper.dart';
import 'utils/constants.dart';

import 'package:flutter/foundation.dart' show kIsWeb;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kIsWeb) {
    FirebaseFirestore.instance.settings = Settings(
      persistenceEnabled: false, 
    );
  }


  try {
    await FirebaseFirestore.instance
        .collection('mascotas_historial')
        .doc('mascota_ejemplo')
        .collection('visitas')
        .add({
          'fecha': DateTime.now(),
          'diagnostico': 'Control anual',
          'veterinario': 'Dr. Pérez',
        });
  } catch (e) {
    debugPrint('Error al agregar documento de ejemplo: $e');
  }
  
  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
    authOptions: FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => my_app.AuthState()),
      Provider(create: (_) => FirestoreService()),
    ],
    child: const MyApp(),
  ),
);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veterinaria App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
       routes: {
      '/': (context) => const AuthWrapper(),
      '/login': (context) => const LoginScreen(),
      '/home': (context) => const HomeScreen(),
      '/mascotas': (context) => const MascotasScreen(),
      '/citas': (context) => const CitasScreen(),
      '/mascotas/agregar': (context) {
    final mascota = ModalRoute.of(context)!.settings.arguments as dynamic?;
    return MascotaFormScreen(mascota: mascota);
  },
      '/citas/agregar': (context) => const CitaFormScreen(),
      '/citas/editar': (context) {
      final cita = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return CitaFormScreen(cita: cita);
    },
  },
      
    );
  }
}