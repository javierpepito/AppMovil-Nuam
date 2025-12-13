import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/calificacion.dart';

class CalificacionProvider with ChangeNotifier {
  List<Calificacion> pendientes = [];
  List<Calificacion> aprobadas = [];
  List<Calificacion> rechazadas = [];
  bool isLoadingPendientes = false;
  bool isLoadingAprobadas = false;
  bool isLoadingRechazadas = false;

  // PENDIENTES: Desde calificacion_tributaria (realmente pendientes por aprobar)
  Future<void> cargarPendientes(int equipoId) async {
    print("CARGANDO CALIFICACIONES PENDIENTES PARA EQUIPO ID: $equipoId");
    isLoadingPendientes = true;
    notifyListeners();
    final data = await Supabase.instance.client
        .from('calificacion_tributaria')
        .select()
        .eq('estado_calificacion', 'por_aprobar')
        .eq('equipo_id', equipoId) as List<dynamic>?;

    pendientes = data?.map<Calificacion>((x) => Calificacion.fromJson(x as Map<String, dynamic>)).toList() ?? [];
    isLoadingPendientes = false;
    notifyListeners();
  }

  // APROBADAS: Desde calificacion_aprovada, filtra por jefe_rut
  Future<void> cargarAprobadas({required String jefeRut}) async {
    isLoadingAprobadas = true;
    notifyListeners();
    final data = await Supabase.instance.client
        .from('calificacion_aprovada')
        .select()
        .eq('jefe_rut', jefeRut) as List<dynamic>?;

    aprobadas = data?.map<Calificacion>((x) => Calificacion.fromJson(x as Map<String, dynamic>)).toList() ?? [];
    isLoadingAprobadas = false;
    notifyListeners();
  }

  // RECHAZADAS: Desde calificacion_rechazada, filtra por jefe_rut
  Future<void> cargarRechazadas({required String jefeRut}) async {
    isLoadingRechazadas = true;
    notifyListeners();
    final data = await Supabase.instance.client
        .from('calificacion_rechazada')
        .select()
        .eq('jefe_rut', jefeRut) as List<dynamic>?;

    rechazadas = data?.map<Calificacion>((x) => Calificacion.fromJson(x as Map<String, dynamic>)).toList() ?? [];
    isLoadingRechazadas = false;
    notifyListeners();
  }
}