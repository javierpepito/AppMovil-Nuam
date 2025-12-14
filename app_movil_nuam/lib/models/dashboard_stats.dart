/// Modelo para las estadísticas del Dashboard
class DashboardStats {
  final int totalPendientesAprobar;
  final int totalAprobadasHoy;
  final int totalRechazadasHoy;
  final int totalPendientesMes;
  final int totalAprobadasMes;
  final int totalRechazadasMes;
  final int totalCalificacionesEquipo;
  final double promedioPuntajeAprobadas;
  final double porcentajeAprobacion;
  final int calificacionesAltoRiesgo;
  final int calificacionesAntiguas;
  final String topCalificadorNombre;
  final int topCalificadorAprobadas;

  DashboardStats({
    required this.totalPendientesAprobar,
    required this.totalAprobadasHoy,
    required this.totalRechazadasHoy,
    required this.totalPendientesMes,
    required this.totalAprobadasMes,
    required this.totalRechazadasMes,
    required this.totalCalificacionesEquipo,
    required this.promedioPuntajeAprobadas,
    required this.porcentajeAprobacion,
    required this.calificacionesAltoRiesgo,
    required this.calificacionesAntiguas,
    required this.topCalificadorNombre,
    required this.topCalificadorAprobadas,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalPendientesAprobar: json['total_pendientes_aprobar'] ?? 0,
      totalAprobadasHoy: json['total_aprobadas_hoy'] ?? 0,
      totalRechazadasHoy: json['total_rechazadas_hoy'] ?? 0,
      totalPendientesMes: json['total_pendientes_mes'] ?? 0,
      totalAprobadasMes: json['total_aprobadas_mes'] ?? 0,
      totalRechazadasMes: json['total_rechazadas_mes'] ?? 0,
      totalCalificacionesEquipo: json['total_calificaciones_equipo'] ?? 0,
      promedioPuntajeAprobadas: (json['promedio_puntaje_aprobadas'] ?? 0.0).toDouble(),
      porcentajeAprobacion: (json['porcentaje_aprobacion'] ?? 0.0).toDouble(),
      calificacionesAltoRiesgo: json['calificaciones_alto_riesgo'] ?? 0,
      calificacionesAntiguas: json['calificaciones_antiguas'] ?? 0,
      topCalificadorNombre: json['top_calificador_nombre'] ?? 'N/A',
      topCalificadorAprobadas: json['top_calificador_aprobadas'] ?? 0,
    );
  }
}
