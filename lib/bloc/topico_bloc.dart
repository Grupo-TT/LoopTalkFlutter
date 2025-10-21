import 'package:flutter_bloc/flutter_bloc.dart';
import 'topico_event.dart';
import 'topico_state.dart';
import '../../repository/topico_service.dart';
import '../../model/topico.dart';

class TopicoBloc extends Bloc<TopicoEvent, TopicoState> {
  final TopicoService topicoService;

  TopicoBloc(this.topicoService) : super(TopicoInitial()) {
    on<LoadTopicos>((event, emit) async {
      emit(TopicoLoading());
      try {
        List<Topico> topicos = await topicoService.obtenerTopicos();
        emit(TopicoLoaded(topicos));
      } catch (e) {
        emit(TopicoError(e.toString()));
      }
    });
  }
}