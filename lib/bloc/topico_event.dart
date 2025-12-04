import 'package:equatable/equatable.dart';

abstract class TopicoEvent extends Equatable {
  const TopicoEvent();

  @override
  List<Object> get props => [];
}

class LoadTopicos extends TopicoEvent {}

class DeleteTopico extends TopicoEvent {
  final int topicoId;

  const DeleteTopico(this.topicoId);

  @override
  List<Object> get props => [topicoId];
}