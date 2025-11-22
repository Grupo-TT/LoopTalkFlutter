import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loop_talk/bloc/topico_bloc.dart';
import 'package:loop_talk/bloc/topico_event.dart';
import 'package:loop_talk/ui/create_topic_page.dart';
import 'vista_inicio.dart';
import 'vista_categorias.dart';
import 'vista_notificaciones.dart';
import 'vista_perfil.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void _onNavigateToHome() {
    setState(() {
      _currentIndex = 0;
    });
  }

  List<Widget> get _pages => [
    const VistaInicio(),
    const VistaCategorias(),
    const VistaNotificaciones(),
    VistaPerfil(onNavigateToHome: _onNavigateToHome),
  ];

  List<String> get _pageTitles => [
    'Inicio',
    'Categorías',
    'Notificaciones',
    'Perfil',
  ];

  @override
  Widget build(BuildContext context) {
    // Ocultar AppBar cuando estemos en la vista de perfil (índice 3) o inicio (índice 0)
    final bool showAppBar = _currentIndex != 3 && _currentIndex != 0;
    
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(
                _pageTitles[_currentIndex],
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
      body: IndexedStack(index: _currentIndex, children: _pages),
      backgroundColor: Colors.white,
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateTopicPage(),
                  ),
                ).then((_) {
                  if (!mounted) return;
                  context.read<TopicoBloc>().add(LoadTopicos());
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
            items: [
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
                icon: Icons.notifications_outlined,
                activeIcon: Icons.notifications,
                label: '',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
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
}
