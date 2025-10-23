import 'package:equatable/equatable.dart';
import '../model/categoria.dart';

abstract class CategoriaEvent extends Equatable {
  const CategoriaEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategorias extends CategoriaEvent {}

class CreateCategoria extends CategoriaEvent {
  final Categoria categoria;

  const CreateCategoria(this.categoria);

  @override
  List<Object?> get props => [categoria];
}

class UpdateCategoria extends CategoriaEvent {
  final Categoria categoria;

  const UpdateCategoria(this.categoria);

  @override
  List<Object?> get props => [categoria];
}
