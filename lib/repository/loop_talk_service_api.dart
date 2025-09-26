import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoopTalkServiceApi {
  final String baseUrl = dotenv.env['API_URL']!;

    Future<String> login(String correo, String contrasena) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "correoElectronico": correo,
        "contrasena": contrasena,
      }),
    );

    if (response.statusCode == 200) {
      return response.body; // Aquí viene el token JWT
    } else {
      throw Exception("Error en login: ${response.statusCode}");
    }
  }
} 
