// lib/bloc/topico/topico_state.dart
import 'package:equatable/equatable.dart';
import '../../model/topico.dart';

abstract class TopicoState extends Equatable {
  const TopicoState();

  @override
  List<Object?> get props => [];
}

class TopicoInitial extends TopicoState {}

class TopicoLoading extends TopicoState {}

class TopicoLoaded extends TopicoState {
  final List<Topico> topicos;

  const TopicoLoaded(this.topicos);

  @override
  List<Object?> get props => [topicos];
}

class TopicoFailure extends TopicoState {
  final String error;

  const TopicoFailure(this.error);

  @override
  List<Object?> get props => [error];
}
