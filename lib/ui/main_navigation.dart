import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loop_talk/bloc/topico_bloc.dart';
import 'package:loop_talk/bloc/topico_event.dart';
import 'package:loop_talk/ui/create_topic_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'vista_inicio.dart';
import 'vista_categorias.dart';
import 'vista_perfil.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../model/topico.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  static const _tutorialPrefKey = 'tutorial_create_loop_shown';
  int _currentIndex = 0;
  final GlobalKey _fabKey = GlobalKey();
  bool _tutorialAlreadySeen = false;
  bool _isCheckingTutorial = false;

  @override
  void initState() {
    super.initState();
    _loadTutorialPreference();
  }

  Future<void> _loadTutorialPreference() async {
    if (_isCheckingTutorial) return;
    _isCheckingTutorial = true;
    final prefs = await SharedPreferences.getInstance();
    _tutorialAlreadySeen = prefs.getBool(_tutorialPrefKey) ?? false;
    _isCheckingTutorial = false;
    if (!_tutorialAlreadySeen && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowTutorial());
    }
  }

  void _onNavigateToHome() {
    setState(() {
      _currentIndex = 0;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowTutorial());
  }

  // Pages and titles are built dynamically in build() based on user role.

  @override
  Widget build(BuildContext context) {
    // showAppBar se calcula después de construir las páginas (depende del índice final de Perfil)
    
    // Obtener rol desde AuthBloc (si está autenticado)
    final authState = context.read<AuthBloc>().state;
    final bool isEstudiante = authState is AuthSuccess && authState.usuario.rol.name.toUpperCase() == 'ESTUDIANTE';

    // Construir listas de páginas e íconos según el rol
    final List<Widget> pages = isEstudiante
        ? [
            const VistaInicio(),
            VistaPerfil(onNavigateToHome: _onNavigateToHome),
          ]
        : [
            const VistaInicio(),
            const VistaCategorias(),
            VistaPerfil(onNavigateToHome: _onNavigateToHome),
          ];

    final List<String> pageTitles = isEstudiante
        ? ['Inicio', 'Perfil']
        : ['Inicio', 'Categorías', 'Perfil'];

    // Asegurar que _currentIndex está dentro del rango
    if (_currentIndex >= pages.length) {
      _currentIndex = 0;
    }

    // Ocultar AppBar cuando estemos en la vista de perfil (última página) o inicio (índice 0)
    final bool showAppBar = _currentIndex != 0 && _currentIndex != (pages.length - 1);

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(
                pageTitles[_currentIndex],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.deepPurple,
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: const [],
            )
          : null,
      body: IndexedStack(index: _currentIndex, children: pages),
      backgroundColor: Colors.white,
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              key: _fabKey,
              onPressed: () {
                final topicoBloc = context.read<TopicoBloc>();
                Navigator.push<Topico?>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateTopicPage(),
                  ),
                ).then((_) {
                  if (!mounted) return;
                  topicoBloc.add(LoadTopicos());
                });
              },
              backgroundColor: Colors.black87,
              child: const Icon(
                Icons.chat_bubble,
                color: Colors.white,
                size: 28,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowTutorial());
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black87,
          unselectedItemColor: Colors.grey[500],
          selectedFontSize: 0,
          unselectedFontSize: 0,
          showUnselectedLabels: false,
          showSelectedLabels: false,
          elevation: 0,
            items: isEstudiante
                ? [
                    _buildNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: '', index: 0),
                    _buildNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: '', index: 1),
                  ]
                : [
                    _buildNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: '', index: 0),
                    _buildNavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore, label: '', index: 1),
                    _buildNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: '', index: 2),
                  ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: Icon(isActive ? activeIcon : icon, size: 28),
      label: label,
    );
  }

  void _maybeShowTutorial() {
    if (!mounted || _tutorialAlreadySeen || _currentIndex != 0) {
      return;
    }
    if (_fabKey.currentContext == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowTutorial());
      return;
    }

    final targets = <TargetFocus>[
      TargetFocus(
        identify: 'create_loop_fab',
        keyTarget: _fabKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _buildTutorialContent(() {
              controller.next();
            }),
          ),
        ],
      ),
    ];

    final tutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black.withValues(alpha: 0.75),
      textSkip: 'Saltar',
      paddingFocus: 8,
      onFinish: _markTutorialSeen,
      onSkip: () {
        _markTutorialSeen();
        return true;
      },
    );
    tutorial.show(context: context);
  }

  Widget _buildTutorialContent(VoidCallback onNext) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Crea tu primer Loop',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toca este botón para compartir una idea o iniciar una conversación.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onNext,
              child: const Text('Entendido'),
            ),
          ),
        ],
      ),
    );
  }

  void _markTutorialSeen() async {
    if (_tutorialAlreadySeen) return;
    _tutorialAlreadySeen = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialPrefKey, true);
  }
}
