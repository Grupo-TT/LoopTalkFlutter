import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../model/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/token_storage.dart';


class LoopTalkServiceApi {
  final String baseUrl = 'http://18.222.231.135:8080';

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
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String jwtToken = data['jwTtoken'] ?? data['jwtToken'] ?? data['token'];
      
      if (jwtToken.isEmpty) {
        throw Exception("Token no encontrado en la respuesta");
      }
      
      return jwtToken;
    } else if (response.statusCode == 401) {
      throw Exception("Credenciales incorrectas");
    } else {
      throw Exception("Error en login: ${response.statusCode}");
    }
  }

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
      throw Exception("Error en registro: ${response.statusCode}");
    }
  }
}
