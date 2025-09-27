import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';

class VistaRegistrar extends StatefulWidget {
  const VistaRegistrar({super.key});

  @override
  State<VistaRegistrar> createState() => _VistaRegistrarState();
}

class _VistaRegistrarState extends State<VistaRegistrar> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contraseniaController = TextEditingController();
  final TextEditingController _confirmContraseniaController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _contraseniaController.dispose();
    _confirmContraseniaController.dispose();
    super.dispose();
  }

  void _registrar(BuildContext context) {
    final nombre = _nombreController.text.trim();
    final correo = _correoController.text.trim();
    final contrasenia = _contraseniaController.text.trim();
    final confirmContrasenia = _confirmContraseniaController.text.trim();

    if (nombre.isEmpty || correo.isEmpty || contrasenia.isEmpty || confirmContrasenia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor completa todos los campos")),
      );
      return;
    }

    if (contrasenia != confirmContrasenia) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden")),
      );
      return;
    }

    context.read<AuthBloc>().add(
          RegisterEvent(nombre, correo, contrasenia),
        );
  }

  @override
  Widget build(BuildContext context) {
    final alto = MediaQuery.of(context).size.height;

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Usuario ${state.usuario.nombre} registrado con éxito")),
            );
            Navigator.pop(context); // volver al login
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// Botón volver
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.purple, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  const SizedBox(height: 5),

                  /// Logo (25% del alto de pantalla)
                  SizedBox(
                    height: alto * 0.25,
                    child: Center(
                      child: Image.asset("assets/logo.png", fit: BoxFit.contain),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Crea tu cuenta",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Para empezar, completa los siguientes datos",
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 15),

                  /// Campo Nombre Completo
                  TextField(
                    controller: _nombreController,
                    decoration: InputDecoration(
                      labelText: "Nombre Completo",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Campo Email
                  TextField(
                    controller: _correoController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Campo Contraseña
                  TextField(
                    controller: _contraseniaController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Contraseña",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Campo Confirmar Contraseña
                  TextField(
                    controller: _confirmContraseniaController,
                    obscureText: _obscurePasswordConfirm,
                    decoration: InputDecoration(
                      labelText: "Confirmar contraseña",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePasswordConfirm ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePasswordConfirm = !_obscurePasswordConfirm;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// Botón registrarse o loader
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: state is AuthLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => _registrar(context),
                            child: const Text("Regístrate", style: TextStyle(color: Colors.white)),
                          ),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("¿Ya tienes una cuenta?", style: TextStyle(color: Colors.blueGrey)),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Inicia sesión",
                          style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
