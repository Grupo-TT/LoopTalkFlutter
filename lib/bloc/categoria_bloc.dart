import 'package:flutter_bloc/flutter_bloc.dart';
import 'categoria_event.dart';
import 'categoria_state.dart';
import '../repository/categoria_service.dart';

class CategoriaBloc extends Bloc<CategoriaEvent, CategoriaState> {
  final CategoriaService categoriaService;

  CategoriaBloc(this.categoriaService) : super(CategoriaInitial()) {
    on<LoadCategorias>((event, emit) async {
      emit(CategoriaLoading());
      try {
        final categorias = await categoriaService.obtenerCategorias();
        emit(CategoriaLoaded(categorias));
      } catch (e) {
        emit(CategoriaError(e.toString()));
      }
    });

    on<CreateCategoria>((event, emit) async {
      // Guardamos el estado previo para poder actualizar la lista localmente si ya estaba cargada
      final prevState = state;
      emit(CategoriaLoading());
      try {
        final created = await categoriaService.crearCategoria(event.categoria);
        // Si antes había una lista cargada, añadimos la nueva categoría localmente
        if (prevState is CategoriaLoaded) {
          final updated = List.of(prevState.categorias)..add(created);
          emit(CategoriaLoaded(updated));
        } else {
          emit(CategoriaOperationSuccess(created));
        }
      } catch (e) {
        emit(CategoriaError(e.toString()));
      }
    });

    on<UpdateCategoria>((event, emit) async {
      final prevState = state;
      emit(CategoriaLoading());
      try {
        final updated = await categoriaService.actualizarCategoria(event.categoria);
        if (prevState is CategoriaLoaded) {
          final updatedList = prevState.categorias.map((c) => c.id == updated.id ? updated : c).toList();
          emit(CategoriaLoaded(updatedList));
        } else {
          emit(CategoriaOperationSuccess(updated));
        }
      } catch (e) {
        emit(CategoriaError(e.toString()));
      }
    });
  }
}
