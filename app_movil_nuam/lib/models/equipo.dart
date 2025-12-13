class Equipo {
  final int equipoId;
  final String nombreEquipo;

  Equipo({
    required this.equipoId,
    required this.nombreEquipo,
  });

  factory Equipo.fromJson(Map<String, dynamic> json) {
    return Equipo(
      equipoId: json['equipo_id'],
      nombreEquipo: json['nombre_equipo'] ?? '',
    );
  }
}