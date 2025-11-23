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

/// Evento para cerrar sesión
class LogoutEvent extends AuthEvent {}

class RefreshAuth extends AuthEvent {}

/// Evento para actualizar perfil del usuario
class UpdateProfileEvent extends AuthEvent {
  final String nombre;
  final String correoElectronico;

  UpdateProfileEvent({required this.nombre, required this.correoElectronico});

  @override
  List<Object?> get props => [nombre, correoElectronico];
}

/// Evento para actualizar contraseña del usuario
class UpdatePasswordEvent extends AuthEvent {
  final String nuevaContrasenia;

  UpdatePasswordEvent({required this.nuevaContrasenia});

  @override
  List<Object?> get props => [nuevaContrasenia];
}
