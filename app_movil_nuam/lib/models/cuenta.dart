class Cuenta {
  final int cuentaId;
  final String rut;
  final String nombre;
  final String apellido;
  final String correo;
  final String rol;

  Cuenta({
    required this.cuentaId,
    required this.rut,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.rol,
  });

  factory Cuenta.fromJson(Map<String, dynamic> json) {
    return Cuenta(
      cuentaId: json['cuenta_id'],
      rut: json['rut'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      correo: json['correo'],
      rol: json['rol'],
    );
  }
}