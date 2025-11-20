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
