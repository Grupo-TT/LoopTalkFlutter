import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:loop_talk/bloc/comentario_bloc.dart';
import 'package:loop_talk/bloc/comentario_event.dart';
import 'package:loop_talk/bloc/comentario_state.dart';
import 'package:loop_talk/model/comentario.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('ComentarioBloc', () {
    late MockComentarioService mockComentarioService;
    late ComentarioBloc comentarioBloc;

    const tTopicoId = 1;
    final tComentario = Comentario(id: 1, contenido: 'Respuesta de prueba');
    final tComentarioList = [tComentario];

    setUp(() {
      mockComentarioService = MockComentarioService();
      comentarioBloc = ComentarioBloc(mockComentarioService);
    });

    tearDown(() {
      comentarioBloc.close();
    });

    test('el estado inicial debería ser ComentarioInitial', () {
      expect(comentarioBloc.state, ComentarioInitial());
    });

    group('LoadRespuestas', () {
      blocTest<ComentarioBloc, ComentarioState>(
        'debería emitir [ComentarioLoading, ComentarioLoaded] cuando la carga es exitosa',
        build: () {
          when(mockComentarioService.obtenerRespuestas(any)).thenAnswer((_) async => tComentarioList);
          return comentarioBloc;
        },
        act: (bloc) => bloc.add(const LoadRespuestas(tTopicoId)),
        expect: () => [
          ComentarioLoading(),
          ComentarioLoaded(tComentarioList),
        ],
        verify: (_) {
          verify(mockComentarioService.obtenerRespuestas(tTopicoId)).called(1);
        },
      );

      blocTest<ComentarioBloc, ComentarioState>(
        'debería emitir [ComentarioLoading, ComentarioError] cuando la carga falla',
        build: () {
          when(mockComentarioService.obtenerRespuestas(any)).thenThrow(Exception('Fallo al cargar respuestas'));
          return comentarioBloc;
        },
        act: (bloc) => bloc.add(const LoadRespuestas(tTopicoId)),
        expect: () => [
          ComentarioLoading(),
          const ComentarioError('Exception: Fallo al cargar respuestas'),
        ],
      );
    });

    group('CreateRespuesta', () {
      final tNuevaRespuesta = Comentario(contenido: 'Nueva respuesta');
      final tRespuestaCreada = Comentario(id: 2, contenido: 'Nueva respuesta');

      blocTest<ComentarioBloc, ComentarioState>(
        'debería emitir [ComentarioLoading, ComentarioOperationSuccess] cuando se crea exitosamente desde un estado inicial',
        build: () {
          when(mockComentarioService.crearRespuesta(any, any)).thenAnswer((_) async => tRespuestaCreada);
          return comentarioBloc;
        },
        act: (bloc) => bloc.add(CreateRespuesta(tTopicoId, tNuevaRespuesta)),
        expect: () => [
          ComentarioLoading(),
          ComentarioOperationSuccess(tRespuestaCreada),
        ],
      );

      blocTest<ComentarioBloc, ComentarioState>(
        'debería emitir [ComentarioLoading, ComentarioLoaded] con la lista actualizada cuando se crea exitosamente desde ComentarioLoaded',
        build: () {
          when(mockComentarioService.crearRespuesta(any, any)).thenAnswer((_) async => tRespuestaCreada);
          return comentarioBloc;
        },
        seed: () => ComentarioLoaded(tComentarioList),
        act: (bloc) => bloc.add(CreateRespuesta(tTopicoId, tNuevaRespuesta)),
        expect: () => [
          ComentarioLoading(),
          ComentarioLoaded([...tComentarioList, tRespuestaCreada]),
        ],
      );

       blocTest<ComentarioBloc, ComentarioState>(
        'debería emitir [ComentarioLoading, ComentarioError] cuando la creación falla',
        build: () {
          when(mockComentarioService.crearRespuesta(any, any)).thenThrow(Exception('Fallo al crear respuesta'));
          return comentarioBloc;
        },
        act: (bloc) => bloc.add(CreateRespuesta(tTopicoId, tNuevaRespuesta)),
        expect: () => [
          ComentarioLoading(),
          const ComentarioError('Exception: Fallo al crear respuesta'),
        ],
      );
    });
  });
}
