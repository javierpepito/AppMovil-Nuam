import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/usuario.dart';
import '../config/app_theme.dart';

/// Pantalla de Perfil: Ver y editar perfil, cerrar sesión
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  Usuario? _usuario;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final usuario = await AuthService.getUserData();
    setState(() {
      _usuario = usuario;
      _isLoading = false;
    });
  }

  Future<void> _editarPerfil() async {
    if (_usuario == null) return;

    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditarPerfilScreen(usuario: _usuario!),
      ),
    );

    if (result != null && result.isNotEmpty) {
      // Actualizar perfil
      setState(() => _isLoading = true);
      Map<String, dynamic> response;
      try {
        response = await ApiService.actualizarPerfil(
          rut: _usuario!.rut,
          telefono: result['telefono'],
          correo: result['correo'],
        );
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (response['success'] == true) {
        // Actualizar usuario en sesión fusionando con el existente
        final dynamic userPayload = response['user'];
        final Map<String, dynamic>? userMap = userPayload is Map<String, dynamic>
            ? userPayload
            : (userPayload is Usuario ? userPayload.toJson() : null);

        final Usuario merged = Usuario(
          cuentaId: _usuario!.cuentaId,
          rut: _usuario!.rut,
          nombre: _usuario!.nombre,
          apellido: _usuario!.apellido,
          correo: userMap?['correo'] ?? _usuario!.correo,
          telefono: userMap?['telefono'] ?? _usuario!.telefono,
          equipoId: _usuario!.equipoId,
          equipoNombre: _usuario!.equipoNombre,
          // Ignoramos direccion y edad que pueda enviar el backend
          direccion: _usuario!.direccion,
          edad: _usuario!.edad,
        );

        await AuthService.updateUserData(merged);

        setState(() {
          _usuario = merged;
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Error al actualizar'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _cerrarSesion() async {
    final confirmado = await showDialog<bool>(
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
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, color: AppTheme.primary, size: 32),
              ),
              const SizedBox(height: 12),
              const Text(
                'Cerrar sesión',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿Estás seguro de que quieres cerrar sesión? Se cerrará tu sesión actual.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700], height: 1.35),
              ),
              const SizedBox(height: 20),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
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
                    onPressed: () => Navigator.pop(dialogContext, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    ),
                    child: const Text(
                      'Cerrar sesión',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (confirmado == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editarPerfil,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _usuario == null
              ? const Center(child: Text('No se pudo cargar el perfil'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Avatar y nombre
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        child: Text(
                          _getInitials(_usuario!.nombreCompleto),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _usuario!.nombreCompleto,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Jefe de Equipo',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Información del perfil
                      _buildInfoCard('Información Personal', [
                        _buildInfoTile(Icons.badge, 'RUT', _usuario!.rut),
                        _buildInfoTile(Icons.email, 'Correo', _usuario!.correo),
                        _buildInfoTile(Icons.phone, 'Teléfono', _usuario!.telefono),
                        // Nota: intencionalmente no mostramos Dirección ni Edad
                      ]),
                      const SizedBox(height: 16),

                      _buildInfoCard('Equipo', [
                        _buildInfoTile(Icons.groups, 'Equipo', _usuario!.equipoNombre),
                        _buildInfoTile(Icons.numbers, 'ID Equipo', '${_usuario!.equipoId}'),
                      ]),
                      const SizedBox(height: 32),

                      // Botón de cerrar sesión
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _cerrarSesion,
                          icon: const Icon(Icons.logout),
                          label: const Text('Cerrar Sesión'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.grey[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }
}

/// Pantalla para editar el perfil
class EditarPerfilScreen extends StatefulWidget {
  final Usuario usuario;

  const EditarPerfilScreen({super.key, required this.usuario});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  late TextEditingController _telefonoController;
  late TextEditingController _correoController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _telefonoController = TextEditingController(text: widget.usuario.telefono);
    _correoController = TextEditingController(text: widget.usuario.correo);
  }

  @override
  void dispose() {
    _telefonoController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'telefono': _telefonoController.text.trim(),
        'correo': _correoController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
         child: Form(
           key: _formKey,
           child: Column(
             children: [
               // Avatar/Encabezado decorativo
               Container(
                 width: 100,
                 height: 100,
                 decoration: BoxDecoration(
                   gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withValues(alpha: 0.85),
                      AppTheme.primary,
                    ],
                     begin: Alignment.topLeft,
                     end: Alignment.bottomRight,
                   ),
                   borderRadius: BorderRadius.circular(20),
                   boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                       blurRadius: 10,
                       offset: const Offset(0, 4),
                     ),
                   ],
                 ),
                 child: const Icon(
                   Icons.person,
                   size: 50,
                   color: Colors.white,
                 ),
               ),
               const SizedBox(height: 32),

               // Campo de Teléfono
               TextFormField(
                 controller: _telefonoController,
                 decoration: InputDecoration(
                   labelText: 'Teléfono',
                   hintText: '+56 9 1234 5678',
                   prefixIcon: const Icon(Icons.phone_rounded),
                   filled: true,
                   fillColor: Colors.grey[100],
                   border: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(12),
                     borderSide: BorderSide.none,
                   ),
                   enabledBorder: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(12),
                     borderSide: BorderSide.none,
                   ),
                   focusedBorder: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(12),
                     borderSide: const BorderSide(
                       color: AppTheme.primary,
                       width: 2,
                     ),
                   ),
                   errorBorder: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(12),
                     borderSide: const BorderSide(
                       color: Colors.red,
                       width: 2,
                     ),
                   ),
                   focusedErrorBorder: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(12),
                     borderSide: const BorderSide(
                       color: Colors.red,
                       width: 2,
                     ),
                   ),
                   labelStyle: TextStyle(color: Colors.grey[600]),
                   contentPadding: const EdgeInsets.symmetric(
                     horizontal: 16,
                     vertical: 14,
                   ),
                 ),
                 keyboardType: TextInputType.phone,
                 validator: (value) {
                   if (value == null || value.isEmpty) {
                     return 'Ingrese su teléfono';
                   }
                   return null;
                 },
               ),
               const SizedBox(height: 20),

               // Campo de Correo
               TextFormField(
                 controller: _correoController,
                 decoration: InputDecoration(
                   labelText: 'Correo Electrónico',
                   hintText: 'ejemplo@correo.com',
                   prefixIcon: const Icon(Icons.email_rounded),
                   filled: true,
                   fillColor: Colors.grey[100],
                   border: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(12),
                     borderSide: BorderSide.none,
                   ),
                   enabledBorder: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(12),
                     borderSide: BorderSide.none,
                   ),
                   focusedBorder: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(12),
                     borderSide: const BorderSide(
                       color: AppTheme.primary,
                       width: 2,
                     ),
                   ),
                   errorBorder: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(12),
                     borderSide: const BorderSide(
                       color: Colors.red,
                       width: 2,
                     ),
                   ),
                   focusedErrorBorder: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(12),
                     borderSide: const BorderSide(
                       color: Colors.red,
                       width: 2,
                     ),
                   ),
                   labelStyle: TextStyle(color: Colors.grey[600]),
                   contentPadding: const EdgeInsets.symmetric(
                     horizontal: 16,
                     vertical: 14,
                   ),
                 ),
                 keyboardType: TextInputType.emailAddress,
                 validator: (value) {
                   if (value == null || value.isEmpty) {
                     return 'Ingrese su correo';
                   }
                   if (!value.contains('@')) {
                     return 'Ingrese un correo válido';
                   }
                   return null;
                 },
               ),
               const SizedBox(height: 40),

               // Botón Guardar Cambios
               SizedBox(
                 width: double.infinity,
                 height: 50,
                 child: ElevatedButton(
                   onPressed: _guardar,
                   style: ElevatedButton.styleFrom(
                     backgroundColor: AppTheme.primary,
                     foregroundColor: Colors.white,
                     elevation: 4,
                     shadowColor: AppTheme.primary.withValues(alpha: 0.4),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(12),
                     ),
                   ),
                   child: const Text(
                     'Guardar Cambios',
                     style: TextStyle(
                       fontSize: 16,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                 ),
               ),
               const SizedBox(height: 16),

               // Botón Cancelar
               SizedBox(
                 width: double.infinity,
                 height: 50,
                 child: OutlinedButton(
                   onPressed: () => Navigator.pop(context),
                   style: OutlinedButton.styleFrom(
                     side: BorderSide(
                       color: Colors.grey[400]!,
                       width: 1.5,
                     ),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(12),
                     ),
                   ),
                   child: Text(
                     'Cancelar',
                     style: TextStyle(
                       fontSize: 16,
                       fontWeight: FontWeight.w600,
                       color: Colors.grey[700],
                     ),
                   ),
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }
}
