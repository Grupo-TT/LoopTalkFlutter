import 'package:equatable/equatable.dart';

class ActualizarTopicoRequest extends Equatable {
  final String titulo;
  final String mensaje;
  final String? estado;
  final int idCurso;

  const ActualizarTopicoRequest({
    required this.titulo,
    required this.mensaje,
    required this.idCurso,
    this.estado,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'titulo': titulo,
      'mensaje': mensaje,
      'idCurso': idCurso,
    };
    if (estado != null) {
      data['estado'] = estado;
    }
    return data;
  }

  @override
  List<Object?> get props => [titulo, mensaje, estado, idCurso];
}

