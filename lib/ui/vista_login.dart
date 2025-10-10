import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import 'vista_recuperar.dart';
import 'vista_registrar.dart';
import 'vista_topicos.dart'; // Importar la nueva vista de tópicos

bool _obscurePasswordLogin = true;

class VistaLogin extends StatefulWidget {
  const VistaLogin({super.key});

  @override
  State<VistaLogin> createState() => _VistaLoginState();
}

class _VistaLoginState extends State<VistaLogin> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contraseniaController = TextEditingController();

  @override
  void dispose() {
    _correoController.dispose();
    _contraseniaController.dispose();
    super.dispose();
  }

  void _login() {
    context.read<AuthBloc>().add(
          LoginEvent(
            _correoController.text.trim(),
            _contraseniaController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final alto = MediaQuery.of(context).size.height;

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Navegar a la vista de tópicos después del login exitoso
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const VistaTopicos(),
              ),
            );
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
                  //Espacio en blanco para mantener a altura
                  Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: const SizedBox(),
                    ),
                  ),

                  const SizedBox(height: 5),

                  /// Imagen arriba (25% del alto de pantalla)
                  SizedBox(
                    height: alto * 0.25,
                    child: Center(
                      child: Image.asset(
                        "assets/logo.png", // aquí va el logo, si tuviera uno *Inserte meme del papá de Timmy Turner
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  /// Título
                  const Text(
                    "¡Hola!",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  /// Subtítulo
                  const Text(
                    "Por favor, ingresa tus datos.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 30),

                  /// Campo Email
                  TextField(
                    controller: _correoController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// Campo Contraseña
                  TextField(
                    controller: _contraseniaController,
                    obscureText: _obscurePasswordLogin,
                    decoration: InputDecoration(
                      labelText: "Contraseña",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePasswordLogin ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePasswordLogin = !_obscurePasswordLogin;
                          });
                        },
                      ),
                    ),
                  ),

                  /// Enlace Olvidaste tu contraseña
                  Container(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VistaRecuperar(),
                          ),
                        );
                      },
                      child: const Text(
                        "¿Olvidaste tu contraseña?",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// Botón Ingresar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: state is AuthLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ), //Texto del Botón
                            onPressed: _login, // Llama a la función _login
                            child: const Text(
                              "Ingresar",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  ),
                  const SizedBox(height: 30),

                  /// Enlace Registro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "¿No tienes una cuenta? ",
                        style: TextStyle(
                          color: Colors.blueGrey,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VistaRegistrar(),
                            ),
                          );
                        },
                        child: const Text(
                          "Regístrate",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
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



