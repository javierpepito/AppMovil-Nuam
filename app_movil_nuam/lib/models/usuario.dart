/// Modelo para el usuario (Jefe de Equipo)
class Usuario {
  final int cuentaId;
  final String rut;
  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;
  final int equipoId;
  final String equipoNombre;
  final String? direccion;
  final int? edad;

  Usuario({
    required this.cuentaId,
    required this.rut,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.telefono,
    required this.equipoId,
    required this.equipoNombre,
    this.direccion,
    this.edad,
  });

  String get nombreCompleto => '$nombre $apellido';

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      cuentaId: json['cuenta_id'] ?? 0,
      rut: json['rut'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      correo: json['correo'] ?? '',
      telefono: json['telefono'] ?? '',
      equipoId: json['equipo_id'] ?? 0,
      equipoNombre: json['equipo_nombre'] ?? '',
      direccion: json['direccion'],
      edad: json['edad'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cuenta_id': cuentaId,
      'rut': rut,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'telefono': telefono,
      'equipo_id': equipoId,
      'equipo_nombre': equipoNombre,
      'direccion': direccion,
      'edad': edad,
    };
  }
}
