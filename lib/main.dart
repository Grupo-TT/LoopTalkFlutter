import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'ui/vista_login.dart';
import 'repository/loop_talk_service_api.dart';
import 'repository/topico_service.dart'; // Importar TopicoService
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/auth_bloc.dart'; 
import 'bloc/topico_bloc.dart'; // Importar TopicoBloc

Future<void> main() async {
  // Cargar variables de entorno desde .env
  await dotenv.load(fileName: "assets/.env");
  final authService = LoopTalkServiceApi();
  final topicoService = TopicoService(); // Instanciar TopicoService


runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(authService),
        ),
        BlocProvider(
          create: (_) => TopicoBloc(topicoService),
        ),
      ],
      child: const LoopTalkApp(),
    ),
  );}

class LoopTalkApp extends StatelessWidget {
  const LoopTalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LoopTalk',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const VistaLogin(),
    );
    
  }
}

