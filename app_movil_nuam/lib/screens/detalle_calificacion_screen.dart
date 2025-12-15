import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/calificacion.dart';

/// Pantalla de detalle de calificación con opciones de aprobar/rechazar
class DetalleCalificacionScreen extends StatefulWidget {
  final int calificacionId;
  final String jefeRut;

  const DetalleCalificacionScreen({
    super.key,
    required this.calificacionId,
    required this.jefeRut,
  });

  @override
  State<DetalleCalificacionScreen> createState() => _DetalleCalificacionScreenState();
}

class _DetalleCalificacionScreenState extends State<DetalleCalificacionScreen> {
  Calificacion? _calificacion;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadDetalle();
  }

  Future<void> _loadDetalle() async {
    setState(() => _isLoading = true);
    final calificacion = await ApiService.getDetalleCalificacion(widget.calificacionId);
    setState(() {
      _calificacion = calificacion;
      _isLoading = false;
    });
  }

  Future<void> _aprobar() async {
    final observaciones = await _showObservacionesDialog('Aprobar');
    if (observaciones == null) return;

    setState(() => _isSubmitting = true);

    final result = await ApiService.aprobarCalificacion(
      calificacionId: widget.calificacionId,
      jefeRut: widget.jefeRut,
      observaciones: observaciones,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Calificación aprobada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Volver con resultado exitoso
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Error al aprobar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rechazar() async {
    final observaciones = await _showObservacionesDialog('Rechazar');
    if (observaciones == null) return;

    setState(() => _isSubmitting = true);

    final result = await ApiService.rechazarCalificacion(
      calificacionId: widget.calificacionId,
      jefeRut: widget.jefeRut,
      observaciones: observaciones,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Calificación rechazada'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Error al rechazar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _showObservacionesDialog(String action) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$action Calificación'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Observaciones',
              hintText: 'Ingrese sus observaciones...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingrese observaciones')),
                  );
                  return;
                }
                Navigator.pop(context, controller.text.trim());
              },
              child: Text(action),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Calificación'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _calificacion == null
              ? const Center(child: Text('No se pudo cargar la calificación'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection('Empresa', [
                        _buildInfoRow('Nombre', _calificacion!.empresaNombre),
                        _buildInfoRow('RUT', _calificacion!.empresaRut),
                        _buildInfoRow('País', _calificacion!.empresaPais),
                      ]),
                      const SizedBox(height: 16),
                      _buildSection('Datos Tributarios', [
                        _buildInfoRow('Año', '${_calificacion!.anioTributario}'),
                        _buildInfoRow('Tipo', _calificacion!.tipoCalificacion),
                        _buildInfoRow('Monto', NumberFormat.currency(locale: 'es_CL', symbol: '\$')
                            .format(_calificacion!.montoTributario)),
                        _buildInfoRow('Factor', _calificacion!.factorTributario.toStringAsFixed(4)),
                        _buildInfoRow('Unidad', _calificacion!.unidadValor),
                      ]),
                      const SizedBox(height: 16),
                      _buildSection('Resultado', [
                        _buildInfoRow('Puntaje', '${_calificacion!.puntajeCalificacion}'),
                        _buildInfoRow('Categoría', _calificacion!.categoriaCalificacion),
                        _buildInfoRow('Nivel de Riesgo', _calificacion!.nivelRiesgo,
                            color: _getRiskColor()),
                      ]),
                      const SizedBox(height: 16),
                      _buildSection('Justificación', [
                        Text(_calificacion!.justificacionResultado),
                      ]),
                      const SizedBox(height: 16),
                      _buildSection('Información Adicional', [
                        _buildInfoRow('Calificador', _calificacion!.calificadorNombre),
                        _buildInfoRow(
                          'Fecha Cálculo',
                          DateFormat('dd/MM/yyyy HH:mm').format(_calificacion!.fechaCalculo),
                        ),
                      ]),
                      const SizedBox(height: 32),

                      // Botones de acción
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isSubmitting ? null : _rechazar,
                              icon: const Icon(Icons.cancel),
                              label: const Text('Rechazar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isSubmitting ? null : _aprobar,
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Aprobar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color ?? Colors.black87,
                fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRiskColor() {
    switch (_calificacion!.nivelRiesgo.toLowerCase()) {
      case 'bajo':
        return Colors.green;
      case 'medio':
        return Colors.orange;
      case 'alto':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
