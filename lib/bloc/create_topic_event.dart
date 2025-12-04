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

  const CreateTopicSubmitted({
    required this.titulo,
    required this.mensaje,
    required this.idCurso,
  });

  @override
  List<Object> get props => [titulo, mensaje, idCurso];
}

class UpdateTopicSubmitted extends CreateTopicEvent {
  final int topicoId;
  final String titulo;
  final String mensaje;
  final int idCurso;
  final String? estado;

  const UpdateTopicSubmitted({
    required this.topicoId,
    required this.titulo,
    required this.mensaje,
    required this.idCurso,
    this.estado,
  });

  @override
  List<Object> get props => [topicoId, titulo, mensaje, idCurso, estado ?? ''];
}