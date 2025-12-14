import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/usuario.dart';
import 'api_service.dart';

/// Servicio para manejar autenticación y sesión persistente
class AuthService {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserData = 'userData';

  // ========================================
  // LOGIN
  // ========================================

  /// Iniciar sesión
  static Future<Map<String, dynamic>> login(String rut, String contrasena) async {
    final result = await ApiService.login(rut, contrasena);

    if (result['success'] == true) {
      // Guardar sesión
      await _saveSession(result['user'] as Usuario);
    }

    return result;
  }

  // ========================================
  // SESIÓN PERSISTENTE
  // ========================================

  /// Guardar sesión del usuario
  static Future<void> _saveSession(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserData, jsonEncode(usuario.toJson()));
  }

  /// Verificar si hay sesión activa
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Obtener datos del usuario de la sesión
  static Future<Usuario?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_keyUserData);

    if (userDataString != null) {
      final userDataJson = jsonDecode(userDataString);
      return Usuario.fromJson(userDataJson);
    }

    return null;
  }

  /// Cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserData);
  }

  /// Actualizar datos del usuario en sesión
  static Future<void> updateUserData(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserData, jsonEncode(usuario.toJson()));
  }
}
