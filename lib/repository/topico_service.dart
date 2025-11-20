import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../../model/topico.dart';
import '../../utils/token_storage.dart';


class TopicoService {
    final String baseUrl = dotenv.env['API_URL']!;
    
    // Timeout de 30 segundos para las peticiones
    static const Duration _timeout = Duration(seconds: 30);

  Future<List<Topico>> obtenerTopicos() async {
    final url = Uri.parse("$baseUrl/topico?size=1000");
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("No se encontró el token");
    }

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    ).timeout(_timeout, onTimeout: () {
      throw Exception("Tiempo de espera agotado. Verifica tu conexión a internet.");
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> contenido = data['content'];
      return contenido.map((json) => Topico.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception("Sesión expirada");
    } else if (response.statusCode == 403) {
      throw Exception("Sin permisos");
    } else {
      throw Exception("Error al cargar tópicos");
    }
  }

  Future<Topico> crearTopico(Topico topico, int idCurso) async {
    final url = Uri.parse("$baseUrl/topico");
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("No se encontró el token de autenticación");
    }

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(topico.toJsonCreate(idCurso)),
    ).timeout(_timeout, onTimeout: () {
      throw Exception("Tiempo de espera agotado. Verifica tu conexión a internet.");
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Topico.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Error al crear el tópico: ${response.statusCode} ${response.body}");
    }
  }
}