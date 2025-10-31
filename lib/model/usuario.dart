import 'package:loop_talk/model/rol.dart';

class Usuario {
  final int id;
  final String nombre;
  final String correoElectronico;
  final String? contrasenia;
  final Rol rol;

  Usuario({
    required this.id,
    required this.nombre,
    required this.correoElectronico,
    required this.rol,
    this.contrasenia,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? json['username'] ?? 'Usuario',
      correoElectronico: json['correoElectronico'] ?? json['email'] ?? '',
      rol: _parseRol(json['rol']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'correoElectronico': correoElectronico,
      'rol': rol.name,
    };
  }

  Map<String, dynamic> toJsonLogin() {
    return {
      'correoElectronico': correoElectronico.toLowerCase(),
      'contrasenia': contrasenia,
    };
  }

  static Rol _parseRol(dynamic value) {
    if (value is Rol) return value;
    if (value is String) {
      try {
        return Rol.values.firstWhere(
          (r) => r.name.toUpperCase() == value.toUpperCase(),
          orElse: () => Rol.estudiante,
        );
      } catch (_) {
        return Rol.estudiante;
      }
    }
    return Rol.estudiante;
  }
}
