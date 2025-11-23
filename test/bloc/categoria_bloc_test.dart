import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:loop_talk/bloc/categoria_bloc.dart';
import 'package:loop_talk/bloc/categoria_event.dart';
import 'package:loop_talk/bloc/categoria_state.dart';
import 'package:loop_talk/model/categoria.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('CategoriaBloc', () {
    late MockCategoriaService mockCategoriaService;
    late CategoriaBloc categoriaBloc;

    final tCategoria = Categoria(id: 1, nombre: 'Prueba', descripcion: 'Descripción de prueba');
    final tCategoriaList = [tCategoria];

    setUp(() {
      mockCategoriaService = MockCategoriaService();
      categoriaBloc = CategoriaBloc(mockCategoriaService);
    });

    tearDown(() {
      categoriaBloc.close();
    });

    test('el estado inicial debería ser CategoriaInitial', () {
      expect(categoriaBloc.state, CategoriaInitial());
    });

    group('LoadCategorias', () {
      blocTest<CategoriaBloc, CategoriaState>(
        'debería emitir [CategoriaLoading, CategoriaLoaded] cuando la carga es exitosa',
        build: () {
          when(mockCategoriaService.obtenerCategorias()).thenAnswer((_) async => tCategoriaList);
          return categoriaBloc;
        },
        act: (bloc) => bloc.add(LoadCategorias()),
        expect: () => [
          CategoriaLoading(),
          CategoriaLoaded(tCategoriaList),
        ],
        verify: (_) {
          verify(mockCategoriaService.obtenerCategorias()).called(1);
        },
      );

      blocTest<CategoriaBloc, CategoriaState>(
        'debería emitir [CategoriaLoading, CategoriaError] cuando la carga falla',
        build: () {
          when(mockCategoriaService.obtenerCategorias()).thenThrow(Exception('Fallo al cargar'));
          return categoriaBloc;
        },
        act: (bloc) => bloc.add(LoadCategorias()),
        expect: () => [
          CategoriaLoading(),
          const CategoriaError('Exception: Fallo al cargar'),
        ],
      );
    });

    group('CreateCategoria', () {
      final tNuevaCategoria = Categoria(nombre: 'Nueva', descripcion: 'Nueva desc');
      final tCategoriaCreada = Categoria(id: 2, nombre: 'Nueva', descripcion: 'Nueva desc');

      blocTest<CategoriaBloc, CategoriaState>(
        'debería emitir [CategoriaLoading, CategoriaOperationSuccess] cuando se crea exitosamente desde un estado inicial',
        build: () {
          when(mockCategoriaService.crearCategoria(any)).thenAnswer((_) async => tCategoriaCreada);
          return categoriaBloc;
        },
        act: (bloc) => bloc.add(CreateCategoria(tNuevaCategoria)),
        expect: () => [
          CategoriaLoading(),
          CategoriaOperationSuccess(tCategoriaCreada),
        ],
      );

      blocTest<CategoriaBloc, CategoriaState>(
        'debería emitir [CategoriaLoading, CategoriaLoaded] con la lista actualizada cuando se crea exitosamente desde CategoriaLoaded',
        build: () {
          when(mockCategoriaService.crearCategoria(any)).thenAnswer((_) async => tCategoriaCreada);
          return categoriaBloc;
        },
        seed: () => CategoriaLoaded(tCategoriaList),
        act: (bloc) => bloc.add(CreateCategoria(tNuevaCategoria)),
        expect: () => [
          CategoriaLoading(),
          CategoriaLoaded([...tCategoriaList, tCategoriaCreada]),
        ],
      );

       blocTest<CategoriaBloc, CategoriaState>(
        'debería emitir [CategoriaLoading, CategoriaError] cuando la creación falla',
        build: () {
          when(mockCategoriaService.crearCategoria(any)).thenThrow(Exception('Fallo al crear'));
          return categoriaBloc;
        },
        act: (bloc) => bloc.add(CreateCategoria(tNuevaCategoria)),
        expect: () => [
          CategoriaLoading(),
          const CategoriaError('Exception: Fallo al crear'),
        ],
      );
    });

    group('UpdateCategoria', () {
      final tCategoriaActualizada = Categoria(id: 1, nombre: 'Actualizada', descripcion: 'Desc actualizada');

      blocTest<CategoriaBloc, CategoriaState>(
        'debería emitir [CategoriaLoading, CategoriaOperationSuccess] cuando se actualiza exitosamente desde un estado inicial',
        build: () {
          when(mockCategoriaService.actualizarCategoria(any)).thenAnswer((_) async => tCategoriaActualizada);
          return categoriaBloc;
        },
        act: (bloc) => bloc.add(UpdateCategoria(tCategoriaActualizada)),
        expect: () => [
          CategoriaLoading(),
          CategoriaOperationSuccess(tCategoriaActualizada),
        ],
      );

      blocTest<CategoriaBloc, CategoriaState>(
        'debería emitir [CategoriaLoading, CategoriaLoaded] con la lista actualizada cuando se actualiza exitosamente desde CategoriaLoaded',
        build: () {
          when(mockCategoriaService.actualizarCategoria(any)).thenAnswer((_) async => tCategoriaActualizada);
          return categoriaBloc;
        },
        seed: () => CategoriaLoaded(tCategoriaList),
        act: (bloc) => bloc.add(UpdateCategoria(tCategoriaActualizada)),
        expect: () => [
          CategoriaLoading(),
          CategoriaLoaded([tCategoriaActualizada]),
        ],
      );

       blocTest<CategoriaBloc, CategoriaState>(
        'debería emitir [CategoriaLoading, CategoriaError] cuando la actualización falla',
        build: () {
          when(mockCategoriaService.actualizarCategoria(any)).thenThrow(Exception('Fallo al actualizar'));
          return categoriaBloc;
        },
        act: (bloc) => bloc.add(UpdateCategoria(tCategoriaActualizada)),
        expect: () => [
          CategoriaLoading(),
          const CategoriaError('Exception: Fallo al actualizar'),
        ],
      );
    });
  });
}
