import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../repository/loop_talk_service_api.dart';
import '../../utils/token_storage.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoopTalkServiceApi authService;

  AuthBloc(this.authService) : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final token = await authService.login(event.correo, event.contrasenia);
        await TokenStorage.saveToken(token);

        final decoded = JwtDecoder.decode(token);
        final userId = decoded['id'];
        final usuario = await authService.obtenerUsuarioPorId(userId, token);

        emit(AuthSuccess(usuario));
      } catch (e) {
        final message = e.toString().replaceFirst('Exception:', '');
        emit(AuthFailure(message));
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
        final message = e.toString().replaceFirst('Exception:', '');
        emit(AuthFailure(message));
      }
    });

    on<LogoutEvent>((event, emit) async {
      await TokenStorage.deleteToken();
      emit(AuthInitial());
    });

    on<UpdateProfileEvent>((event, emit) async {
      final currentState = state;
      if (currentState is AuthSuccess) {
        emit(AuthLoading());
        try {
          final usuarioActual = currentState.usuario;
          final token = await TokenStorage.getToken();

          if (token == null) throw Exception("Token no encontrado");

          // Llamada al endpoint PUT
          final usuarioActualizado = await authService.actualizarUsuario(
            id: usuarioActual.id,
            nombre: event.nombre,
            correo: event.correoElectronico,
            token: token,
          );

          emit(AuthSuccess(usuarioActualizado));
        } catch (e) {
          emit(AuthFailure("Error al actualizar el perfil: $e"));
        }
      }
    });
  }
}
