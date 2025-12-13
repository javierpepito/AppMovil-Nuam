import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/auth_provider.dart';
import '../providers/equipo_provider.dart';
import '../providers/calificacion_provider.dart';
import '../providers/estadisticas_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loaded = false;
  int _equipoId = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final equipoProvider = Provider.of<EquipoProvider>(context, listen: false);
      final estadProvider = Provider.of<EstadisticasProvider>(context, listen: false);
      final califProvider = Provider.of<CalificacionProvider>(context, listen: false);

      if (authProvider.cuenta != null) {
        equipoProvider.cargarEquipo(authProvider.cuenta!.rut).then((_) {
          if (equipoProvider.equipo != null) {
            _equipoId = equipoProvider.equipo!.equipoId;
            estadProvider.cargarEstadisticas(_equipoId);
            califProvider.cargarPendientes(_equipoId);
            califProvider.cargarAprobadas(jefeRut: authProvider.cuenta!.rut);
            califProvider.cargarRechazadas(jefeRut: authProvider.cuenta!.rut);
          }
        });
      }
      setState(() => _loaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final equipo = Provider.of<EquipoProvider>(context);
    final estad = Provider.of<EstadisticasProvider>(context);
    final calif = Provider.of<CalificacionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Jefe - NUAM'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (auth.cuenta != null && equipo.equipo != null) {
            await estad.cargarEstadisticas(equipo.equipo!.equipoId);
            await calif.cargarPendientes(equipo.equipo!.equipoId);
            await calif.cargarAprobadas(jefeRut: auth.cuenta!.rut);
            await calif.cargarRechazadas(jefeRut: auth.cuenta!.rut);
          }
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            Text(
              '¡Hola, ${auth.cuenta?.nombre ?? 'Jefe'}!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Equipo: ${equipo.equipo?.nombreEquipo ?? 'Cargando...'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),

            // Estadísticas principales (Tarjetas)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatCard(
                  color: Colors.orange,
                  icon: Icons.list_alt,
                  label: 'Total',
                  value: estad.estadisticas?.total ?? 0,
                ),
                _StatCard(
                  color: Colors.blue,
                  icon: Icons.hourglass_empty,
                  label: 'Pendientes',
                  value: estad.estadisticas?.pendientes ?? 0,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatCard(
                  color: Colors.green,
                  icon: Icons.check_circle_outline,
                  label: 'Aprobadas',
                  value: estad.estadisticas?.aprobadas ?? 0,
                ),
                _StatCard(
                  color: Colors.red,
                  icon: Icons.cancel_outlined,
                  label: 'Rechazadas',
                  value: estad.estadisticas?.rechazadas ?? 0,
                ),
              ],
            ),
            const SizedBox(height: 25),
            Text(
              'Resumen del mes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: _PieChartWidget(
                pendientes: estad.estadisticas?.pendientes ?? 0,
                aprobadas: estad.estadisticas?.aprobadas ?? 0,
                rechazadas: estad.estadisticas?.rechazadas ?? 0,
              ),
            ),

            const SizedBox(height: 20),

            // Últimas calificaciones pendientes (Muestra 5)
            Text(
              'Pendientes de aprobación',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (calif.isLoadingPendientes)
              const Center(child: CircularProgressIndicator())
            else if (calif.pendientes.isEmpty)
              const Text('No hay calificaciones pendientes.')
            else
              ...calif.pendientes.take(5).map((c) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.business),
                      title: Text(c.empresa),
                      subtitle: Text(
                          'Año: ${c.anioTributario}  |  Puntaje: ${c.puntaje}'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () {
                        // Luego puedes navegar a la pantalla de detalle
                        // Navigator.pushNamed(context, '/calificacion_detalle', arguments: c);
                      },
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

// Tarjeta para estadísticas rápidas
class _StatCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final int value;

  const _StatCard({
    required this.color,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// Pie Chart Widget con fl_chart
class _PieChartWidget extends StatelessWidget {
  final int pendientes;
  final int aprobadas;
  final int rechazadas;

  const _PieChartWidget({
    required this.pendientes,
    required this.aprobadas,
    required this.rechazadas,
  });

  @override
  Widget build(BuildContext context) {
    final total = pendientes + aprobadas + rechazadas;
    if (total == 0) {
      return const Center(child: Text("Sin datos aún para mostrar gráfico."));
    }

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            color: Colors.blue,
            value: pendientes.toDouble(),
            title: 'Pendientes\n$pendientes',
            radius: 52,
            titleStyle: const TextStyle(fontSize: 13, color: Colors.white),
          ),
          PieChartSectionData(
            color: Colors.green,
            value: aprobadas.toDouble(),
            title: 'Aprobadas\n$aprobadas',
            radius: 52,
            titleStyle: const TextStyle(fontSize: 13, color: Colors.white),
          ),
          PieChartSectionData(
            color: Colors.red,
            value: rechazadas.toDouble(),
            title: 'Rechazadas\n$rechazadas',
            radius: 52,
            titleStyle: const TextStyle(fontSize: 13, color: Colors.white),
          ),
        ],
        sectionsSpace: 3,
        centerSpaceRadius: 36,
      ),
    );
  }
}