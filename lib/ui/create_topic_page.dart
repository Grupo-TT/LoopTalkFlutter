import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loop_talk/bloc/auth_bloc.dart';
import 'package:loop_talk/bloc/auth_state.dart';
import 'package:loop_talk/bloc/categoria_bloc.dart';
import 'package:loop_talk/bloc/categoria_event.dart';
import 'package:loop_talk/bloc/categoria_state.dart';
import 'package:loop_talk/bloc/create_topic_bloc.dart';
import 'package:loop_talk/model/categoria.dart';
import 'package:loop_talk/bloc/topico_bloc.dart';
import 'package:loop_talk/bloc/topico_event.dart';

class CreateTopicPage extends StatelessWidget {
  const CreateTopicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<CreateTopicBloc, CreateTopicState>(
        listener: (context, state) {
          if (state is CreateTopicSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tópico creado con éxito')),
            );
            context.read<TopicoBloc>().add(LoadTopicos());
            Navigator.of(context).pop();
          } else if (state is CreateTopicFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.error}')),
            );
          }
        },
        child: const CreateTopicForm(),
      ),
    );
  }
}

class CreateTopicForm extends StatefulWidget {
  const CreateTopicForm({super.key});

  @override
  State<CreateTopicForm> createState() => _CreateTopicFormState();
}

class _CreateTopicFormState extends State<CreateTopicForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _categorySearchController = TextEditingController();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySub;
  bool _isOffline = false;
  Categoria? _selectedCategoria;
  List<Categoria> _filteredCategorias = [];
  List<Categoria> _allCategorias = [];

  @override
  void initState() {
    super.initState();
    context.read<CategoriaBloc>().add(LoadCategorias());
    _categorySearchController.addListener(_filterCategorias);
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateOfflineStatus(result);
    _connectivitySub = _connectivity.onConnectivityChanged.listen(_updateOfflineStatus);
  }

  void _updateOfflineStatus(ConnectivityResult result) {
    final isOffline = result == ConnectivityResult.none;
    if (!mounted || _isOffline == isOffline) {
      return;
    }
    setState(() {
      _isOffline = isOffline;
    });
  }

  void _filterCategorias() {
    final query = _categorySearchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCategorias = _allCategorias;
      } else {
        _filteredCategorias = _allCategorias
            .where((c) => c.nombre.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('videojuego') || name.contains('juego')) {
      return Icons.sports_esports;
    } else if (name.contains('música') || name.contains('musica')) {
      return Icons.music_note;
    } else if (name.contains('cine') || name.contains('película')) {
      return Icons.movie;
    } else if (name.contains('literatura') || name.contains('libro')) {
      return Icons.menu_book;
    } else if (name.contains('arte')) {
      return Icons.palette;
    } else if (name.contains('tecnología') || name.contains('tecnologia')) {
      return Icons.computer;
    } else if (name.contains('deporte')) {
      return Icons.sports_soccer;
    } else if (name.contains('idea')) {
      return Icons.lightbulb;
    }
    return Icons.category;
  }

  Color _getCategoryIconColor(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('música') || name.contains('musica')) {
      return Colors.black;
    } else if (name.contains('cine') || name.contains('película')) {
      return Colors.purple;
    } else if (name.contains('literatura') || name.contains('libro')) {
      return Colors.lightBlue;
    } else if (name.contains('arte')) {
      return Colors.pink;
    } else if (name.contains('tecnología') || name.contains('tecnologia')) {
      return Colors.lightBlue;
    } else if (name.contains('deporte')) {
      return Colors.blue;
    } else if (name.contains('idea')) {
      return Colors.amber;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          ColoredBox(
            color: Colors.white,
            child: Column(
              children: [
                // Header con usuario
                _buildUserHeader(),
                // Contenido scrollable
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          // Campo de título
                          _buildTitleField(),
                          const SizedBox(height: 16),
                          // Campo de descripción
                          _buildDescriptionField(),
                          const SizedBox(height: 32),
                          // Sección de categorías
                          _buildCategorySection(),
                          const SizedBox(height: 100), // Espacio para los botones inferiores
                        ],
                      ),
                    ),
                  ),
                ),
                // Botones inferiores
                _buildBottomActions(),
              ],
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !_isOffline,
              child: AnimatedOpacity(
                opacity: _isOffline ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                  ),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children:  [
                          Icon(
                            Icons.wifi_off_rounded,
                            size: 48,
                            color: Colors.black87,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Sin conexión',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Reintentando...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 24),
                           CircularProgressIndicator(
                            strokeWidth: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String username = 'Usuario';
        if (authState is AuthSuccess) {
          final nombre = authState.usuario.nombre;
          if (nombre.isNotEmpty) {
            username = nombre.split(' ').first;
          }
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              // Botón de cancelar
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black87),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(width: 8),
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: Colors.grey[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Username
              Text(
                '@$username',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTitleField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: _titleController,
        decoration: InputDecoration(
          hintText: 'Que tienes en mente?',
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingresa un título';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: _messageController,
        decoration: InputDecoration(
          hintText: 'Descripción',
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.all(16),
        ),
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingresa una descripción';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCategorySection() {
    return BlocBuilder<CategoriaBloc, CategoriaState>(
      builder: (context, categoriaState) {
        if (categoriaState is CategoriaLoaded) {
          if (_allCategorias.isEmpty || _allCategorias.length != categoriaState.categorias.length) {
            _allCategorias = categoriaState.categorias;
            _filteredCategorias = categoriaState.categorias;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de sección
            const Text(
              'Selecciona la Categoría',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            // Barra de búsqueda
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _categorySearchController,
                decoration: InputDecoration(
                  hintText: 'Buscar categoria...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Lista horizontal de categorías
            SizedBox(
              height: 50,
              child: _filteredCategorias.isEmpty
                  ? Center(
                      child: Text(
                        'No se encontraron categorías',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filteredCategorias.length,
                      itemBuilder: (context, index) {
                        final categoria = _filteredCategorias[index];
                        final isSelected = _selectedCategoria?.id == categoria.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _buildCategoryChip(categoria, isSelected),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryChip(Categoria categoria, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoria = categoria;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.grey[800]! : Colors.black,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getCategoryIcon(categoria.nombre),
              size: 20,
              color: isSelected
                  ? Colors.white
                  : _getCategoryIconColor(categoria.nombre),
            ),
            const SizedBox(width: 8),
            Text(
              categoria.nombre,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.check,
                size: 18,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Botón de agregar media
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: IconButton(
                icon: const Icon(Icons.add_photo_alternate, color: Colors.black87),
                onPressed: () {
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funcionalidad de imagen próximamente')),
                  );
                },
              ),
            ),
            const Spacer(),
            // Botón de publicar
            BlocBuilder<CreateTopicBloc, CreateTopicState>(
              builder: (context, state) {
                final isLoading = state is CreateTopicInProgress;
                return SizedBox(
                  width: 120,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              if (_selectedCategoria == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Por favor selecciona una categoría'),
                                  ),
                                );
                                return;
                              }
                              context.read<CreateTopicBloc>().add(
                                    CreateTopicSubmitted(
                                      titulo: _titleController.text,
                                      mensaje: _messageController.text,
                                      idCurso: _selectedCategoria!.id!,
                                    ),
                                  );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Publicar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _titleController.dispose();
    _messageController.dispose();
    _categorySearchController.dispose();
    super.dispose();
  }
}
