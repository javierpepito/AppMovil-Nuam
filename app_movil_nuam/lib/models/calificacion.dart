class Calificacion {
  final int id;
  final String empresa;
  final int anioTributario;
  final String tipoCalificacion;
  final double monto;
  final double factor;
  final String unidadValor;
  final int puntaje;
  final String categoria;
  final String riesgo;
  final String estado;
  final String? justificacion;
  final DateTime fechaCalculo;

  Calificacion({
    required this.id,
    required this.empresa,
    required this.anioTributario,
    required this.tipoCalificacion,
    required this.monto,
    required this.factor,
    required this.unidadValor,
    required this.puntaje,
    required this.categoria,
    required this.riesgo,
    required this.estado,
    required this.fechaCalculo,
    this.justificacion,
  });

  factory Calificacion.fromJson(Map<String, dynamic> json) {
    return Calificacion(
      id: json['calificacion_id'] is int ? json['calificacion_id'] : int.tryParse(json['calificacion_id'].toString()) ?? 0,
      empresa: json['nombre_empresa'] ?? '',
      anioTributario: json['anio_tributario'] ?? 0,
      tipoCalificacion: json['tipo_calificacion'] ?? '',
      monto: (json['monto_tributario'] is num) ? (json['monto_tributario'] as num).toDouble() : double.tryParse(json['monto_tributario'].toString()) ?? 0,
      factor: (json['factor_tributario'] is num) ? (json['factor_tributario'] as num).toDouble() : double.tryParse(json['factor_tributario'].toString()) ?? 0,
      unidadValor: json['unidad_valor'] ?? '',
      puntaje: json['puntaje_calificacion'] ?? 0,
      categoria: json['categoria_calificacion'] ?? '',
      riesgo: json['nivel_riesgo'] ?? '',
      estado: json['estado_calificacion'] ?? '',
      fechaCalculo: json['fecha_calculo'] != null ? DateTime.parse(json['fecha_calculo']) : DateTime(2000,1,1),
      justificacion: json['justificacion_resultado'],
    );
  }
}