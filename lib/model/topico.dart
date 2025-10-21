class Topico {
  final int? id;
  final String titulo;
  final String mensaje;

  Topico({
    this.id,
    required this.titulo,
    required this.mensaje
  });

  factory Topico.fromJson(Map<String, dynamic> json){
    return Topico(
      id: json['id'] as int?,
      titulo: json['titulo'] as String,
      mensaje: json['mensaje'] as String,
    );
  }

  Map<String, dynamic> toJsonCreate(int idCategoria){
    return {
      'titulo': titulo,
      'mensaje': mensaje,
      'idCurso': idCategoria
    };
  }
}