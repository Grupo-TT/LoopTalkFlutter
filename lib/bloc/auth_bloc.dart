import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../repository/loop_talk_service_api.dart';
import '../../model/usuario.dart';
import '../../utils/token_storage.dart';
import 'package:loop_talk/model/rol.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoopTalkServiceApi authService;

  AuthBloc(this.authService) : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final token = await authService.login(event.correo, event.contrasenia);
        await TokenStorage.saveToken(token);

        final usuario = Usuario(
          id: 0,
          nombre: "Usuario",
          correoElectronico: event.correo,
          rol: Rol.estudiante,
        );

        emit(AuthSuccess(usuario));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<RegisterEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final usuario = await authService.registrarUsuario(
          nombre: event.nombre,
          correo: event.correo,
          contrasenia: event.contrasenia,
        );

        emit(AuthSuccess(usuario));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LogoutEvent>((event, emit) async {
      await TokenStorage.deleteToken();
      emit(AuthInitial());
    });
  }
}
