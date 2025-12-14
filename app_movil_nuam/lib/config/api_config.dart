/// Configuración de endpoints de la API REST de NUAM
class ApiConfig {
  // ========================================
  // CONFIGURACIÓN DE ENTORNO
  // ========================================
  
  /// Cambiar a true para usar servidor de desarrollo local
  static const bool isDevelopment = true;
  
  /// URL base de desarrollo (tu PC)
  static const String devBaseUrl = 'http://localhost:8000';
  
  /// URL base de producción (Heroku/Render cuando despliegues)
  static const String prodBaseUrl = 'https://app-nuam-bf1dd339e878.herokuapp.com';
  
  /// URL base actual según el entorno
  static String get baseUrl => isDevelopment ? devBaseUrl : prodBaseUrl;
  
  // ========================================
  // ENDPOINTS SEGÚN DOCUMENTACIÓN API
  // ========================================
  
  /// POST - Login (Solo Jefe de Equipo)
  static String get login => '$baseUrl/api/login/';
  
  /// GET - Dashboard con estadísticas
  static String dashboard(int equipoId) => '$baseUrl/api/dashboard/?equipo_id=$equipoId';
  
  /// GET - Calificaciones pendientes por aprobar
  static String calificacionesPendientes(int equipoId) => 
      '$baseUrl/api/calificaciones-pendientes/?equipo_id=$equipoId';
  
  /// GET - Detalle de calificación
  static String detalleCalificacion(int id) => '$baseUrl/api/calificacion/$id/';
  
  /// POST - Aprobar calificación
  static String get aprobarCalificacion => '$baseUrl/api/aprobar-calificacion/';
  
  /// POST - Rechazar calificación
  static String get rechazarCalificacion => '$baseUrl/api/rechazar-calificacion/';
  
  /// GET - Historial de calificaciones (aprobadas y rechazadas)
  static String historial({required int equipoId, String estado = 'all'}) =>
      '$baseUrl/api/historial/?equipo_id=$equipoId&estado=$estado';
  
  /// GET - Miembros del equipo
  static String miEquipo(String rutJefe) => '$baseUrl/api/mi-equipo/?rut_jefe=$rutJefe';
  
  /// GET - Perfil del jefe
  static String perfil(String rut) => '$baseUrl/api/perfil/?rut=$rut';
  
  /// PUT - Actualizar perfil
  static String get actualizarPerfil => '$baseUrl/api/perfil/';
  
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