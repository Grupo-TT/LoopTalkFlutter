import 'package:flutter/material.dart';

class VistaRecuperar extends StatefulWidget {
  const VistaRecuperar({super.key});

  @override
  State<VistaRecuperar> createState() => _VistaRecuperarState();
}

class _VistaRecuperarState extends State<VistaRecuperar> {
  @override
  Widget build(BuildContext context) {
    final alto = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Botón volver
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.deepPurple, size: 32),
                  onPressed: () {
                    Navigator.pop(context); // Vuelve a la vista login
                  },
                ),
              ),

              const SizedBox(height: 5),

              /// Logo (25% del alto de pantalla)
              SizedBox(
                height: alto * 0.25,
                child: Center(
                  child: Image.asset(
                    "assets/icon.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// Título
              const Text(
                "Recuperar contraseña",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              /// Subtítulo
              const Text(
                "¡No te preocupes! Ingresa el email asociado a tu cuenta. Te enviaremos las instrucciones de recuperación.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              /// Campo Email
              TextField(
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// Botón Enviar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Lógica de envío de recuperación
                  },
                  child: const Text(
                    "Enviar",
                    style: TextStyle(color: Colors.white),
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
