import 'package:loop_talk/model/usuario.dart';

class Comentario {
  final int? id;
  final String contenido;
  final String? fechaCreacion;
  final Usuario? autor;
  final int? topicoId;

  Comentario({
    this.id,
    required this.contenido,
    this.fechaCreacion,
    this.autor,
    this.topicoId,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      id: json['id'] as int?,
      contenido: json['contenido'] as String? ?? json['mensaje'] as String? ?? '',
      fechaCreacion: json['fechaCreacion'] as String?,
      autor: json['autor'] != null ? Usuario.fromJson(json['autor']) : null,
      topicoId: json['topicoId'] as int? ?? json['topico']?['id'] as int?,
    );
  }

  Map<String, dynamic> toJsonCreate(int topicoId) {
    return {
      'contenido': contenido,
      'topicoId': topicoId,
    };
  }
}

