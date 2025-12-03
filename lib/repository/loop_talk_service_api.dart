import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../model/usuario.dart';

class LoopTalkServiceApi {
  final String baseUrl = dotenv.env['API_URL']!;

  // Timeout de 30 segundos para las peticiones
  static const Duration _timeout = Duration(seconds: 30);

  Future<String> login(String correo, String contrasenia) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http
        .post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "correoElectronico": correo,
            "contrasenia": contrasenia,
          }),
        )
        .timeout(
          _timeout,
          onTimeout: () {
            throw Exception(
              "Tiempo de espera agotado. Verifica tu conexión a internet.",
            );
          },
        );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String jwtToken =
          data['jwTtoken'] ?? data['jwtToken'] ?? data['token'];

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

    final response = await http
        .post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "nombre": nombre,
            "correoElectronico": correo,
            "contrasenia": contrasenia,
            "rol": "ESTUDIANTE",
          }),
        )
        .timeout(
          _timeout,
          onTimeout: () {
            throw Exception(
              "Tiempo de espera agotado. Verifica tu conexión a internet.",
            );
          },
        );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Usuario.fromJson(data);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception("Error en registro: ${response.statusCode}. Detalles: ${errorBody['message'] ?? response.body}");
    }
  }

  Future<Usuario> obtenerUsuarioPorId(int id, String token) async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/usuario/$id'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        )
        .timeout(
          _timeout,
          onTimeout: () {
            throw Exception(
              "Tiempo de espera agotado. Verifica tu conexión a internet.",
            );
          },
        );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Usuario.fromJson(data);
    } else {
      throw Exception('Error al obtener el usuario');
    }
  }

  Future<Usuario> actualizarUsuario({
    required int id,
    required String nombre,
    required String correo,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/usuario/$id');

    final response = await http
        .put(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "id": id,
            "nombre": nombre,
            "correoElectronico": correo,
          }),
        )
        .timeout(
          _timeout,
          onTimeout: () {
            throw Exception(
              "Tiempo de espera agotado. Verifica tu conexión a internet.",
            );
          },
        );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Usuario.fromJson(data);
    } else {
      throw Exception("Error al actualizar usuario: ${response.statusCode}");
    }
  }

  Future<Usuario> cambiarContrasenia({
    required int id,
    required String nuevaContrasenia,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/usuario/$id');

    final response = await http
        .put(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({"id": id, "contrasenia": nuevaContrasenia}),
        )
        .timeout(
          _timeout,
          onTimeout: () {
            throw Exception(
              "Tiempo de espera agotado. Verifica tu conexión a internet.",
            );
          },
        );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Usuario.fromJson(data);
    } else {
      throw Exception("Error al cambiar contraseña: ${response.statusCode}");
    }
  }
}
