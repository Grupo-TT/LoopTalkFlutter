// lib/bloc/topico/topico_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'topico_event.dart';
import 'topico_state.dart';
import '../../repository/topico_service.dart';
import '../../model/topico.dart';

class TopicoBloc extends Bloc<TopicoEvent, TopicoState> {
  final TopicoService service;

  TopicoBloc(this.service) : super(TopicoInitial()) {
    on<LoadTopicosEvent>((event, emit) async {
      emit(TopicoLoading());
      try {
        final response = await service.obtenerTopicos();
        final topicos = response.map((e) => Topico.fromJson(e)).toList();
        emit(TopicoLoaded(topicos));
      } catch (e) {
        emit(TopicoFailure(e.toString()));
      }
    });
  }
}
