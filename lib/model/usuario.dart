import 'package:loop_talk/model/rol.dart';
class Usuario {
  final int id;
  final String nombre;
  final String correoElectronico;
  final String? password;
  final Rol rol;

  Usuario({
    required this.id,
    required this.nombre,
    required this.correoElectronico,
    required this.rol,
    this.password
  });

  /// Crear un Usuario desde JSON
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombre: json['nombre'],
      correoElectronico: json['correoElectronico'],
      rol: json['rol'],
    );
  }

  /// Convertir Usuario a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'correoElectronico': correoElectronico,
      'rol': rol,
    };
  }

  Map<String, dynamic> toJsonLogin() {
    return {
      'correoElectronico': correoElectronico.toLowerCase(),
      'contrasenia': password
    };
  }
}
