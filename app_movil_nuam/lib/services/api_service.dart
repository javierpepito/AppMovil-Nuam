import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/usuario.dart';
import '../models/calificacion.dart';
import '../models/dashboard_stats.dart';
import '../models/miembro_equipo.dart';

/// Servicio para consumir la API REST de Django
class ApiService {
  // ========================================
  // AUTENTICACIÓN
  // ========================================

  /// POST - Login (Solo Jefe de Equipo)
  static Future<Map<String, dynamic>> login(String rut, String contrasena) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          'rut': rut,
          'contrasena': contrasena,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'user': Usuario.fromJson(data['user']),
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error en el login',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  // ========================================
  // DASHBOARD
  // ========================================

  /// GET - Dashboard con estadísticas
  static Future<DashboardStats?> getDashboardStats(int equipoId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.dashboard(equipoId)),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DashboardStats.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error al obtener dashboard: $e');
      return null;
    }
  }

  // ========================================
  // CALIFICACIONES PENDIENTES
  // ========================================

  /// GET - Calificaciones pendientes por aprobar
  static Future<List<Calificacion>> getCalificacionesPendientes(int equipoId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.calificacionesPendientes(equipoId)),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('DEBUG - Response calificaciones pendientes: $data');
        
        if (data['calificaciones'] == null) {
          print('ERROR - calificaciones es null en la respuesta');
          return [];
        }
        
        final calificaciones = (data['calificaciones'] as List)
            .map((c) => Calificacion.fromJson(c))
            .toList();
        print('DEBUG - Total calificaciones parseadas: ${calificaciones.length}');
        return calificaciones;
      }
      print('ERROR - Status code: ${response.statusCode}, Body: ${response.body}');
      return [];
    } catch (e) {
      print('Error al obtener calificaciones pendientes: $e');
      return [];
    }
  }

  // ========================================
  // DETALLE DE CALIFICACIÓN
  // ========================================

  /// GET - Detalle de una calificación específica
  static Future<Calificacion?> getDetalleCalificacion(int id) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.detalleCalificacion(id)),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Calificacion.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error al obtener detalle de calificación: $e');
      return null;
    }
  }

  // ========================================
  // APROBAR / RECHAZAR CALIFICACIÓN
  // ========================================

  /// POST - Aprobar calificación
  static Future<Map<String, dynamic>> aprobarCalificacion({
    required int calificacionId,
    required String jefeRut,
    required String observaciones,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.aprobarCalificacion),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          'calificacion_id': calificacionId,
          'jefe_rut': jefeRut,
          'observaciones': observaciones,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['errors']?.toString() ?? 'Error al aprobar',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  /// POST - Rechazar calificación
  static Future<Map<String, dynamic>> rechazarCalificacion({
    required int calificacionId,
    required String jefeRut,
    required String observaciones,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.rechazarCalificacion),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          'calificacion_id': calificacionId,
          'jefe_rut': jefeRut,
          'observaciones': observaciones,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['errors']?.toString() ?? 'Error al rechazar',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  // ========================================
  // HISTORIAL
  // ========================================

  /// GET - Historial de calificaciones (aprobadas y rechazadas)
  static Future<List<Calificacion>> getHistorial({
    required int equipoId,
    String estado = 'all', // 'all', 'aprobado', 'rechazado'
  }) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.historial(equipoId: equipoId, estado: estado)),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final historial = (data['historial'] as List)
            .map((c) => Calificacion.fromJson(c))
            .toList();
        return historial;
      }
      return [];
    } catch (e) {
      print('Error al obtener historial: $e');
      return [];
    }
  }

  // ========================================
  // EQUIPO
  // ========================================

  /// GET - Miembros del equipo
  static Future<Equipo?> getMiEquipo(String rutJefe) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.miEquipo(rutJefe)),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Equipo.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error al obtener equipo: $e');
      return null;
    }
  }

  // ========================================
  // PERFIL
  // ========================================

  /// GET - Perfil del jefe
  static Future<Usuario?> getPerfil(String rut) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.perfil(rut)),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Usuario.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error al obtener perfil: $e');
      return null;
    }
  }

  /// PUT - Actualizar perfil
  static Future<Map<String, dynamic>> actualizarPerfil({
    required String rut,
    String? telefono,
    String? correo,
    String? direccion,
  }) async {
    try {
      final body = <String, dynamic>{'rut': rut};
      if (telefono != null) body['telefono'] = telefono;
      if (correo != null) body['correo'] = correo;
      if (direccion != null) body['direccion'] = direccion;

      final response = await http.put(
        Uri.parse(ApiConfig.actualizarPerfil),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'user': Usuario.fromJson(data['data']),
        };
      } else {
        return {
          'success': false,
          'message': 'Error al actualizar perfil',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
}
