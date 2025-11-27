import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/topico_bloc.dart';
import '../bloc/topico_event.dart';
import '../bloc/topico_state.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/categoria_bloc.dart';
import '../bloc/categoria_event.dart';
import '../bloc/categoria_state.dart';
import '../model/topico.dart';
import '../model/categoria.dart';
import '../services/firebase_likes_service.dart';
import 'vista_detalle_topico.dart';

class VistaInicio extends StatefulWidget {
  const VistaInicio({super.key});

  @override
  State<VistaInicio> createState() => _VistaInicioState();
}

class _VistaInicioState extends State<VistaInicio> {
  String? _selectedCategory;
  int? _selectedCategoryId;
  final FirebaseLikesService _likesService = FirebaseLikesService();
  String? _currentUserId;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isHeaderVisible = true;
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    // Configurar el estilo de la barra de estado para que sea blanca
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    
    // Obtener userId del AuthBloc
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      _currentUserId = authState.usuario.id.toString();
    }
    
    context.read<TopicoBloc>().add(LoadTopicos());
    context.read<CategoriaBloc>().add(LoadCategorias());
    
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      setState(() {}); // Actualizar cuando cambie el texto de búsqueda
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final shouldHide = _scrollController.offset > 50;
      
      if (shouldHide && _isHeaderVisible) {
        setState(() {
          _isHeaderVisible = false;
        });
      } else if (!shouldHide && !_isHeaderVisible) {
        setState(() {
          _isHeaderVisible = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Column(
        children: [
          // Header personalizado que se oculta al hacer scroll
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _isHeaderVisible ? kToolbarHeight + MediaQuery.of(context).padding.top : 0,
            color: Colors.white,
            child: _isHeaderVisible ? _buildHeader() : const SizedBox.shrink(),
          ),
          // Contenido
          Expanded(
            child: BlocBuilder<TopicoBloc, TopicoState>(
              builder: (context, state) {
                if (state is TopicoLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TopicoLoaded) {
                  final allTopicos = state.topicos;
                  
                  // Filtrar por categoría
                  var topicos = _selectedCategoryId != null
                      ? allTopicos.where((t) => t.curso?.id == _selectedCategoryId).toList()
                      : allTopicos;
                  
                  // Filtrar por búsqueda si está activa
                  if (_isSearchActive && _searchController.text.isNotEmpty) {
                    final searchQuery = _searchController.text.toLowerCase();
                    topicos = topicos.where((t) {
                      return t.titulo.toLowerCase().contains(searchQuery) ||
                             t.mensaje.toLowerCase().contains(searchQuery);
                    }).toList();
                  }
                  
                  // Inicializar posts en Firebase si no existen
                  for (var topico in topicos) {
                    if (topico.id != null) {
                      _likesService.initializePost(topico.id!);
                    }
                  }
                  
                  if (topicos.isEmpty) {
                    return _buildEmptyState();
                  }
                  
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<TopicoBloc>().add(LoadTopicos());
                    },
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        // Saludo y pregunta (oculto cuando se busca)
                        if (!_isSearchActive)
                          SliverToBoxAdapter(
                            child: _buildGreetingSection(),
                          ),
                        // Sección de filtros (oculta cuando se busca)
                        if (!_isSearchActive)
                          SliverToBoxAdapter(
                            child: _buildFilterSection(),
                          ),
                        // Lista de tópicos
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: _isSearchActive ? 20 : 0,
                          ),
                          sliver: topicos.isEmpty && _isSearchActive && _searchController.text.isNotEmpty
                              ? SliverToBoxAdapter(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(40.0),
                                      child: Column(
                                        children: [
                                          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No se encontraron resultados',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Intenta con otros términos de búsqueda',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 16),
                                        child: _buildTopicoCard(topicos[index]),
                                      );
                                    },
                                    childCount: topicos.length,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  );
                }

        if (state is TopicoError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<TopicoBloc>().add(LoadTopicos()),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: 12,
          ),
          child: _isSearchActive
              ? Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Buscar posts...',
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSearchActive = false;
                          _searchController.clear();
                        });
                      },
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    // Título "Home"
                    const Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    // Botón de búsqueda
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
                          Icons.search,
                          color: Colors.black87,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _isSearchActive = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String nombreUsuario = 'Usuario';
        if (authState is AuthSuccess) {
          final nombre = authState.usuario.nombre;
          if (nombre.isNotEmpty) {
            nombreUsuario = nombre.split(' ').first;
          }
        }
        
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, $nombreUsuario',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '¿Qué tema quieres explorar hoy?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterSection() {
    return BlocBuilder<CategoriaBloc, CategoriaState>(
      builder: (context, categoriaState) {
        List<Categoria> categorias = [];
        if (categoriaState is CategoriaLoaded) {
          categorias = categoriaState.categorias;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Text(
                'Para Ti',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildFilterChip(
                    'Últimos',
                    isSelected: _selectedCategory == null,
                    onTap: () {
                      setState(() {
                        _selectedCategory = null;
                        _selectedCategoryId = null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ...categorias.map((categoria) {
                    final isSelected = _selectedCategory == categoria.nombre;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildFilterChip(
                        categoria.nombre,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedCategory = categoria.nombre;
                            _selectedCategoryId = categoria.id;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(String label, {required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black87 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.black87 : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay tópicos disponibles',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            '¡Sé el primero en iniciar una conversación!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicoCard(Topico topico) {
    final autor = topico.autor;
    final username = autor != null
        ? '@${autor.nombre.replaceAll(' ', '_')}'
        : '@Usuario';
    final tiempoPublicacion = _formatTimeAgo(topico.fechaCreacion);
    final categoria = topico.curso?.nombre ?? 'General';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VistaDetalleTopico(topico: topico),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con avatar, username, tiempo y menú
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[200],
                      child: Icon(
                        Icons.person,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tiempoPublicacion,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
                      onPressed: () {
                        // Menú de opciones
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Título
                Text(
                  topico.titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                // Mensaje truncado
                Text(
                  topico.mensaje,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Línea separadora
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 12),
                // Métricas de engagement
                    Row(
                  children: [
                    _buildLikeButton(topico.id),
                    const SizedBox(width: 20),
                    _buildCommentAction(topico),
                    const Spacer(),
                    // Tag de categoría
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#$categoria',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLikeButton(int? topicoId) {
    if (topicoId == null || _currentUserId == null) {
      return StreamBuilder<int>(
        stream: _likesService.getLikesCount(0),
        builder: (context, snapshot) {
          final count = snapshot.data ?? 0;
          return _buildEngagementMetric(Icons.thumb_up_outlined, count.toString());
        },
      );
    }

    return StreamBuilder<int>(
      stream: _likesService.getLikesCount(topicoId),
      builder: (context, countSnapshot) {
        final likesCount = countSnapshot.data ?? 0;
        
        return FutureBuilder<bool>(
          future: _likesService.hasUserLiked(topicoId, _currentUserId!),
          builder: (context, likeSnapshot) {
            final isLiked = likeSnapshot.data ?? false;
            
            return InkWell(
              onTap: () {
                _likesService.likePost(topicoId, _currentUserId!);
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                      size: 18,
                      color: isLiked ? Colors.blueAccent : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      likesCount.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: isLiked ? Colors.blueAccent : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEngagementMetric(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          count,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCommentAction(Topico topico) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VistaDetalleTopico(topico: topico),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              'Comentar',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(String? fechaCreacion) {
    if (fechaCreacion == null) return 'Hace un momento';

    try {
      final fecha = DateTime.parse(fechaCreacion);
      final ahora = DateTime.now();
      final diferencia = ahora.difference(fecha);

      if (diferencia.inDays > 0) {
        return 'Hace ${diferencia.inDays}d';
      } else if (diferencia.inHours > 0) {
        return 'Hace ${diferencia.inHours}h';
      } else if (diferencia.inMinutes > 0) {
        return 'Hace ${diferencia.inMinutes}m';
      } else {
        return 'Hace un momento';
      }
    } catch (e) {
      return 'Hace un momento';
    }
  }

}

