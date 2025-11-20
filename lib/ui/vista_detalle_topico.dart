import 'package:flutter/material.dart';
import '../model/topico.dart';
import '../model/comentario.dart';

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
  final List<Comentario> _comentarios = [];
  bool _isLiked = false;
  int _likeCount = 360;

  @override
  void initState() {
    super.initState();
    // Inicializar likes del post
    _likeCount = 360;
    _isLiked = false;
    
    // TODO: Cargar comentarios desde la API
    // Por ahora, datos de ejemplo
    _loadExampleComments();
  }

  void _loadExampleComments() {
    // Datos de ejemplo - reemplazar con llamada a API
    setState(() {
      _comentarios.addAll([
        Comentario(
          id: 1,
          contenido: 'Te recomiendo "El fin de la infancia" de Arthur C. Clarke. Es corto, muy accesible y tiene un giro increíble sobre la humanidad. Ideal para empezar sin abrumarse.',
          fechaCreacion: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          autor: widget.topico.autor,
        ),
        Comentario(
          id: 2,
          contenido: 'Muchas Gracias!!! 😊',
          fechaCreacion: DateTime.now().subtract(const Duration(minutes: 2)).toIso8601String(),
          autor: widget.topico.autor,
        ),
      ]);
      
      // Inicializar contadores de likes
      for (var comentario in _comentarios) {
        if (comentario.id != null) {
          _likeCounts[comentario.id!] = 234;
          _likedComentarios[comentario.id!] = false;
        }
      }
    });
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
    final autor = widget.topico.autor;
    final username = autor != null
        ? '@${autor.nombre.replaceAll(' ', '_')}'
        : '@Usuario';
    final tiempoPublicacion = _formatTimeAgo(widget.topico.fechaCreacion);
    final categoria = widget.topico.curso?.nombre ?? 'General';

    return Scaffold(
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
                        // Username y tiempo
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                username,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '•',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Publicado $tiempoPublicacion',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Botón X
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
                    const SizedBox(height: 16),
                    // Título del post
                    Text(
                      widget.topico.titulo,
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
                      widget.topico.mensaje,
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
                        // Botón alargado con like y dislike
                        _buildLikeDislikeButton(),
                        const Spacer(),
                        // Botón de comentarios a la derecha
                        _buildCommentsButton(),
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
                    // Lista de comentarios
                    if (_comentarios.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Center(
                          child: Text(
                            'No hay comentarios aún',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      )
                    else
                      ..._comentarios.map((comentario) => _buildCommentCard(comentario)),
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
    );
  }

  Widget _buildLikeDislikeButton() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[800]!, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sección de like
          InkWell(
            onTap: () {
              setState(() {
                _isLiked = !_isLiked;
                if (_isLiked) {
                  _likeCount++;
                } else {
                  _likeCount--;
                }
              });
              // TODO: Llamar a la API cuando esté lista
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    size: 18,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _likeCount.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Separador vertical
          Container(
            width: 1,
            height: 20,
            color: Colors.grey[300],
          ),
          // Sección de dislike
          InkWell(
            onTap: () {
              // TODO: Implementar dislike
            },
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Icon(
                Icons.thumb_down_outlined,
                size: 18,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsButton() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[800]!, width: 1.5),
      ),
      child: InkWell(
        onTap: () {
          // Scroll a comentarios o focus en input
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 18,
                color: Colors.grey[800],
              ),
              const SizedBox(width: 6),
              Text(
                _comentarios.length.toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                    Row(
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '•',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tiempoPublicacion,
                          style: TextStyle(
                            fontSize: 16,
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
                          // TODO: Llamar a la API cuando esté lista
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
                const SizedBox(width: 16),
                Icon(Icons.thumb_down_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  '12',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
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
                  // TODO: Implementar funcionalidad de agregar media
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
                onPressed: () {
                  if (_commentController.text.trim().isNotEmpty) {
                    // TODO: Enviar comentario a la API
                    setState(() {
                      _comentarios.add(
                        Comentario(
                          id: _comentarios.length + 1,
                          contenido: _commentController.text.trim(),
                          fechaCreacion: DateTime.now().toIso8601String(),
                          autor: widget.topico.autor,
                        ),
                      );
                      _likeCounts[_comentarios.length] = 0;
                      _likedComentarios[_comentarios.length] = false;
                      _commentController.clear();
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
