import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'ui/vista_login.dart';
import 'repository/loop_talk_service_api.dart';
import 'repository/topico_service.dart';
import 'repository/categoria_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/auth_bloc.dart'; 
import 'bloc/topico_bloc.dart';
import 'bloc/categoria_bloc.dart';
import 'bloc/create_topic_bloc.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  try {
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Error inicializando Firebase: $e');
  }
  
  await dotenv.load(fileName: "assets/.env");
  
  final authService = LoopTalkServiceApi();
  final topicoService = TopicoService();
  final categoriaService = CategoriaService();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(authService),
        ),
        BlocProvider(
          create: (_) => TopicoBloc(topicoService),
        ),
        BlocProvider(
          create: (_) => CategoriaBloc(categoriaService),
        ),
        BlocProvider(
          create: (_) => CreateTopicBloc(topicoService: topicoService),
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

