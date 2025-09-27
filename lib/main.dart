import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'ui/vista_login.dart';

Future<void> main() async {
  // Cargar variables de entorno desde .env
  await dotenv.load(fileName: "assets/.env");

  runApp(const LoopTalkApp());
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
