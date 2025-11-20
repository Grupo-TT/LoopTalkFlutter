import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:loop_talk/model/topico.dart';
import 'package:loop_talk/repository/topico_service.dart';

part 'create_topic_event.dart';
part 'create_topic_state.dart';

class CreateTopicBloc extends Bloc<CreateTopicEvent, CreateTopicState> {
  final TopicoService topicoService;

  CreateTopicBloc({required this.topicoService}) : super(CreateTopicInitial()) {
    on<CreateTopicSubmitted>(_onTopicSubmitted);
  }

  Future<void> _onTopicSubmitted(
    CreateTopicSubmitted event,
    Emitter<CreateTopicState> emit,
  ) async {
    emit(CreateTopicInProgress());
    try {
      final topico = Topico(titulo: event.titulo, mensaje: event.mensaje);
      final nuevoTopico = await topicoService.crearTopico(topico, event.idCurso);
      emit(CreateTopicSuccess(topico: nuevoTopico));
    } catch (e) {
      emit(CreateTopicFailure(error: e.toString()));
    }
  }
}
