import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/usuario.dart';
import '../models/calificacion.dart';

/// Pantalla de Historial: Aprobadas y Rechazadas
class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Usuario? _usuario;
  List<Calificacion> _aprobadas = [];
  List<Calificacion> _rechazadas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadData();
  }

  void _handleTabChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    _usuario = await AuthService.getUserData();

    if (_usuario != null) {
      final results = await Future.wait([
        ApiService.getHistorial(equipoId: _usuario!.equipoId, estado: 'aprobado'),
        ApiService.getHistorial(equipoId: _usuario!.equipoId, estado: 'rechazado'),
      ]);

      setState(() {
        _aprobadas = results[0];
        _rechazadas = results[1];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  String _getTitleByTab() {
    if (_tabController.index == 0) {
      return 'Aprobadas';
    } else {
      return 'Rechazadas';
    }
  }

  IconData _getIconByTab() {
    if (_tabController.index == 0) {
      return Icons.check_circle;
    } else {
      return Icons.cancel;
    }
  }

  Color _getAppBarColorByTab() {
    if (_tabController.index == 0) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(_getIconByTab(), color: Colors.white),
            const SizedBox(width: 12),
            Text(
              _getTitleByTab(),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: _getAppBarColorByTab(),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              icon: const Icon(Icons.check_circle),
              text: 'Aprobadas (${_aprobadas.length})',
            ),
            Tab(
              icon: const Icon(Icons.cancel),
              text: 'Rechazadas (${_rechazadas.length})',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildListaHistorial(_aprobadas, 'aprobadas'),
                _buildListaHistorial(_rechazadas, 'rechazadas'),
              ],
            ),
    );
  }

  Widget _buildListaHistorial(List<Calificacion> calificaciones, String tipo) {
    if (calificaciones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tipo == 'aprobadas' ? Icons.check_circle_outline : Icons.cancel_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay calificaciones $tipo',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: calificaciones.length,
        itemBuilder: (context, index) {
          final calificacion = calificaciones[index];
          return _buildHistorialCard(calificacion, tipo);
        },
      ),
    );
  }

  Widget _buildHistorialCard(Calificacion calificacion, String tipo) {
    final isAprobada = tipo == 'aprobadas';
    final color = isAprobada ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isAprobada ? Icons.check_circle : Icons.cancel,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        calificacion.empresaNombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'RUT: ${calificacion.empresaRut}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Información
            Row(
              children: [
                _buildInfoChip(Icons.star, '${calificacion.puntajeCalificacion}'),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.category, 'Cat. ${calificacion.categoriaCalificacion}'),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRiskColor(calificacion.nivelRiesgo).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    calificacion.nivelRiesgo,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getRiskColor(calificacion.nivelRiesgo),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Monto, Factor y Unidad
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDataPoint('Monto', NumberFormat.currency(locale: 'es_CL', symbol: '\$').format(calificacion.montoTributario)),
                  _buildDataPoint('Factor', calificacion.factorTributario.toStringAsFixed(4)),
                  _buildDataPoint('Unidad', calificacion.unidadValor),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Calificador
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  calificacion.calificadorNombre,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Fecha de revisión
            if (calificacion.fechaRevision != null)
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Revisado: ${DateFormat('dd/MM/yyyy').format(calificacion.fechaRevision!)}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),

            // Observaciones
            if (calificacion.observaciones != null && calificacion.observaciones!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Observaciones:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      calificacion.observaciones!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.blue),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataPoint(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getRiskColor(String riesgo) {
    switch (riesgo.toLowerCase()) {
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
