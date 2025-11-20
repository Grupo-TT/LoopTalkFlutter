import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../../utils/token_storage.dart';
import 'package:loop_talk/model/categoria.dart';

class CategoriaService {
    final String baseUrl = dotenv.env['API_URL']!;
    
    // Timeout de 30 segundos para las peticiones
    static const Duration _timeout = Duration(seconds: 30);

    Future<List<Categoria>> obtenerCategorias() async{
      final url = Uri.parse("$baseUrl/curso");
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
        return contenido.map((json) => Categoria.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception("Sesión expirada");
      } else if (response.statusCode == 403) {
        throw Exception("Sin permisos");
      } else {
        throw Exception("Error al cargar las categorías");
      }
    }

    Future<Categoria> crearCategoria(Categoria categoria) async{

      final url = Uri.parse("$baseUrl/curso");
      final token = await TokenStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception("No se encontró el token");
      }

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(categoria.toJsonCreate()),
      ).timeout(_timeout, onTimeout: () {
        throw Exception("Tiempo de espera agotado. Verifica tu conexión a internet.");
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Categoria.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception("Sesión expirada");
      } else if (response.statusCode == 403) {
        throw Exception("Sin permisos");
      } else {
        throw Exception("Error al crear la categoría: ${response.statusCode}");
      }
    }

    Future<Categoria> actualizarCategoria(Categoria categoria) async{
      final url = Uri.parse("$baseUrl/curso/${categoria.id}");
      final token = await TokenStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception("No se encontró el token");
      }

      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(categoria.toJsonUpdate()),
      ).timeout(_timeout, onTimeout: () {
        throw Exception("Tiempo de espera agotado. Verifica tu conexión a internet.");
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Categoria.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception("Sesión expirada");
      } else if (response.statusCode == 403) {
        throw Exception("Sin permisos");
      } else {
        throw Exception("Error al actualizar la categoría: ${response.statusCode}");
      }
    }
}