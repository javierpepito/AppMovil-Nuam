import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/estadisticas.dart';

class EstadisticasProvider with ChangeNotifier {
  EstadisticasEquipo? estadisticas;
  bool isLoading = false;

  Future<void> cargarEstadisticas(int equipoId) async {
    print("CARGANDO ESTADÍSTICAS PARA EQUIPO ID: $equipoId");
    isLoading = true;
    notifyListeners();

    final pendientesData = await Supabase.instance.client
        .from('calificacion_tributaria')
        .select()
        .eq('estado_calificacion', 'por_aprobar')
        .eq('equipo_id', equipoId) as List<dynamic>?;
    final totalPendientes = pendientesData?.length ?? 0;

    final aprobadasData = await Supabase.instance.client
        .from('calificacion_aprovada')
        .select()
        .eq('equipo_id', equipoId) as List<dynamic>?;
    final totalAprobadas = aprobadasData?.length ?? 0;

    final rechazadasData = await Supabase.instance.client
        .from('calificacion_rechazada')
        .select()
        .eq('equipo_id', equipoId) as List<dynamic>?;
    final totalRechazadas = rechazadasData?.length ?? 0;

    // Si aún no tienes cómo calcular estos pon 0 y así compila
    estadisticas = EstadisticasEquipo(
      total: totalAprobadas + totalPendientes + totalRechazadas,
      pendientes: totalPendientes,
      porAprobar: totalPendientes,
      aprobadas: totalAprobadas,
      rechazadas: totalRechazadas,
      empresas: 0,
      mesActual: 0,
    );

    isLoading = false;
    notifyListeners();
  }
}