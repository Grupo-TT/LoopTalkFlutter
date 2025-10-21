class Categoria {
  final int? id;
  final String nombre;
  final String descripcion;

  Categoria({this.id ,required this.nombre, required this.descripcion});

  factory Categoria.fromJson(Map<String, dynamic> json){
    return Categoria(
      id: json['id'] as int?,
      nombre: json['categoria'] as String,
      descripcion: json['nombre'] as String,
    );
  }

  Map<String, dynamic> toJsonCreate(){
    return {
      'nombre': nombre,
      'categoria': descripcion
    };
  }

  Map<String, dynamic> toJsonUpdate(){
    return {
      'id': id,
      'nombre': nombre,
      'categoria': descripcion
    };
  }

}