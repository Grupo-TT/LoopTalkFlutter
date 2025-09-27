import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Evento para login
class LoginEvent extends AuthEvent {
  final String correo;
  final String contrasenia;

  LoginEvent(this.correo, this.contrasenia);

  @override
  List<Object?> get props => [correo, contrasenia];
}

/// Evento para registro
class RegisterEvent extends AuthEvent {
  final String nombre;
  final String correo;
  final String contrasenia;

  RegisterEvent(this.nombre, this.correo, this.contrasenia);

  @override
  List<Object?> get props => [nombre, correo, contrasenia];
}
