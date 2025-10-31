import 'package:equatable/equatable.dart';
import '../../model/usuario.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthRegistered extends AuthState {}

class AuthSuccess extends AuthState {
  final Usuario usuario;
  AuthSuccess(this.usuario);

  @override
  List<Object?> get props => [usuario];
}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);

  @override
  List<Object?> get props => [error];
}
