import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/equipo_provider.dart';
import 'providers/calificacion_provider.dart';
import 'providers/estadisticas_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://zebxaifwzynjogkrpnye.supabase.co', // ← Pega aquí tu URL de proyecto
    anonKey: 'sb_publishable_MAWUgA0WD2eyjaQQvsSVDA_Fs0FvWYp',        // ← Y aquí tu anon key pública
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EquipoProvider()),
        ChangeNotifierProvider(create: (_) => CalificacionProvider()),
        ChangeNotifierProvider(create: (_) => EstadisticasProvider()),
      ],
      child: MaterialApp(
        title: 'App Jefe - NUAM',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
        },
      ),
    );
  }
}