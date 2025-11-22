import 'package:mockito/annotations.dart';
import 'package:loop_talk/repository/categoria_service.dart';
import 'package:loop_talk/repository/comentario_service.dart';
import 'package:loop_talk/repository/topico_service.dart';
import 'package:loop_talk/repository/loop_talk_service_api.dart';

@GenerateMocks([CategoriaService, ComentarioService, TopicoService, LoopTalkServiceApi])
void main() {}
