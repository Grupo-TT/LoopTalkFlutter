import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'ui/vista_login.dart';
import 'repository/loop_talk_service_api.dart';
import 'repository/topico_service.dart'; // Importar TopicoService
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/auth_bloc.dart'; 
import 'bloc/topico_bloc.dart'; // Importar TopicoBloc

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  final authService = LoopTalkServiceApi();
  final topicoService = TopicoService();

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
  );
  
  FlutterNativeSplash.remove();
}

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

