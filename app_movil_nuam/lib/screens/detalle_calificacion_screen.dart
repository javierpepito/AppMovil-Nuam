import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
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
    final bool isApprove = action.toLowerCase().startsWith('aprobar');
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: (isApprove ? Colors.green : Colors.red).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isApprove ? Icons.check_circle : Icons.cancel,
                  color: isApprove ? Colors.green : Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$action calificación',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Observaciones',
                  hintText: 'Ingrese sus observaciones...',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: AppTheme.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                maxLines: 4,
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primary, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ingrese observaciones')),
                        );
                        return;
                      }
                      Navigator.pop(dialogContext, controller.text.trim());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isApprove ? Colors.green : Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    ),
                    child: Text(
                      action,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
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
    final icon = _iconForSectionTitle(title);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppTheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    final valueWidget = color == null
        ? Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          )
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 0.4,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(child: valueWidget),
        ],
      ),
    );
  }

  IconData _iconForSectionTitle(String title) {
    switch (title.toLowerCase()) {
      case 'empresa':
        return Icons.business;
      case 'datos tributarios':
        return Icons.receipt_long;
      case 'resultado':
        return Icons.analytics;
      case 'justificación':
        return Icons.notes;
      case 'información adicional':
        return Icons.info;
      default:
        return Icons.folder;
    }
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
