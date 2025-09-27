class Usuario {
  final int id;
  final String nombre;
  final String correoElectronico;
  final String rol;

  Usuario({
    required this.id,
    required this.nombre,
    required this.correoElectronico,
    required this.rol,
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
}
