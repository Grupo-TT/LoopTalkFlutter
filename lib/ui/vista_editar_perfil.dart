import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:loop_talk/components/snackbar_helper.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'package:loop_talk/services/firebase_storage_service.dart';
import 'package:loop_talk/services/firebase_profile_service.dart';

class VistaEditarPerfil extends StatefulWidget {
  const VistaEditarPerfil({super.key});

  @override
  State<VistaEditarPerfil> createState() => _VistaEditarPerfilState();
}

class _VistaEditarPerfilState extends State<VistaEditarPerfil> {
  late TextEditingController _nombreController;
  late TextEditingController _correoController;

  final ImagePicker _picker = ImagePicker();
  XFile? _imagenSeleccionada;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();

    final state = context.read<AuthBloc>().state;

    if (state is AuthSuccess) {
      _nombreController = TextEditingController(text: state.usuario.nombre);
      _correoController = TextEditingController(
        text: state.usuario.correoElectronico,
      );
    } else {
      _nombreController = TextEditingController();
      _correoController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────
  //   PERMISOS
  // ────────────────────────────────────────────────
  Future<bool> _solicitarPermiso(ImageSource source) async {
    final permission = source == ImageSource.camera
        ? Permission.camera
        : Permission.photos;
    final sourceText = source == ImageSource.camera ? 'cámara' : 'galería';

    final status = await permission.request();

    if (!mounted) return false;

    if (status.isGranted) return true;

    if (status.isDenied) {
      SnackBarHelper.showInfoMessage(
        context,
        'Permiso denegado para acceder a la $sourceText.',
      );
    } else if (status.isPermanentlyDenied) {
      SnackBarHelper.showActionMessage(
        context,
        'El permiso para la $sourceText está denegado permanentemente.',
        actionLabel: 'Ajustes',
        onActionPressed: () => openAppSettings(),
      );
    }

    return false;
  }

  // ────────────────────────────────────────────────
  //   SELECTOR DE IMAGEN
  // ────────────────────────────────────────────────
  Future<void> _abrirSelectorImagen(ImageSource source) async {
    final XFile? imagen = await _picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (imagen != null) {
      setState(() {
        _imagenSeleccionada = imagen;
      });
    }
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () async {
                Navigator.pop(context);

                if (await _solicitarPermiso(ImageSource.gallery)) {
                  await _abrirSelectorImagen(ImageSource.gallery);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () async {
                Navigator.pop(context);

                if (await _solicitarPermiso(ImageSource.camera)) {
                  await _abrirSelectorImagen(ImageSource.camera);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  //   GUARDAR CAMBIOS – BLO C
  // ────────────────────────────────────────────────
  // ────────────────────────────────────────────────
  //   GUARDAR CAMBIOS – BLO C
  // ────────────────────────────────────────────────
  Future<void> _guardarCambios() async {
    if (_isUploading) return;

    final nombre = _nombreController.text.trim();
    final correo = _correoController.text.trim();

    if (nombre.isEmpty || correo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor completa todos los campos")),
      );
      return;
    }

    if (!correo.contains('@')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Correo inválido")));
      return;
    }

    String? fotoUrl;
    final authState = context.read<AuthBloc>().state;
    final userId = (authState is AuthSuccess) ? authState.usuario.id : null;

    if (_imagenSeleccionada != null) {
      setState(() {
        _isUploading = true;
      });
      try {
        final storageService = FirebaseStorageService();
        final fileName =
            'profile_images/${DateTime.now().millisecondsSinceEpoch}_${_imagenSeleccionada!.name}';
        fotoUrl = await storageService.uploadImage(
          File(_imagenSeleccionada!.path),
          fileName,
        );

        // Save photo URL to Firestore so other users can see it
        if (userId != null) {
          final profileService = FirebaseProfileService();
          await profileService.saveProfilePhoto(userId, fotoUrl);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error al subir imagen: $e")));
        }
        return;
      }
    }

    if (mounted) {
      context.read<AuthBloc>().add(
        UpdateProfileEvent(
          nombre: nombre,
          correoElectronico: correo,
          fotoUrl: fotoUrl,
        ),
      );
      // Reset uploading state as Bloc will handle loading now
      setState(() {
        _isUploading = false;
      });
    }
  }

  // ────────────────────────────────────────────────
  //   CONFIRMAR SALIR
  // ────────────────────────────────────────────────
  Future<void> _confirmarSalir() async {
    final salir = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Descartar cambios'),
        content: const Text('¿Deseas salir sin guardar los cambios?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (salir == true) Navigator.pop(context);
  }

  // ────────────────────────────────────────────────
  //   UI
  // ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          SnackBarHelper.showInfoMessage(
            context,
            "Cambios guardados exitosamente",
          );
          Navigator.pop(context);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.deepPurple,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: _confirmarSalir,
            ),
            title: const Text(
              'Editar perfil',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              if (isLoading || _isUploading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.white),
                  onPressed: _guardarCambios,
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 20),

              // FOTO DE PERFIL
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: ClipOval(
                        child: _imagenSeleccionada != null
                            ? Image.file(
                                File(_imagenSeleccionada!.path),
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.black,
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _mostrarOpcionesImagen,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // NOMBRE
              TextField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // CORREO
              TextField(
                controller: _correoController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(color: Colors.black),
                ),
            ],
          ),
        );
      },
    );
  }
}
