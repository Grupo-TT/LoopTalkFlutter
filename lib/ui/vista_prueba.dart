import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/topico_bloc.dart';
import '../bloc/topico_event.dart';
import '../bloc/topico_state.dart';
import '../model/topico.dart';
import '../model/comentario.dart';
import '../services/firebase_likes_service.dart';
import '../repository/comentario_service.dart';

class VistaPrueba extends StatefulWidget {
  const VistaPrueba({super.key});

  @override
  State<VistaPrueba> createState() => _VistaPruebaState();
}

class _VistaPruebaState extends State<VistaPrueba> {
  @override
  void initState() {
    super.initState();
    // Cargar los tópicos cuando se abre la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TopicoBloc>().add(LoadTopicos());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocListener<TopicoBloc, TopicoState>(
          listener: (context, state) {
            // Forzar rebuild cuando cambian los tópicos
            if (state is TopicoLoaded || state is TopicoActionSuccess) {
              setState(() {});
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthSuccess) {
                final usuario = state.usuario;
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<TopicoBloc>().add(LoadTopicos());
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estadísticas',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildStatsSection(context, usuario.id),
                        const SizedBox(height: 32),
                        _buildSectionTitle('Actividad'),
                        const SizedBox(height: 12),
                        _buildTimelineSection(context, usuario.id),
                        const SizedBox(height: 32),
                        _buildSectionTitle('Escritura'),
                        const SizedBox(height: 12),
                        _buildWordsSection(context, usuario.id),
                        const SizedBox(height: 32),
                        _buildSectionTitle('Categorías'),
                        const SizedBox(height: 12),
                        _buildCategoryDistributionSection(context, usuario.id),
                        const SizedBox(height: 32),
                        _buildSectionTitle('Engagement'),
                        const SizedBox(height: 12),
                        _buildEngagementSection(context, usuario.id),
                        const SizedBox(height: 32),
                        _buildSectionTitle('Actividad reciente'),
                        const SizedBox(height: 12),
                        _buildRecentActivitySection(context, usuario.id),
                      ],
                    ),
                  ),
                );
              } else {
                return const Center(
                  child: Text('No hay usuario autenticado'),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, int userId) {
    return BlocBuilder<TopicoBloc, TopicoState>(
      builder: (context, state) {
        var value = '--';

        if (state is TopicoLoaded) {
          final userTopicos = state.topicos.where((t) => t.autor?.id == userId).length;
          value = userTopicos.toString();
        } else if (state is TopicoLoading || state is TopicoActionInProgress) {
          value = '...';
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: _buildStatCard(
              icon: Icons.chat_bubble_outline,
              value: value,
              label: 'Loops Creados',
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.black),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
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

  Widget _buildTimelineSection(BuildContext context, int userId) {
    return BlocBuilder<TopicoBloc, TopicoState>(
      builder: (context, state) {
        if (state is! TopicoLoaded) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final userTopicos = state.topicos
            .where((t) => t.autor?.id == userId && t.fechaCreacion != null)
            .toList();

        if (userTopicos.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Aún no has creado loops. Comparte tu primera idea para ver aquí tu actividad.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final timelineEntries = _buildMonthlyTimeline(userTopicos);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Loops por mes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              ...timelineEntries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.period,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${entry.count}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<_TimelineEntry> _buildMonthlyTimeline(List<Topico> topicos) {
    final Map<String, int> counts = {};
    
    for (final topico in topicos) {
      final fecha = topico.fechaCreacion;
      if (fecha == null) continue;
      
      final date = DateTime.tryParse(fecha);
      if (date == null) continue;
      
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      counts[key] = (counts[key] ?? 0) + 1;
    }

    final sortedKeys = counts.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    
    final latest = sortedKeys.take(6).toList();

    return latest.map((key) {
      final parts = key.split('-');
      final year = parts[0];
      final month = int.parse(parts[1]);
      final period = '${_monthName(month)} $year';
      return _TimelineEntry(period: period, count: counts[key] ?? 0);
    }).toList();
  }

  String _monthName(int month) {
    const names = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    if (month < 1 || month > 12) return '';
    return names[month - 1];
  }

  Widget _buildWordsSection(BuildContext context, int userId) {
    return BlocBuilder<TopicoBloc, TopicoState>(
      builder: (context, state) {
        if (state is! TopicoLoaded) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final userTopicos = state.topicos
            .where((t) => t.autor?.id == userId)
            .toList();

        if (userTopicos.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Aún no has creado loops para calcular estadísticas de escritura.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final wordsStats = _calculateWordsStats(userTopicos);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Estadísticas de escritura',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildWordsStatRow(
                label: 'Total de palabras',
                value: '${wordsStats.totalWords}',
                icon: Icons.text_fields,
              ),
              const SizedBox(height: 12),
              _buildWordsStatRow(
                label: 'Promedio por loop',
                value: '${wordsStats.averageWords}',
                icon: Icons.bar_chart,
              ),
              const SizedBox(height: 12),
              _buildWordsStatRow(
                label: 'Loop más largo',
                value: '${wordsStats.maxWords} palabras',
                icon: Icons.trending_up,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWordsStatRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black87),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  _WordsStats _calculateWordsStats(List<Topico> topicos) {
    int totalWords = 0;
    int maxWords = 0;

    for (final topico in topicos) {
      final wordsInTitle = _countWords(topico.titulo);
      final wordsInMessage = _countWords(topico.mensaje);
      final totalWordsInTopico = wordsInTitle + wordsInMessage;
      
      totalWords += totalWordsInTopico;
      if (totalWordsInTopico > maxWords) {
        maxWords = totalWordsInTopico;
      }
    }

    final averageWords = topicos.isEmpty ? 0 : (totalWords / topicos.length).round();

    return _WordsStats(
      totalWords: totalWords,
      averageWords: averageWords,
      maxWords: maxWords,
    );
  }

  int _countWords(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  Widget _buildCategoryDistributionSection(BuildContext context, int userId) {
    return BlocBuilder<TopicoBloc, TopicoState>(
      builder: (context, state) {
        if (state is! TopicoLoaded) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final userTopicos = state.topicos
            .where((t) => t.autor?.id == userId)
            .toList();

        if (userTopicos.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Aún no has creado loops para ver la distribución por categorías.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final categoryStats = _calculateCategoryDistribution(userTopicos);

        if (categoryStats.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Tus loops no tienen categorías asignadas.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Loops por categoría',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categoryStats.map(
                  (stat) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          stat.categoryName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${stat.count}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  List<_CategoryStat> _calculateCategoryDistribution(List<Topico> topicos) {
    final Map<String, int> counts = {};
    int totalWithCategory = 0;

    for (final topico in topicos) {
      if (topico.curso != null && topico.curso!.nombre.isNotEmpty) {
        final categoryName = topico.curso!.nombre;
        counts[categoryName] = (counts[categoryName] ?? 0) + 1;
        totalWithCategory++;
      }
    }

    if (counts.isEmpty) return [];

    final sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.map((entry) {
      final percentage = totalWithCategory > 0
          ? ((entry.value / totalWithCategory) * 100).round()
          : 0;
      return _CategoryStat(
        categoryName: entry.key,
        count: entry.value,
        percentage: percentage,
      );
    }).toList();
  }

  Widget _buildEngagementSection(BuildContext context, int userId) {
    return BlocBuilder<TopicoBloc, TopicoState>(
      builder: (context, state) {
        if (state is! TopicoLoaded) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final userTopicos = state.topicos
            .where((t) => t.autor?.id == userId && t.id != null)
            .toList();

        if (userTopicos.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Aún no has creado loops para calcular engagement.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return FutureBuilder<_EngagementStats>(
          key: ValueKey('engagement_${userTopicos.length}_${userTopicos.map((t) => t.id).join(',')}'),
          future: _calculateEngagementStats(userTopicos),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }

            if (snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Error al cargar engagement: ${snapshot.error}',
                    style: const TextStyle(fontSize: 13, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final stats = snapshot.data ?? _EngagementStats(likes: 0, comments: 0);

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Interacción recibida',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildEngagementRow(
                    icon: Icons.thumb_up_outlined,
                    label: 'Likes recibidos',
                    value: '${stats.likes}',
                  ),
                  const SizedBox(height: 12),
                  _buildEngagementRow(
                    icon: Icons.chat_bubble_outline,
                    label: 'Comentarios recibidos',
                    value: '${stats.comments}',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEngagementRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black87),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Future<_EngagementStats> _calculateEngagementStats(List<Topico> topicos) async {
    final likesService = FirebaseLikesService();
    final comentarioService = ComentarioService();
    
    int totalLikes = 0;
    int totalComments = 0;

    for (final topico in topicos) {
      if (topico.id == null) continue;

      // Obtener likes (usar el valor actual del stream)
      try {
        final likesStream = likesService.getLikesCount(topico.id!);
        final likesSnapshot = await likesStream.first.timeout(
          const Duration(seconds: 5),
          onTimeout: () => 0,
        );
        totalLikes += likesSnapshot;
      } catch (e) {
        // Si hay error, continuar con el siguiente
      }

      // Obtener comentarios
      try {
        final comentarios = await comentarioService.obtenerRespuestas(topico.id!).timeout(
          const Duration(seconds: 5),
          onTimeout: () => <Comentario>[],
        );
        totalComments += comentarios.length;
      } catch (e) {
        // Si hay error, continuar con el siguiente
      }
    }

    return _EngagementStats(likes: totalLikes, comments: totalComments);
  }

  Widget _buildRecentActivitySection(BuildContext context, int userId) {
    return BlocBuilder<TopicoBloc, TopicoState>(
      builder: (context, state) {
        if (state is! TopicoLoaded) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final userTopicos = state.topicos
            .where((t) => t.autor?.id == userId && t.fechaCreacion != null)
            .toList();

        if (userTopicos.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Aún no has creado loops para ver tu actividad reciente.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return FutureBuilder<_RecentActivityInfo>(
          future: _calculateRecentActivity(userTopicos, userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }

            final activityInfo = snapshot.data ?? _RecentActivityInfo(
              loopsThisWeek: 0,
              lastLoopDays: 0,
              lastLoopDate: null,
            );

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen de actividad',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (activityInfo.loopsThisWeek > 0)
                    _buildActivityRow(
                      icon: Icons.calendar_today,
                      text: 'Has creado ${activityInfo.loopsThisWeek} loop${activityInfo.loopsThisWeek == 1 ? '' : 's'} esta semana',
                    ),
                  if (activityInfo.loopsThisWeek > 0) const SizedBox(height: 12),
                  _buildActivityRow(
                    icon: Icons.access_time,
                    text: _buildLastLoopText(activityInfo.lastLoopDays, activityInfo.lastLoopDate),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActivityRow({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black87),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  String _buildLastLoopText(int days, DateTime? lastDate) {
    if (lastDate == null) {
      return 'Sin actividad registrada';
    }

    if (days == 0) {
      return 'Último loop publicado hoy';
    } else if (days == 1) {
      return 'Último loop publicado hace 1 día';
    } else if (days < 7) {
      return 'Último loop publicado hace $days días';
    } else if (days < 30) {
      final weeks = (days / 7).floor();
      return 'Último loop publicado hace $weeks ${weeks == 1 ? 'semana' : 'semanas'}';
    } else if (days < 365) {
      final months = (days / 30).floor();
      return 'Último loop publicado hace $months ${months == 1 ? 'mes' : 'meses'}';
    } else {
      final years = (days / 365).floor();
      return 'Último loop publicado hace $years ${years == 1 ? 'año' : 'años'}';
    }
  }

  Future<_RecentActivityInfo> _calculateRecentActivity(List<Topico> topicos, int userId) async {
    // Guardar la fecha de última visita
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString('last_visit_$userId', now.toIso8601String());

    // Obtener fechas de creación y ordenarlas
    final dates = topicos
        .map((t) => t.fechaCreacion)
        .whereType<String>()
        .map((fecha) => DateTime.tryParse(fecha))
        .whereType<DateTime>()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (dates.isEmpty) {
      return _RecentActivityInfo(
        loopsThisWeek: 0,
        lastLoopDays: 0,
        lastLoopDate: null,
      );
    }

    final lastLoopDate = dates.first;
    final lastLoopDays = now.difference(lastLoopDate).inDays;

    // Calcular loops esta semana
    final weekAgo = now.subtract(const Duration(days: 7));
    final loopsThisWeek = dates.where((date) => date.isAfter(weekAgo)).length;

    return _RecentActivityInfo(
      loopsThisWeek: loopsThisWeek,
      lastLoopDays: lastLoopDays,
      lastLoopDate: lastLoopDate,
    );
  }
}

class _EngagementStats {
  final int likes;
  final int comments;

  _EngagementStats({required this.likes, required this.comments});
}

class _RecentActivityInfo {
  final int loopsThisWeek;
  final int lastLoopDays;
  final DateTime? lastLoopDate;

  _RecentActivityInfo({
    required this.loopsThisWeek,
    required this.lastLoopDays,
    required this.lastLoopDate,
  });
}

class _CategoryStat {
  final String categoryName;
  final int count;
  final int percentage;

  _CategoryStat({
    required this.categoryName,
    required this.count,
    required this.percentage,
  });
}

class _WordsStats {
  final int totalWords;
  final int averageWords;
  final int maxWords;

  _WordsStats({
    required this.totalWords,
    required this.averageWords,
    required this.maxWords,
  });
}

class _TimelineEntry {
  final String period;
  final int count;

  _TimelineEntry({required this.period, required this.count});
}

