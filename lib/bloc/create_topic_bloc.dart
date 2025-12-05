import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:loop_talk/model/topico.dart';
import 'package:loop_talk/repository/topico_service.dart';
import 'package:loop_talk/model/requests/actualizar_topico_request.dart';

part 'create_topic_event.dart';
part 'create_topic_state.dart';

class CreateTopicBloc extends Bloc<CreateTopicEvent, CreateTopicState> {
  final TopicoService topicoService;

  CreateTopicBloc({required this.topicoService}) : super(CreateTopicInitial()) {
    on<CreateTopicSubmitted>(_onTopicSubmitted);
    on<UpdateTopicSubmitted>(_onUpdateTopicSubmitted);
  }

  Future<void> _onTopicSubmitted(
    CreateTopicSubmitted event,
    Emitter<CreateTopicState> emit,
  ) async {
    emit(CreateTopicInProgress());
    try {
      final topico = Topico(
        titulo: event.titulo,
        mensaje: event.mensaje,
        fotoUrl: event.fotoUrl,
      );
      final nuevoTopico = await topicoService.crearTopico(
        topico,
        event.idCurso,
      );
      emit(CreateTopicSuccess(topico: nuevoTopico));
    } catch (e) {
      emit(CreateTopicFailure(error: e.toString()));
    }
  }

  Future<void> _onUpdateTopicSubmitted(
    UpdateTopicSubmitted event,
    Emitter<CreateTopicState> emit,
  ) async {
    emit(CreateTopicInProgress());
    try {
      final request = ActualizarTopicoRequest(
        titulo: event.titulo,
        mensaje: event.mensaje,
        idCurso: event.idCurso,
        estado: event.estado,
      );
      final actualizado = await topicoService.actualizarTopico(
        topicoId: event.topicoId,
        request: request,
      );
      emit(CreateTopicSuccess(topico: actualizado, isUpdate: true));
    } catch (e) {
      emit(CreateTopicFailure(error: e.toString()));
    }
  }
}
