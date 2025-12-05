import 'package:loop_talk/model/rol.dart';

class Usuario {
  final int id;
  final String nombre;
  final String correoElectronico;
  final String? contrasenia;
  final Rol rol;
  final String? fotoUrl;

  Usuario({
    required this.id,
    required this.nombre,
    required this.correoElectronico,
    required this.rol,
    this.contrasenia,
    this.fotoUrl,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? json['username'] ?? 'Usuario',
      correoElectronico: json['correoElectronico'] ?? json['email'] ?? '',
      rol: _parseRol(json['rol']),
      fotoUrl: json['fotoUrl'] as String?,
    );
  }

  /// Creates a copy of this Usuario with the given fields replaced with new values.
  Usuario copyWith({
    int? id,
    String? nombre,
    String? correoElectronico,
    String? contrasenia,
    Rol? rol,
    String? fotoUrl,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      correoElectronico: correoElectronico ?? this.correoElectronico,
      contrasenia: contrasenia ?? this.contrasenia,
      rol: rol ?? this.rol,
      fotoUrl: fotoUrl ?? this.fotoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'correoElectronico': correoElectronico,
      'rol': rol.name,
      if (fotoUrl != null) 'fotoUrl': fotoUrl,
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
