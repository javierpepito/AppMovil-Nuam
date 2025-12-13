import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/equipo.dart';

class EquipoProvider with ChangeNotifier {
  Equipo? equipo;
  bool isLoading = false;
  String? error;

  /// Carga el equipo del jefe usando el rut desde la tabla jefe_equipo
  Future<void> cargarEquipo(String rutJefe) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      // Si el jefe sólo tiene un equipo
      final data = await Supabase.instance.client
          .from('jefe_equipo')
          .select()
          .eq('rut', rutJefe)
          .maybeSingle();

      if (data != null) {
        equipo = Equipo.fromJson(data as Map<String, dynamic>);
        error = null;
      } else {
        equipo = null;
        error = "No se encontró equipo para el jefe";
      }
    } catch (e) {
      equipo = null;
      error = "Error al cargar equipo";
      print('Error cargarEquipo: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearEquipo() {
    equipo = null;
    notifyListeners();
  }
}