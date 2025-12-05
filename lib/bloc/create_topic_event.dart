part of 'create_topic_bloc.dart';

abstract class CreateTopicEvent extends Equatable {
  const CreateTopicEvent();

  @override
  List<Object> get props => [];
}

class CreateTopicSubmitted extends CreateTopicEvent {
  final String titulo;
  final String mensaje;
  final int idCurso;
  final String? fotoUrl;

  const CreateTopicSubmitted({
    required this.titulo,
    required this.mensaje,
    required this.idCurso,
    this.fotoUrl,
  });

  @override
  List<Object> get props => [titulo, mensaje, idCurso, fotoUrl ?? ''];
}

class UpdateTopicSubmitted extends CreateTopicEvent {
  final int topicoId;
  final String titulo;
  final String mensaje;
  final int idCurso;
  final String? estado;
  final String? fotoUrl;

  const UpdateTopicSubmitted({
    required this.topicoId,
    required this.titulo,
    required this.mensaje,
    required this.idCurso,
    this.estado,
    this.fotoUrl,
  });

  @override
  List<Object> get props => [
    topicoId,
    titulo,
    mensaje,
    idCurso,
    estado ?? '',
    fotoUrl ?? '',
  ];
}
