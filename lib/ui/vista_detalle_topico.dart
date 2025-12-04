import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/topico.dart';
import '../model/comentario.dart';
import '../model/usuario.dart';
import '../services/firebase_likes_service.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/comentario_bloc.dart';
import '../bloc/comentario_event.dart';
import '../bloc/comentario_state.dart';
import '../bloc/topico_bloc.dart';
import '../bloc/topico_event.dart';
import '../bloc/topico_state.dart';
import '../repository/comentario_service.dart';
import '../utils/permission_utils.dart';
import 'create_topic_page.dart';
import '../components/snackbar_helper.dart';
import 'dart:developer';

class VistaDetalleTopico extends StatefulWidget {
  final Topico topico;

  const VistaDetalleTopico({
    super.key,
    required this.topico,
  });

  @override
  State<VistaDetalleTopico> createState() => _VistaDetalleTopicoState();
}

class _VistaDetalleTopicoState extends State<VistaDetalleTopico> {
  final TextEditingController _commentController = TextEditingController();
  final Map<int, bool> _likedComentarios = {};
  final Map<int, int> _likeCounts = {};
  // Comentarios serán gestionados por ComentarioBloc
  final FirebaseLikesService _likesService = FirebaseLikesService();
  String? _currentUserId;
  Usuario? _currentUser;
  late Topico _topicoActual;
  int? _pendingDeleteId;

  @override
  void initState() {
    super.initState();
    _topicoActual = widget.topico;
    
    // Obtener userId del AuthBloc
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      _currentUser = authState.usuario;
      _currentUserId = authState.usuario.id.toString();
    }
    
    // Inicializar post en Firebase
    if (_topicoActual.id != null) {
      _likesService.initializePost(_topicoActual.id!);
    }
    
    // Comentarios se cargarán mediante ComentarioBloc creado en build
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

