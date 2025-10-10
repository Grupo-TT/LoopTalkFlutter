import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../model/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoopTalkServiceApi {
  final String baseUrl = dotenv.env['API_URL']!;

  /// Login
  Future<String> login(String correo, String contrasenia) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "correoElectronico": correo,
        "contrasenia": contrasenia,
      }),
    );

    if (response.statusCode == 200) {
      final token = response.body;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      return response.body; // Aquí viene el token JWT
    } else {
      throw Exception("Error en login: ${response.statusCode} - ${response.body}");
    }
  }

  /// Registrar usuario
  Future<Usuario> registrarUsuario({
    required String nombre,
    required String correo,
    required String contrasenia,
  }) async {
    final url = Uri.parse("$baseUrl/registro");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nombre": nombre,
        "correoElectronico": correo,
        "contrasenia": contrasenia,
        "rol": "ESTUDIANTE",
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Usuario.fromJson(data);
    } else {
      throw Exception("Error en registro: ${response.statusCode} - ${response.body}");
    }
  }
}
