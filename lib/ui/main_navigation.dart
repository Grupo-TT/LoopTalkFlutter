import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loop_talk/bloc/topico_bloc.dart';
import 'package:loop_talk/bloc/topico_event.dart';
import 'package:loop_talk/ui/create_topic_page.dart';
import 'package:loop_talk/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'vista_inicio.dart';
import 'vista_categorias.dart';
import 'vista_perfil.dart';
import 'vista_prueba.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../model/topico.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  static const _tutorialPrefKeyCreateLoop = 'tutorial_create_loop_shown';
  static const _tutorialPrefKeyCreateCategory =
      'tutorial_create_category_shown';

  int _currentIndex = 0;
  final GlobalKey _fabKey = GlobalKey();
  final GlobalKey _categoryFabKey = GlobalKey();
  final GlobalKey _bottomNavBarKey = GlobalKey();
  bool _tutorialAlreadySeen = false;
  bool _categoryTutorialSeen = false;
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
    final userId = _currentUserId();
    _tutorialAlreadySeen =
        prefs.getBool('${_tutorialPrefKeyCreateLoop}_$userId') ?? false;
    _categoryTutorialSeen =
        prefs.getBool('${_tutorialPrefKeyCreateCategory}_$userId') ?? false;
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
    final bool isEstudiante =
        authState is AuthSuccess &&
        authState.usuario.rol.name.toUpperCase() == 'ESTUDIANTE';

    // Construir listas de páginas e íconos según el rol
    final List<Widget> pages = isEstudiante
        ? [
            const VistaInicio(),
            VistaPerfil(
              onNavigateToHome: _onNavigateToHome,
              isActive: _currentIndex == 1,
            ),
            VistaPrueba(
              navBarKey: _bottomNavBarKey,
              isActive: _currentIndex == 2,
            ),
          ]
        : [
            const VistaInicio(),
            VistaCategorias(tutorialFabKey: _categoryFabKey),
            VistaPerfil(
              onNavigateToHome: _onNavigateToHome,
              isActive: _currentIndex == 2,
            ),
            VistaPrueba(
              navBarKey: _bottomNavBarKey,
              isActive: _currentIndex == 3,
            ),
          ];

    final List<String> pageTitles = isEstudiante
        ? ['Inicio', 'Perfil', 'Prueba']
        : ['Inicio', 'Categorías', 'Perfil', 'Prueba'];

    // Asegurar que _currentIndex está dentro del rango
    if (_currentIndex >= pages.length) {
      _currentIndex = 0;
    }

    // Ocultar AppBar cuando estemos en la vista de perfil o inicio (índice 0)
    // La última página (VistaPrueba) no tiene AppBar personalizado
    final bool showAppBar =
        _currentIndex != 0 &&
        _currentIndex != (pages.length - 2) &&
        _currentIndex != (pages.length - 1);

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(
                pageTitles[_currentIndex],
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: AppColors.scaffoldBg,
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: const [],
            )
          : null,
      body: IndexedStack(index: _currentIndex, children: pages),
      backgroundColor: AppColors.scaffoldBg,
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
              backgroundColor: AppColors.accentGreen,
              child: const Icon(
                Icons.chat_bubble,
                color: AppColors.scaffoldBg,
                size: 28,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          key: _bottomNavBarKey,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_currentIndex == 0) {
                _maybeShowTutorial();
              } else if (!isEstudiante && _currentIndex == 1) {
                _maybeShowCategoryTutorial();
              }
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.cardBg,
          selectedItemColor: AppColors.accentGreen,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          showUnselectedLabels: false,
          showSelectedLabels: false,
          elevation: 0,
          items: isEstudiante
              ? [
                  _buildNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: '',
                    index: 0,
                  ),
                  _buildNavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: '',
                    index: 1,
                  ),
                  _buildNavItem(
                    icon: Icons.analytics_outlined,
                    activeIcon: Icons.analytics,
                    label: '',
                    index: 2,
                  ),
                ]
              : [
                  _buildNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: '',
                    index: 0,
                  ),
                  _buildNavItem(
                    icon: Icons.explore_outlined,
                    activeIcon: Icons.explore,
                    label: '',
                    index: 1,
                  ),
                  _buildNavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: '',
                    index: 2,
                  ),
                  _buildNavItem(
                    icon: Icons.analytics_outlined,
                    activeIcon: Icons.analytics,
                    label: '',
                    index: 3,
                  ),
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
            builder: (context, controller) => _buildTutorialContent(
              title: 'Crea tu primer Loop',
              description:
                  'Toca este botón para compartir una idea o iniciar una conversación.',
              onNext: controller.next,
            ),
          ),
        ],
      ),
    ];

    _showCoachMark(
      targets: targets,
      onFinished: () => _markTutorialSeen(_tutorialPrefKeyCreateLoop),
    );
  }

  void _maybeShowCategoryTutorial() {
    if (!mounted || _currentIndex != 1 || _categoryTutorialSeen) {
      return;
    }
    if (_categoryFabKey.currentContext == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _maybeShowCategoryTutorial(),
      );
      return;
    }

    final targets = <TargetFocus>[
      TargetFocus(
        identify: 'create_category_fab',
        keyTarget: _categoryFabKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _buildTutorialContent(
              title: 'Crea una categoría',
              description:
                  'Como moderador puedes agregar nuevas categorías para organizar los Loops.',
              onNext: controller.next,
            ),
          ),
        ],
      ),
    ];

    _showCoachMark(
      targets: targets,
      onFinished: () => _markTutorialSeen(_tutorialPrefKeyCreateCategory),
    );
  }

  Widget _buildTutorialContent({
    required String title,
    required String description,
    required VoidCallback onNext,
  }) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
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

  void _showCoachMark({
    required List<TargetFocus> targets,
    required VoidCallback onFinished,
  }) {
    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black.withValues(alpha: 0.75),
      textSkip: 'Saltar',
      paddingFocus: 8,
      onFinish: onFinished,
      onSkip: () {
        onFinished();
        return true;
      },
    ).show(context: context);
  }

  void _markTutorialSeen(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = _currentUserId();
    await prefs.setBool('${key}_$userId', true);
    if (key == _tutorialPrefKeyCreateLoop) {
      _tutorialAlreadySeen = true;
    } else if (key == _tutorialPrefKeyCreateCategory) {
      _categoryTutorialSeen = true;
    }
  }

  String _currentUserId() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      return authState.usuario.id.toString();
    }
    return 'guest';
  }
}
