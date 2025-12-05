import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import 'package:loop_talk/theme/app_theme.dart';

class VistaCambiarPassword extends StatefulWidget {
  const VistaCambiarPassword({super.key});

  @override
  State<VistaCambiarPassword> createState() => _VistaCambiarPasswordState();
}

class _VistaCambiarPasswordState extends State<VistaCambiarPassword> {
  final TextEditingController _passwordActualController =
      TextEditingController();
  final TextEditingController _nuevaPasswordController =
      TextEditingController();
  final TextEditingController _confirmarPasswordController =
      TextEditingController();

  bool _obscurePasswordActual = true;
  bool _obscureNuevaPassword = true;
  bool _obscureConfirmarPassword = true;

  bool _tieneMinimoCaracteres = false;
  bool _tieneMayusculasYNumeros = false;
  bool _esDiferente = false;

  @override
  void initState() {
    super.initState();
    _nuevaPasswordController.addListener(_validarPassword);
    _passwordActualController.addListener(_validarPassword);
  }

  @override
  void dispose() {
    _passwordActualController.dispose();
    _nuevaPasswordController.dispose();
    _confirmarPasswordController.dispose();
    _nuevaPasswordController.removeListener(_validarPassword);
    _passwordActualController.removeListener(_validarPassword);
    super.dispose();
  }

  void _validarPassword() {
    final nuevaPassword = _nuevaPasswordController.text;
    final passwordActual = _passwordActualController.text;

    setState(() {
      _tieneMinimoCaracteres = nuevaPassword.length >= 8;

      _tieneMayusculasYNumeros =
          nuevaPassword.contains(RegExp(r'[A-Z]')) &&
          nuevaPassword.contains(RegExp(r'[0-9]'));

      _esDiferente =
          nuevaPassword.isNotEmpty &&
          passwordActual.isNotEmpty &&
          nuevaPassword != passwordActual;
    });
  }

  bool _esFormularioValido() {
    return _tieneMinimoCaracteres &&
        _tieneMayusculasYNumeros &&
        _esDiferente &&
        _confirmarPasswordController.text == _nuevaPasswordController.text &&
        _nuevaPasswordController.text.isNotEmpty;
  }

  void _actualizarPassword() {
    if (!_esFormularioValido()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, completa todos los requisitos de la contraseña',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
      UpdatePasswordEvent(
        nuevaContrasenia: _nuevaPasswordController.text.trim(),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contraseña actualizada correctamente'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          } else if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Contraseña actualizada correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return _buildForm();
        },
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.accentGreen,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textSecondary,
              ),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tu contraseña debe:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          _buildRequirement(
            'Tener al menos 8 caracteres',
            _tieneMinimoCaracteres,
          ),
          const SizedBox(height: 8),
          _buildRequirement(
            'Incluir mayúsculas y números',
            _tieneMayusculasYNumeros,
          ),
          const SizedBox(height: 8),
          _buildRequirement('Ser diferente a la anterior', _esDiferente),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          size: 20,
          color: isValid ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isValid ? Colors.green[700] : Colors.red[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cambiar Contraseña',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ingresa tu contraseña actual y crea una nueva para tu cuenta.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),

          _buildPasswordField(
            controller: _passwordActualController,
            label: 'Contraseña Actual',
            obscureText: _obscurePasswordActual,
            onToggleVisibility: () {
              setState(() => _obscurePasswordActual = !_obscurePasswordActual);
            },
          ),

          const SizedBox(height: 24),

          _buildPasswordField(
            controller: _nuevaPasswordController,
            label: 'Nueva Contraseña',
            obscureText: _obscureNuevaPassword,
            onToggleVisibility: () {
              setState(() => _obscureNuevaPassword = !_obscureNuevaPassword);
            },
          ),

          const SizedBox(height: 16),

          _buildPasswordRequirements(),

          const SizedBox(height: 24),

          _buildPasswordField(
            controller: _confirmarPasswordController,
            label: 'Confirmar contraseña',
            obscureText: _obscureConfirmarPassword,
            onToggleVisibility: () {
              setState(
                () => _obscureConfirmarPassword = !_obscureConfirmarPassword,
              );
            },
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _esFormularioValido() ? _actualizarPassword : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                disabledBackgroundColor: AppColors.surfaceBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Actualizar',
                style: TextStyle(
                  color: AppColors.scaffoldBg,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
