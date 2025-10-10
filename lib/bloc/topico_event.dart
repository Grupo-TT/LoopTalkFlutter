// lib/bloc/topico/topico_event.dart
import 'package:equatable/equatable.dart';

abstract class TopicoEvent extends Equatable {
  const TopicoEvent();

  @override
  List<Object?> get props => [];
}

class LoadTopicosEvent extends TopicoEvent {}
