import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../model/topico.dart';


class TopicoService {
  final String baseUrl = dotenv.env['API_URL']!;

  Future<List<dynamic>> obtenerTopicos() async {
    final url = Uri.parse("$baseUrl/topico");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception("No se encontró el token. El usuario no ha iniciado sesión.");
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

      // ✅ Extraemos la lista de 'content'
      final List<dynamic> contenido = data['content'];

      // ✅ Convertimos cada elemento a un Topico
      return contenido.map((json) => Topico.fromJson(json)).toList();
    } else {
      throw Exception("Error: ${response.statusCode} - ${response.body}");
    }
  }
}