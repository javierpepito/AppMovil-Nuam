/// Configuración de endpoints de la API REST de NUAM
class ApiConfig {
  // ========================================
  // CONFIGURACIÓN DE ENTORNO
  // ========================================
  
  /// Cambiar a true para usar servidor de desarrollo local
  static const bool isDevelopment = false;
  
  /// URL base de desarrollo (tu PC)
  static const String devBaseUrl = 'http://127.0.0.1:8000';
  
  /// URL base de producción (Heroku/Render cuando despliegues)
  static const String prodBaseUrl = 'https://app-nuam-bf1dd339e878.herokuapp.com';
  
  /// URL base actual según el entorno
  static String get baseUrl => isDevelopment ? devBaseUrl : prodBaseUrl;
  
  // ========================================
  // ENDPOINTS
  // ========================================
  
  /// POST - Login
  static String get login => '$baseUrl/api/login/';
  
  /// GET - Perfil del jefe por RUT
  static String perfilJefe(String rut) => '$baseUrl/api/cuentas/perfil/? rut=$rut';
  
  /// GET - Equipo del jefe
  static String equipoJefe(String rutJefe) => '$baseUrl/api/equipos/por_jefe/?rut_jefe=$rutJefe';
  
  /// GET - Estadísticas del equipo
  static String estadisticas(int equipoId) => '$baseUrl/api/estadisticas/? equipo_id=$equipoId';
  
  /// GET - Calificaciones por aprobar
  static String calificacionesPorAprobar(int equipoId) => 
      '$baseUrl/api/calificaciones/por_aprobar/?equipo_id=$equipoId';
  
  /// GET - Todas las calificaciones con filtros
  static String calificaciones({int? equipoId, String? estado}) {
    String url = '$baseUrl/api/calificaciones/';
    List<String> params = [];
    if (equipoId != null) params.add('equipo_id=$equipoId');
    if (estado != null) params.add('estado=$estado');
    if (params.isNotEmpty) url += '?${params.join('&')}';
    return url;
  }
  
  /// GET - Detalle de calificación
  static String detalleCalificacion(int id) => '$baseUrl/api/calificaciones/$id/';
  
  /// POST - Aprobar calificación
  static String aprobarCalificacion(int id) => '$baseUrl/api/calificaciones/$id/aprobar/';
  
  /// POST - Rechazar calificación
  static String rechazarCalificacion(int id) => '$baseUrl/api/calificaciones/$id/rechazar/';
  
  /// GET - Calificaciones aprobadas
  static String calificacionesAprobadas({String? jefeRut}) {
    String url = '$baseUrl/api/calificaciones-aprobadas/';
    if (jefeRut != null) url += '?jefe_rut=$jefeRut';
    return url;
  }
  
  /// GET - Calificaciones rechazadas
  static String calificacionesRechazadas({String? jefeRut}) {
    String url = '$baseUrl/api/calificaciones-rechazadas/';
    if (jefeRut != null) url += '?jefe_rut=$jefeRut';
    return url;
  }
  
  // ========================================
  // CONFIGURACIÓN HTTP
  // ========================================
  
  /// Headers por defecto para todas las peticiones
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };
  
  /// Timeout para peticiones HTTP
  static const Duration timeout = Duration(seconds: 15);
}