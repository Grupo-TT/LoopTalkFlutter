import 'package:equatable/equatable.dart';
import '../model/categoria.dart';

abstract class CategoriaState extends Equatable {
  const CategoriaState();

  @override
  List<Object?> get props => [];
}

class CategoriaInitial extends CategoriaState {}

class CategoriaLoading extends CategoriaState {}

class CategoriaLoaded extends CategoriaState {
  final List<Categoria> categorias;

  const CategoriaLoaded(this.categorias);

  @override
  List<Object?> get props => [categorias];
}

class CategoriaOperationSuccess extends CategoriaState {
  final Categoria categoria;

  const CategoriaOperationSuccess(this.categoria);

  @override
  List<Object?> get props => [categoria];
}

class CategoriaError extends CategoriaState {
  final String message;

  const CategoriaError(this.message);

  @override
  List<Object?> get props => [message];
}
