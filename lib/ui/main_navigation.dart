import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey[400],
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
                icon: Icons.category_outlined,
                activeIcon: Icons.category,
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