  @override
  Widget build(BuildContext context) {
    final autor = _topicoActual.autor;
    final username = autor != null
        ? '@${autor.nombre.replaceAll(' ', '_')}'
        : '@Usuario';
    final tiempoPublicacion = _formatTimeAgo(_topicoActual.fechaCreacion);
    final categoria = _topicoActual.curso?.nombre ?? 'General';
    final canEdit = canEditTopico(currentUser: _currentUser, topico: _topicoActual);
    final canDelete = canDeleteTopico(currentUser: _currentUser, topico: _topicoActual);

    return BlocProvider(
      create: (_) => ComentarioBloc(ComentarioService())..add(LoadRespuestas(_topicoActual.id!)),
      child: MultiBlocListener(
        listeners: [
          BlocListener<ComentarioBloc, ComentarioState>(
            listener: (context, state) {
              if (state is ComentarioOperationSuccess) {
                SnackBarHelper.showSuccesssMessage(context, 'Comentario enviado');
                _commentController.clear();
                if (_topicoActual.id != null) {
                  context.read<ComentarioBloc>().add(LoadRespuestas(_topicoActual.id!));
                }
              } else if (state is ComentarioLoaded) {
                _commentController.clear();
              } else if (state is ComentarioError) {
                SnackBarHelper.showErrorMessage(context, 'Error: ${state.message}');
              }
            },
          ),
          BlocListener<TopicoBloc, TopicoState>(
            listener: (context, state) {
              if (state is TopicoActionSuccess) {
                SnackBarHelper.showSuccesssMessage(context, state.message);
                if (_pendingDeleteId != null && state.affectedTopicoId == _pendingDeleteId) {
                  _pendingDeleteId = null;
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                }
              } else if (state is TopicoActionFailure) {
                if (state.affectedTopicoId == _pendingDeleteId) {
                  _pendingDeleteId = null;
                }
                SnackBarHelper.showErrorMessage(context, state.message);
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Contenido scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Header del post con avatar, username, tiempo y botón X
                    Row(
                      children: [
                        // Avatar
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
                        // Username y fecha debajo
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                username,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Publicado $tiempoPublicacion',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Botones de acción
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (canEdit || canDelete)
                              IconButton(
                                icon: const Icon(Icons.more_vert, color: Colors.black87, size: 24),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _showTopicoActionSheet(
                                  canEdit: canEdit,
                                  canDelete: canDelete,
                                ),
                              ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.black87, size: 24),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Título del post
                    Text(
                      _topicoActual.titulo,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Tag de categoría
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 1),
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
                    const SizedBox(height: 16),
                    // Contenido del post
                    Text(
                      _topicoActual.mensaje,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Métricas de engagement - botón alargado con like/dislike y botón separado de comentarios
                    Row(
                      children: [
                        // Botón alargado con like (sin dislike)
                        _buildLikeDislikeButton(),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Sección de comentarios
                    const Text(
                      'Comentarios',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Lista de comentarios (cargadas desde API vía ComentarioBloc)
                    BlocBuilder<ComentarioBloc, ComentarioState>(
                      builder: (context, state) {
                        if (state is ComentarioLoading) {
                          return const Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else if (state is ComentarioLoaded) {
                          final respuestas = state.respuestas;
                          if (respuestas.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Center(
                                child: Text(
                                  'Sin comentarios, sé el primero en responder',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: respuestas.map((comentario) => _buildCommentCard(comentario)).toList(),
                          );
                        } else if (state is ComentarioError) {
                          return Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Center(
                              child: Text(
                                'Sin comentarios, sé el primero en responder',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          );
                        }

                        return const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
                    const SizedBox(height: 100), // Espacio para el input de comentarios
                  ],
                ),
              ),
            ),
            // Input de comentarios
            _buildCommentInput(),
          ],
        ),
      ),
    ),
  ),
);
  }

  Widget _buildLikeDislikeButton() {
    if (_topicoActual.id == null || _currentUserId == null) {
      return Container(); // No mostrar si no hay ID
    }

    return StreamBuilder<int>(
      stream: _likesService.getLikesCount(_topicoActual.id!),
      builder: (context, snapshot) {
        final likesCount = snapshot.data ?? 0;
        
        return FutureBuilder<bool>(
          future: _likesService.hasUserLiked(_topicoActual.id!, _currentUserId!),
          builder: (context, likeSnapshot) {
            final isLiked = likeSnapshot.data ?? false;
            return Container(
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[800]!, width: 1.5),
              ),
              child: InkWell(
                onTap: () {
                _likesService.likePost(_topicoActual.id!, _currentUserId!);
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                        size: 18,
                        color: isLiked ? Colors.blueAccent : Colors.grey[800],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        likesCount.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: isLiked ? Colors.blueAccent : Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // comments button removed — comments are displayed in the list and input is at the bottom

  Widget _buildCommentCard(Comentario comentario) {
    final autor = comentario.autor;
    final username = autor != null
        ? '@${autor.nombre.replaceAll(' ', '_')}'
        : '@Usuario';
    final tiempoPublicacion = _formatTimeAgo(comentario.fechaCreacion);
    final isLiked = comentario.id != null ? (_likedComentarios[comentario.id] ?? false) : false;
    final likeCount = comentario.id != null ? (_likeCounts[comentario.id] ?? 0) : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del comentario
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[200],
                child: Icon(
                  Icons.person,
                  color: Colors.grey[600],
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tiempoPublicacion,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Contenido del comentario
                    Text(
                      comentario.contenido,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Métricas de engagement del comentario
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: comentario.id != null
                      ? () {
                          setState(() {
                            final wasLiked = _likedComentarios[comentario.id] ?? false;
                            _likedComentarios[comentario.id!] = !wasLiked;

                            if (wasLiked) {
                              _likeCounts[comentario.id!] = (likeCount - 1);
                            } else {
                              _likeCounts[comentario.id!] = (likeCount + 1);
                            }
                          });
                    
                        }
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                          size: 16,
                          color: isLiked ? Colors.blueAccent : Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          likeCount.toString(),
                          style: TextStyle(
                            fontSize: 13,
                            color: isLiked ? Colors.blueAccent : Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    // Usar Builder para obtener un BuildContext que esté por debajo del BlocProvider
    return Builder(
      builder: (innerContext) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                // Botón de agregar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.black87, size: 20),
                    onPressed: () {
                      
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Campo de texto
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _commentController,
                      onSubmitted: (_) => _submitComment(innerContext),
                      decoration: InputDecoration(
                        hintText: 'Añade un comentario',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Botón de enviar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => _submitComment(innerContext),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitComment(BuildContext ctx) {
    final texto = _commentController.text.trim();
    if (texto.isEmpty || _topicoActual.id == null) return;

    final nueva = Comentario(
      id: null,
      contenido: texto,
      fechaCreacion: DateTime.now().toIso8601String(),
      autor: _topicoActual.autor,
      topicoId: _topicoActual.id,
    );

    // Usar el ComentarioBloc provisto en el árbol (creado en build)
    try {
      final bloc = ctx.read<ComentarioBloc>();
      bloc.add(CreateRespuesta(_topicoActual.id!, nueva));
    } catch (e, st) {
      // Mostrar mensaje visible para que el usuario sepa que falló
      // y registrar en la consola para depuración.
      log('Error al despachar CreateRespuesta: $e\n$st');
      SnackBarHelper.showErrorMessage(ctx, 'No se pudo enviar el comentario');
    }
  }

  void _showTopicoActionSheet({required bool canEdit, required bool canDelete}) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canEdit)
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Editar tópico'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _navigateToEditTopico();
                  },
                ),
              if (canDelete)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  title: const Text('Eliminar tópico'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _confirmTopicoDelete();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _navigateToEditTopico() async {
    final updated = await Navigator.push<Topico>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTopicPage(initialTopico: _topicoActual),
      ),
    );
    if (!mounted || updated == null) {
      return;
    }
    setState(() {
      _topicoActual = updated;
    });
  }

  Future<void> _confirmTopicoDelete() async {
    final topicoId = _topicoActual.id;
    if (topicoId == null) {
      SnackBarHelper.showErrorMessage(context, 'No se puede eliminar este tópico.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar tópico'),
          content: const Text('¿Estás seguro de que deseas eliminar este tópico?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }
    _pendingDeleteId = topicoId;
    context.read<TopicoBloc>().add(DeleteTopico(topicoId));
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
