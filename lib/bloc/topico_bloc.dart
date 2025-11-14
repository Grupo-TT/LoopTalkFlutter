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
        topicos.sort((a, b) {
          final dateA = a.fechaCreacion != null ? DateTime.tryParse(a.fechaCreacion!) : null;
          final dateB = b.fechaCreacion != null ? DateTime.tryParse(b.fechaCreacion!) : null;
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1; // a es más antiguo
          if (dateB == null) return -1; // b es más antiguo
          return dateB.compareTo(dateA); // Orden descendente
        });
        emit(TopicoLoaded(topicos));
      } catch (e) {
        emit(TopicoError(e.toString()));
      }
    });
  }
}