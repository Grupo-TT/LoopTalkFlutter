import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../model/topico.dart';
import '../../utils/token_storage.dart';


class TopicoService {
  final String baseUrl = 'http://18.222.231.135:8080';

  Future<List<Topico>> obtenerTopicos() async {
    final url = Uri.parse("$baseUrl/topico");
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
    );

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
}