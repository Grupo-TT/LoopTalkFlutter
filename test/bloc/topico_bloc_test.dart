import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:loop_talk/bloc/topico_bloc.dart';
import 'package:loop_talk/bloc/topico_event.dart';
import 'package:loop_talk/bloc/topico_state.dart';
import 'package:loop_talk/model/topico.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('TopicoBloc', () {
    late MockTopicoService mockTopicoService;
    late TopicoBloc topicoBloc;

    final tTopico1 = Topico(id: 1, titulo: 'Antiguo', mensaje: 'msg', fechaCreacion: '2025-01-01T10:00:00Z');
    final tTopico2 = Topico(id: 2, titulo: 'Reciente', mensaje: 'msg', fechaCreacion: '2025-11-22T10:00:00Z');
    final tTopicoSinFecha = Topico(id: 3, titulo: 'Sin Fecha', mensaje: 'msg');

    setUp(() {
      mockTopicoService = MockTopicoService();
      topicoBloc = TopicoBloc(mockTopicoService);
    });

    tearDown(() {
      topicoBloc.close();
    });

    test('el estado inicial debería ser TopicoInitial', () {
      expect(topicoBloc.state, TopicoInitial());
    });

    group('LoadTopicos', () {
      blocTest<TopicoBloc, TopicoState>(
        'debería emitir [TopicoLoading, TopicoLoaded] con tópicos ordenados cuando la carga es exitosa',
        build: () {
          // Devuelve la lista desordenada para probar la lógica de ordenamiento del BLoC
          when(mockTopicoService.obtenerTopicos()).thenAnswer((_) async => [tTopico1, tTopico2, tTopicoSinFecha]);
          return topicoBloc;
        },
        act: (bloc) => bloc.add(LoadTopicos()),
        expect: () => [
          TopicoLoading(),
          // La lista esperada debe estar ordenada por fecha descendente, con los nulos al final
          TopicoLoaded([tTopico2, tTopico1, tTopicoSinFecha]),
        ],
        verify: (_) {
          verify(mockTopicoService.obtenerTopicos()).called(1);
        },
      );

      blocTest<TopicoBloc, TopicoState>(
        'debería emitir [TopicoLoading, TopicoError] cuando la carga falla',
        build: () {
          when(mockTopicoService.obtenerTopicos()).thenThrow(Exception('Fallo al cargar tópicos'));
          return topicoBloc;
        },
        act: (bloc) => bloc.add(LoadTopicos()),
        expect: () => [
          TopicoLoading(),
          const TopicoError('Exception: Fallo al cargar tópicos'),
        ],
      );

      blocTest<TopicoBloc, TopicoState>(
        'debería manejar una lista vacía de tópicos',
        build: () {
          when(mockTopicoService.obtenerTopicos()).thenAnswer((_) async => []);
          return topicoBloc;
        },
        act: (bloc) => bloc.add(LoadTopicos()),
        expect: () => [
          TopicoLoading(),
          const TopicoLoaded([]),
        ],
      );
    });
  });
}
