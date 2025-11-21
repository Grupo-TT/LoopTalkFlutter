import 'package:flutter_bloc/flutter_bloc.dart';
import 'comentario_event.dart';
import 'comentario_state.dart';
import '../repository/comentario_service.dart';

class ComentarioBloc extends Bloc<ComentarioEvent, ComentarioState> {
  final ComentarioService comentarioService;

  ComentarioBloc(this.comentarioService) : super(ComentarioInitial()) {
    on<LoadRespuestas>((event, emit) async {
      emit(ComentarioLoading());
      try {
        final respuestas = await comentarioService.obtenerRespuestas(event.topicoId);
        emit(ComentarioLoaded(respuestas));
      } catch (e) {
        emit(ComentarioError(e.toString()));
      }
    });

    on<CreateRespuesta>((event, emit) async {
      final prevState = state;
      emit(ComentarioLoading());
      try {
        final created = await comentarioService.crearRespuesta(event.topicoId, event.comentario);
        if (prevState is ComentarioLoaded) {
          final updated = List.of(prevState.respuestas)..add(created);
          emit(ComentarioLoaded(updated));
        } else {
          emit(ComentarioOperationSuccess(created));
        }
      } catch (e) {
        emit(ComentarioError(e.toString()));
      }
    });
  }
}
