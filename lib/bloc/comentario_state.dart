import 'package:equatable/equatable.dart';
import '../model/comentario.dart';

abstract class ComentarioState extends Equatable {
  const ComentarioState();

  @override
  List<Object?> get props => [];
}

class ComentarioInitial extends ComentarioState {}

class ComentarioLoading extends ComentarioState {}

class ComentarioLoaded extends ComentarioState {
  final List<Comentario> respuestas;
  const ComentarioLoaded(this.respuestas);

  @override
  List<Object?> get props => [respuestas];
}

class ComentarioOperationSuccess extends ComentarioState {
  final Comentario comentario;
  const ComentarioOperationSuccess(this.comentario);

  @override
  List<Object?> get props => [comentario];
}

class ComentarioError extends ComentarioState {
  final String message;
  const ComentarioError(this.message);

  @override
  List<Object?> get props => [message];
}
