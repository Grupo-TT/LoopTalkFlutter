import 'package:equatable/equatable.dart';
import '../../model/topico.dart';

abstract class TopicoState extends Equatable {
  const TopicoState();

  @override
  List<Object> get props => [];
}

class TopicoInitial extends TopicoState {}

class TopicoLoading extends TopicoState {}

class TopicoLoaded extends TopicoState {
  final List<Topico> topicos;

  const TopicoLoaded(this.topicos);

  @override
  List<Object> get props => [topicos];
}

class TopicoActionInProgress extends TopicoLoaded {
  const TopicoActionInProgress(List<Topico> topicos) : super(topicos);
}

class TopicoActionSuccess extends TopicoLoaded {
  final String message;
  final int? affectedTopicoId;

  const TopicoActionSuccess(
    List<Topico> topicos, {
    required this.message,
    this.affectedTopicoId,
  }) : super(topicos);

  @override
  List<Object> get props => [...super.props, message, affectedTopicoId ?? -1];
}

class TopicoActionFailure extends TopicoLoaded {
  final String message;
  final int? affectedTopicoId;

  const TopicoActionFailure(
    List<Topico> topicos, {
    required this.message,
    this.affectedTopicoId,
  }) : super(topicos);

  @override
  List<Object> get props => [...super.props, message, affectedTopicoId ?? -1];
}

class TopicoError extends TopicoState {
  final String message;

  const TopicoError(this.message);

  @override
  List<Object> get props => [message];
}