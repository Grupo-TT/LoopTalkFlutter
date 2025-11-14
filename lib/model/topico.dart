import 'package:loop_talk/model/categoria.dart';
import 'package:loop_talk/model/usuario.dart';

class Topico {
  final int? id;
  final String titulo;
  final String mensaje;
  final String? estado;
  final String? fechaCreacion;
  final Usuario? autor;
  final Categoria? curso;

  Topico({
    this.id,
    required this.titulo,
    required this.mensaje,
    this.estado,
    this.fechaCreacion,
    this.autor,
    this.curso,
  });

  factory Topico.fromJson(Map<String, dynamic> json) {
    return Topico(
      id: json['id'] as int?,
      titulo: json['titulo'] as String,
      mensaje: json['mensaje'] as String,
      estado: json['estado'] as String?,
      fechaCreacion: json['fechaCreacion'] as String?,
      autor: json['autor'] != null ? Usuario.fromJson(json['autor']) : null,
      curso: json['curso'] != null ? Categoria.fromJson(json['curso']) : null,
    );
  }

  Map<String, dynamic> toJsonCreate(int idCurso) {
    return {'titulo': titulo, 'mensaje': mensaje, 'idCurso': idCurso};
  }
}