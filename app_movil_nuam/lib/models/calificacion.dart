/// Modelo para Calificación Tributaria
class Calificacion {
  final int calificacionId;
  final String empresaRut;
  final String empresaNombre;
  final String empresaPais;
  final int anioTributario;
  final String tipoCalificacion;
  final int montoTributario;
  final String factorTributario;
  final String unidadValor;
  final int puntajeCalificacion;
  final String categoriaCalificacion;
  final String nivelRiesgo;
  final String justificacionResultado;
  final DateTime fechaCalculo;
  final String calificadorNombre;
  final String? estado; // Para historial: 'aprobado' o 'rechazado'
  final DateTime? fechaRevision; // Para historial
  final String? observaciones; // Para historial

  Calificacion({
    required this.calificacionId,
    required this.empresaRut,
    required this.empresaNombre,
    required this.empresaPais,
    required this.anioTributario,
    required this.tipoCalificacion,
    required this.montoTributario,
    required this.factorTributario,
    required this.unidadValor,
    required this.puntajeCalificacion,
    required this.categoriaCalificacion,
    required this.nivelRiesgo,
    required this.justificacionResultado,
    required this.fechaCalculo,
    required this.calificadorNombre,
    this.estado,
    this.fechaRevision,
    this.observaciones,
  });

  factory Calificacion.fromJson(Map<String, dynamic> json) {
    return Calificacion(
      calificacionId: json['calificacion_id'] ?? 0,
      empresaRut: json['empresa_rut'] ?? '',
      empresaNombre: json['empresa_nombre'] ?? '',
      empresaPais: json['empresa_pais'] ?? '',
      anioTributario: json['anio_tributario'] ?? 0,
      tipoCalificacion: json['tipo_calificacion'] ?? '',
      montoTributario: json['monto_tributario'] ?? 0,
      factorTributario: json['factor_tributario'] ?? '',
      unidadValor: json['unidad_valor'] ?? '',
      puntajeCalificacion: json['puntaje_calificacion'] ?? 0,
      categoriaCalificacion: json['categoria_calificacion'] ?? '',
      nivelRiesgo: json['nivel_riesgo'] ?? '',
      justificacionResultado: json['justificacion_resultado'] ?? '',
      fechaCalculo: json['fecha_calculo'] != null
          ? DateTime.parse(json['fecha_calculo'])
          : DateTime.now(),
      calificadorNombre: json['calificador_nombre'] ?? '',
      estado: json['estado'],
      fechaRevision: json['fecha_revision'] != null
          ? DateTime.parse(json['fecha_revision'])
          : null,
      observaciones: json['observaciones'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calificacion_id': calificacionId,
      'empresa_rut': empresaRut,
      'empresa_nombre': empresaNombre,
      'empresa_pais': empresaPais,
      'anio_tributario': anioTributario,
      'tipo_calificacion': tipoCalificacion,
      'monto_tributario': montoTributario,
      'factor_tributario': factorTributario,
      'unidad_valor': unidadValor,
      'puntaje_calificacion': puntajeCalificacion,
      'categoria_calificacion': categoriaCalificacion,
      'nivel_riesgo': nivelRiesgo,
      'justificacion_resultado': justificacionResultado,
      'fecha_calculo': fechaCalculo.toIso8601String(),
      'calificador_nombre': calificadorNombre,
      'estado': estado,
      'fecha_revision': fechaRevision?.toIso8601String(),
      'observaciones': observaciones,
    };
  }
}