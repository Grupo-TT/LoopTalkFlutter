import 'package:flutter/material.dart';

class VistaCambiarPassword extends StatefulWidget {
  const VistaCambiarPassword({super.key});

  @override
  State<VistaCambiarPassword> createState() => _VistaCambiarPasswordState();
}

class _VistaCambiarPasswordState extends State<VistaCambiarPassword> {
  final TextEditingController _passwordActualController = TextEditingController();
  final TextEditingController _nuevaPasswordController = TextEditingController();
  final TextEditingController _confirmarPasswordController = TextEditingController();
  
  bool _obscurePasswordActual = true;
  bool _obscureNuevaPassword = true;
  bool _obscureConfirmarPassword = true;

  // Validaciones en tiempo real
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
      // Al menos 8 caracteres
      _tieneMinimoCaracteres = nuevaPassword.length >= 8;
      
      // Incluir mayúsculas y números
      _tieneMayusculasYNumeros = nuevaPassword.contains(RegExp(r'[A-Z]')) &&
                                  nuevaPassword.contains(RegExp(r'[0-9]'));
      
      // Ser diferente a la anterior
      _esDiferente = nuevaPassword.isNotEmpty && 
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
          content: Text('Por favor, completa todos los requisitos de la contraseña'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Implementar llamada a la API
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            const Text(
              'Cambiar Contraseña',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            // Subtítulo
            Text(
              'Ingresa tu contraseña actual y crea una nueva para tu cuenta.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            // Campo Contraseña Actual
            _buildPasswordField(
              controller: _passwordActualController,
              label: 'Contraseña Actual',
              obscureText: _obscurePasswordActual,
              onToggleVisibility: () {
                setState(() {
                  _obscurePasswordActual = !_obscurePasswordActual;
                });
              },
            ),
            const SizedBox(height: 24),
            // Campo Nueva Contraseña
            _buildPasswordField(
              controller: _nuevaPasswordController,
              label: 'Nueva Contraseña',
              obscureText: _obscureNuevaPassword,
              onToggleVisibility: () {
                setState(() {
                  _obscureNuevaPassword = !_obscureNuevaPassword;
                });
              },
            ),
            const SizedBox(height: 16),
            // Requisitos de contraseña
            _buildPasswordRequirements(),
            const SizedBox(height: 24),
            // Campo Confirmar Contraseña
            _buildPasswordField(
              controller: _confirmarPasswordController,
              label: 'Confirmar contraseña',
              obscureText: _obscureConfirmarPassword,
              onToggleVisibility: () {
                setState(() {
                  _obscureConfirmarPassword = !_obscureConfirmarPassword;
                });
              },
            ),
            const SizedBox(height: 40),
            // Botón Actualizar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _esFormularioValido() ? _actualizarPassword : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Actualizar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
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
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black87, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.grey[600],
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
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu contraseña debe:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
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
          _buildRequirement(
            'Ser diferente a la anterior',
            _esDiferente,
          ),
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
}

