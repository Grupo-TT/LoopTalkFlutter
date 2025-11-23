import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loop_talk/main.dart';
import 'package:loop_talk/bloc/auth_bloc.dart';
import 'package:loop_talk/bloc/topico_bloc.dart';
import 'package:loop_talk/bloc/categoria_bloc.dart';
import 'package:loop_talk/bloc/create_topic_bloc.dart';
import 'helpers/test_helpers.mocks.dart';

void main() {
  // Declarar mocks para los servicios
  late MockLoopTalkServiceApi mockAuthService;
  late MockTopicoService mockTopicoService;
  late MockCategoriaService mockCategoriaService;

  // Declarar instancias de los BLoCs
  late AuthBloc authBloc;
  late TopicoBloc topicoBloc;
  late CategoriaBloc categoriaBloc;
  late CreateTopicBloc createTopicBloc;

  setUp(() {
    // Inicializar los mocks
    mockAuthService = MockLoopTalkServiceApi();
    mockTopicoService = MockTopicoService();
    mockCategoriaService = MockCategoriaService();

    // Inicializar los BLoCs con los mocks
    authBloc = AuthBloc(mockAuthService);
    topicoBloc = TopicoBloc(mockTopicoService);
    categoriaBloc = CategoriaBloc(mockCategoriaService);
    createTopicBloc = CreateTopicBloc(topicoService: mockTopicoService);
  });

  tearDown(() {
    // Cerrar los BLoCs
    authBloc.close();
    topicoBloc.close();
    categoriaBloc.close();
    createTopicBloc.close();
  });

  testWidgets('Smoke test: La app debería mostrar la pantalla de login inicial', (WidgetTester tester) async {
    // Construir la app con todos los providers necesarios
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc),
          BlocProvider.value(value: topicoBloc),
          BlocProvider.value(value: categoriaBloc),
          BlocProvider.value(value: createTopicBloc),
        ],
        child: const LoopTalkApp(),
      ),
    );

    // Esperar a que los widgets se rendericen
    await tester.pumpAndSettle();

    // Verificar que los elementos clave de la pantalla de login están presentes
    expect(find.text('¡Hola!'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Contraseña'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Ingresar'), findsOneWidget);
  });
}