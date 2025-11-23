import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../../utils/token_storage.dart';
import 'package:loop_talk/model/comentario.dart';
import 'dart:developer';

class ComentarioService {
  final String baseUrl = dotenv.env['API_URL']!;

  Future<List<Comentario>> obtenerRespuestas(int topicoId) async {
    final url = Uri.parse("$baseUrl/topico/$topicoId/respuestas");
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('No se encontró el token');
    }

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final dynamic body = jsonDecode(response.body);
      // Soporta dos formatos comunes: lista directa o objeto con 'content'
      final List<dynamic> items = (body is List)
          ? body
          : (body is Map && body['content'] is List)
              ? body['content'] as List<dynamic>
              : [];

      return items.map((json) => Comentario.fromJson(json as Map<String, dynamic>)).toList();
    } else if (response.statusCode == 204) {
      // No Content -> sin respuestas
      return <Comentario>[];
    } else if (response.statusCode == 401) {
      throw Exception('Sesión expirada');
    } else if (response.statusCode == 403) {
      throw Exception('Sin permisos');
    } else {
      throw Exception('Error al cargar las respuestas');
    }
  }

  Future<Comentario> crearRespuesta(int topicoId, Comentario comentario) async {
    final url = Uri.parse("$baseUrl/topico/$topicoId/respuestas");
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('No se encontró el token');
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(comentario.toJsonCreate(topicoId)),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      log('crearRespuesta: status=${response.statusCode} body=${response.body}');
      return Comentario.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('Sesión expirada');
    } else if (response.statusCode == 403) {
      throw Exception('Sin permisos');
    } else {
      log('crearRespuesta error: status=${response.statusCode} body=${response.body}');
      throw Exception('Error al crear la respuesta: ${response.statusCode}');
    }
  }
}