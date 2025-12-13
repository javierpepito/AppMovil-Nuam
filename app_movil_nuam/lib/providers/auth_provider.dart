import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cuenta.dart';

class AuthProvider with ChangeNotifier {
  Cuenta? cuenta; // La cuenta logueada
  bool isLoading = false;
  String? error;

  /// Login usando rut y contraseña consultando la tabla `cuenta` de Supabase
  Future<bool> login(String rut, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final data = await Supabase.instance.client
          .from('cuenta')
          .select()
          .eq('rut', rut)
          .eq('contrasena', password)
          .maybeSingle();

      isLoading = false;

      if (data != null) {
        cuenta = Cuenta.fromJson(data as Map<String, dynamic>);
        error = null;
        notifyListeners();
        return true;
      } else {
        cuenta = null;
        error = "Credenciales inválidas";
        notifyListeners();
        return false;
      }
    } catch (e) {
      isLoading = false;
      cuenta = null;
      error = "Error en el inicio de sesión";
      notifyListeners();
      print('Error en login Supabase: $e');
      return false;
    }
  }

  void logout() {
    cuenta = null;
    notifyListeners();
  }
}