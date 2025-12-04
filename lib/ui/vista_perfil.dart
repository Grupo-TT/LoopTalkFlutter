import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'vista_login.dart';
import 'vista_editar_perfil.dart';
import 'vista_cambiar_password.dart';

class VistaPerfil extends StatefulWidget {
  final VoidCallback? onNavigateToHome;
  final bool isActive;

  const VistaPerfil({super.key, this.onNavigateToHome, this.isActive = false});

  @override
  State<VistaPerfil> createState() => _VistaPerfilState();
}

class _VistaPerfilState extends State<VistaPerfil> {
  static const _tutorialProfileKey = 'tutorial_profile_shown';
  final GlobalKey _editProfileKey = GlobalKey();
  bool _profileTutorialSeen = true;

  @override
  void initState() {
    super.initState();
    _loadProfileTutorial();
  }

  @override
  void didUpdateWidget(covariant VistaPerfil oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_profileTutorialSeen && widget.isActive && !oldWidget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowProfileTutorial());
    }
  }

  Future<void> _loadProfileTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = _currentUserId();
    final seen = prefs.getBool('${_tutorialProfileKey}_$userId') ?? false;
    _profileTutorialSeen = seen;
    if (!seen && widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowProfileTutorial());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess) {
              final usuario = state.usuario;

              return Column(
                children: [
                  // Header personalizado
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: Row(
                        children: [
                          // Botón cuadrado para volver a home
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!, width: 1.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.black87,
                                size: 20,
                              ),
                              onPressed: () {
                                widget.onNavigateToHome?.call();
                              },
                            ),
                          ),
                          const Spacer(),
                          // Título "Perfil"
                          const Text(
                            'Perfil',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          // Espacio para balancear
                          const SizedBox(width: 40),
                        ],
                      ),
                    ),
                  ),
                  // Contenido
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black, width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.black,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              usuario.nombre,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              usuario.correoElectronico,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    _buildSectionTitle('General'),
                    const SizedBox(height: 12),
                    _buildGeneralSection(context),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Sesión'),
                    const SizedBox(height: 12),
                          _buildSessionSection(context),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return const Center(child: Text("No hay usuario autenticado"));
            }
          },
        ),
      ),
    );
  }

  void _maybeShowProfileTutorial() {
    if (!mounted || _profileTutorialSeen || !widget.isActive) {
      return;
    }
    if (_editProfileKey.currentContext == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowProfileTutorial());
      return;
    }

    final targets = [
      TargetFocus(
        identify: 'edit_profile_item',
        keyTarget: _editProfileKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => _buildProfileTutorialContent(
              title: 'Personaliza tu perfil',
              description: 'Aquí puedes editar tu perfil cuando lo necesites.',
              onNext: controller.next,
            ),
          ),
        ],
      ),
    ];

    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black.withValues(alpha: 0.75),
      textSkip: 'Saltar',
      paddingFocus: 8,
      onFinish: _markProfileTutorialSeen,
      onSkip: () {
        _markProfileTutorialSeen();
        return true;
      },
    ).show(context: context);
  }

  Widget _buildProfileTutorialContent({
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

  Future<void> _markProfileTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = _currentUserId();
    await prefs.setBool('${_tutorialProfileKey}_$userId', true);
    _profileTutorialSeen = true;
  }

  String _currentUserId() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      return authState.usuario.id.toString();
    }
    return 'guest';
  }

  void _cerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout,
                    size: 32,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 20),
                // Título
                const Text(
                  '¿Cerrar sesión?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                // Descripción
                Text(
                  'Estás a punto de salir de tu cuenta en este dispositivo. Podrás volver a entrar iniciando sesión nuevamente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Botones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          context.read<AuthBloc>().add(LogoutEvent());
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const VistaLogin()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cerrar sesión',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.grey[500],
      ),
    );
  }

  Widget _buildGeneralSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            itemKey: _editProfileKey,
            icon: Icons.person_outline,
            title: 'Editar Perfil',
            subtitle: 'Actualiza tu foto, nombre o correo',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VistaEditarPerfil(),
                ),
              );

              // 🔄 Cuando regresa de editar, el BlocBuilder se reconstruye automáticamente
            },
            showDivider: true,
          ),
          _buildMenuItem(
            icon: Icons.lock_outline,
            title: 'Cambiar Contraseña',
            subtitle: 'Administra la seguridad de tu cuenta',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VistaCambiarPassword(),
                ),
              );
            },
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Cerrar sesión',
            subtitle: 'Sal de la aplicación en este dispositivo',
            onTap: () => _cerrarSesion(context),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    Key? itemKey,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool showDivider,
    Color? titleColor,
    Color? iconColor,
  }) {
    return Column(
      children: [
        InkWell(
          key: itemKey,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, size: 24, color: iconColor ?? Colors.black),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: titleColor ?? Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, thickness: 1, color: Colors.grey[300], indent: 56),
      ],
    );
  }
}
