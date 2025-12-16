import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/usuario.dart';
import '../models/dashboard_stats.dart';
import '../models/calificacion.dart';
import '../widgets/cards.dart';
import 'detalle_calificacion_screen.dart';

/// Pantalla de Inicio: Dashboard + Calificaciones Pendientes
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  Usuario? _usuario;
  DashboardStats? _stats;
  List<Calificacion> _pendientes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Obtener usuario
    _usuario = await AuthService.getUserData();

    if (_usuario != null) {
      // Cargar dashboard y pendientes en paralelo
      final results = await Future.wait([
        ApiService.getDashboardStats(_usuario!.equipoId),
        ApiService.getCalificacionesPendientes(_usuario!.equipoId),
      ]);

      setState(() {
        _stats = results[0] as DashboardStats?;
        _pendientes = results[1] as List<Calificacion>;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Saludo
                    Text(
                      'Hola, ${_usuario?.nombre ?? "Jefe"}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Equipo: ${_usuario?.equipoNombre ?? "N/A"}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Dashboard - Tarjetas de Estadísticas
                    if (_stats != null) ...[
                      Text(
                        'Dashboard',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _buildDashboardCards(),
                      const SizedBox(height: 24),
                    ],

                    // Calificaciones Pendientes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pendientes por Aprobar',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _pendientes.length.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (_pendientes.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No hay calificaciones pendientes',
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._pendientes.map((calificacion) {
                        return CalificacionCard(
                          empresaNombre: calificacion.empresaNombre,
                          empresaRut: calificacion.empresaRut,
                          puntaje: calificacion.puntajeCalificacion,
                          categoria: calificacion.categoriaCalificacion,
                          nivelRiesgo: calificacion.nivelRiesgo,
                          calificadorNombre: calificacion.calificadorNombre,
                          fechaCalculo: calificacion.fechaCalculo,
                          onTap: () => _verDetalle(calificacion),
                        );
                      }),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDashboardCards() {
    if (_stats == null) return const SizedBox();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Pendientes',
                value: '${_stats!.totalPendientesAprobar}',
                icon: Icons.pending_actions,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Aprobadas Hoy',
                value: '${_stats!.totalAprobadasHoy}',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Rechazadas Hoy',
                value: '${_stats!.totalRechazadasHoy}',
                icon: Icons.cancel,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Alto Riesgo',
                value: '${_stats!.calificacionesAltoRiesgo}',
                icon: Icons.warning,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Promedio Puntaje',
                value: _stats!.promedioPuntajeAprobadas.toStringAsFixed(1),
                icon: Icons.star,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: '% Aprobación',
                value: '${_stats!.porcentajeAprobacion.toStringAsFixed(0)}%',
                icon: Icons.trending_up,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _verDetalle(Calificacion calificacion) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleCalificacionScreen(
          calificacionId: calificacion.calificacionId,
          jefeRut: _usuario!.rut,
        ),
      ),
    );

    // Si se aprobó o rechazó, recargar datos
    if (result == true) {
      _loadData();
    }
  }
}
