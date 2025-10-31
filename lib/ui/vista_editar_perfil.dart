import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loop_talk/components/snackbar_helper.dart';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class VistaEditarPerfil extends StatefulWidget {
  const VistaEditarPerfil({super.key});

  @override
  State<VistaEditarPerfil> createState() => _VistaEditarPerfilState();
}

class _VistaEditarPerfilState extends State<VistaEditarPerfil> {
  final TextEditingController _nombreController = TextEditingController(text: 'Miguel_Andres');
  final TextEditingController _emailController = TextEditingController(text: 'correoplaceholder@gmail.com');
  final ImagePicker _picker = ImagePicker();
  XFile? _imagenSeleccionada;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  
  Future<bool> _solicitarPermiso(ImageSource source) async {
    
    final permission = source == ImageSource.camera ? Permission.camera : Permission.photos;
    final sourceText = source == ImageSource.camera ? 'cámara' : 'galería';

    final status = await permission.request();

    if (!mounted) return false;

    if (status.isGranted) {
      return true;
    } 
    
    if (status.isDenied) {
      
        SnackBarHelper.showInfoMessage(context, 'Permiso denegado para acceder a la $sourceText.');
      
    }else if (status.isPermanentlyDenied) {
    SnackBarHelper.showActionMessage(
      context,
      'El permiso para la $sourceText está denegado permanentemente.',
      actionLabel: 'Ajustes',
      onActionPressed: () => openAppSettings(),
    );
  }

  return false;
}

  
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
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () async {
                  Navigator.of(context).pop();
                  
                  final bool tienePermiso = await _solicitarPermiso(ImageSource.gallery);
                  
                  if (tienePermiso) {
                    _abrirSelectorImagen(ImageSource.gallery);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () async {
                  Navigator.of(context).pop();
                  
                  final bool tienePermiso = await _solicitarPermiso(ImageSource.camera);
                  
                  if (tienePermiso) {
                    _abrirSelectorImagen(ImageSource.camera);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _guardarCambios() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cambios guardados exitosamente')),
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
        centerTitle: true,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'Editor Perfil',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.black, size: 28),
            onPressed: _guardarCambios,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: ClipOval(
                        child: _imagenSeleccionada != null
                            ? Image.file(
                                File(_imagenSeleccionada!.path),
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              )
                            : const Center(
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.black,
                                ),
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
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nombre Completo',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nombreController,
                    decoration: InputDecoration(
                      hintText: 'Ingresa tu nombre completo',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black, width: 1),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Ingresa tu email',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black, width: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

