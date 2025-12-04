import '../model/topico.dart';
import '../model/usuario.dart';
import '../model/rol.dart';

bool canEditTopico({required Usuario? currentUser, required Topico topico}) {
  if (currentUser == null || topico.autor == null) {
    return false;
  }
  return currentUser.id == topico.autor?.id;
}

bool canDeleteTopico({required Usuario? currentUser, required Topico topico}) {
  if (currentUser == null) {
    return false;
  }
  final isAuthor = topico.autor != null && currentUser.id == topico.autor?.id;
  final rol = currentUser.rol;
  final isModerator = rol == Rol.moderador || rol == Rol.profesor;
  return isAuthor || isModerator;
}

