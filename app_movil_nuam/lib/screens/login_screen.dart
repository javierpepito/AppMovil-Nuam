import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final rutController = TextEditingController();
  final passController = TextEditingController();

  @override
  void dispose() {
    rutController.dispose();
    passController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final ok = await auth.login(rutController.text.trim(), passController.text.trim());
      if (ok) {
        // Navega al Dashboard (puedes cambiar la ruta si lo deseas)
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else {
        final error = auth.error ?? 'Error desconocido. Intenta nuevamente.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingreso de Jefe - NUAM'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 24),
                Text(
                  '¡Bienvenido, Jefe!',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: rutController,
                  decoration: const InputDecoration(
                    labelText: 'RUT',
                    hintText: 'Ej: 12345678-9',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  validator: (val) =>
                      val != null && val.trim().isEmpty ? 'Ingrese su RUT' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: passController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (val) =>
                      val != null && val.trim().isEmpty ? 'Contraseña requerida' : null,
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _login,
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text('Ingresar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}