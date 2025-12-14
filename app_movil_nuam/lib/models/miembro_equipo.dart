/// Modelo para un miembro del equipo
class MiembroEquipo {
  final String rut;
  final String nombreCompleto;
  final String correo;
  final String telefono;
  final int totalCalificaciones;
  final int calificacionesAprobadas;
  final int calificacionesRechazadas;
  final int calificacionesPendientes;

  MiembroEquipo({
    required this.rut,
    required this.nombreCompleto,
    required this.correo,
    required this.telefono,
    required this.totalCalificaciones,
    required this.calificacionesAprobadas,
    required this.calificacionesRechazadas,
    required this.calificacionesPendientes,
  });

  factory MiembroEquipo.fromJson(Map<String, dynamic> json) {
    return MiembroEquipo(
      rut: json['rut'] ?? '',
      nombreCompleto: json['nombre_completo'] ?? '',
      correo: json['correo'] ?? '',
      telefono: json['telefono'] ?? '',
      totalCalificaciones: json['total_calificaciones'] ?? 0,
      calificacionesAprobadas: json['calificaciones_aprobadas'] ?? 0,
      calificacionesRechazadas: json['calificaciones_rechazadas'] ?? 0,
      calificacionesPendientes: json['calificaciones_pendientes'] ?? 0,
    );
  }
}

/// Modelo para el equipo completo
class Equipo {
  final String equipoNombre;
  final int totalMiembros;
  final List<MiembroEquipo> miembros;

  Equipo({
    required this.equipoNombre,
    required this.totalMiembros,
    required this.miembros,
  });

  factory Equipo.fromJson(Map<String, dynamic> json) {
    return Equipo(
      equipoNombre: json['equipo_nombre'] ?? '',
      totalMiembros: json['total_miembros'] ?? 0,
      miembros: (json['miembros'] as List<dynamic>?)
              ?.map((m) => MiembroEquipo.fromJson(m))
              .toList() ??
          [],
    );
  }
}
