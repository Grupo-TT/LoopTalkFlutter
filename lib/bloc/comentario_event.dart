import 'package:equatable/equatable.dart';
import '../model/comentario.dart';

abstract class ComentarioEvent extends Equatable {
  const ComentarioEvent();

  @override
  List<Object?> get props => [];
}

class LoadRespuestas extends ComentarioEvent {
  final int topicoId;
  const LoadRespuestas(this.topicoId);

  @override
  List<Object?> get props => [topicoId];
}

class CreateRespuesta extends ComentarioEvent {
  final int topicoId;
  final Comentario comentario;

  const CreateRespuesta(this.topicoId, this.comentario);

  @override
  List<Object?> get props => [topicoId, comentario];
}
