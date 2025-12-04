import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
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
  final GlobalKey? navBarKey;
  final bool isActive;

  const VistaPrueba({super.key, this.navBarKey, this.isActive = false});

  @override
  State<VistaPrueba> createState() => _VistaPruebaState();
}

class _VistaPruebaState extends State<VistaPrueba> {
  static const _tutorialPrefKeyStats = 'tutorial_stats_shown';
  bool _statsTutorialSeen = true;

  @override
  void initState() {
    super.initState();
    // Cargar los tópicos cuando se abre la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TopicoBloc>().add(LoadTopicos());
    });
    _loadStatsTutorial();
  }

  @override
  void didUpdateWidget(covariant VistaPrueba oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_statsTutorialSeen && widget.isActive && !oldWidget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowStatsTutorial());
    }
  }

  Future<void> _loadStatsTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = _currentUserId();
    final seen = prefs.getBool('${_tutorialPrefKeyStats}_$userId') ?? false;
    setState(() {
      _statsTutorialSeen = seen;
    });
    if (!seen && widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowStatsTutorial());
    }
  }

  String _currentUserId() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      return authState.usuario.id.toString();
    }
    return 'guest';
  }

  void _maybeShowStatsTutorial() {
    if (!mounted || _statsTutorialSeen || !widget.isActive || widget.navBarKey == null) {
      return;
    }
    if (widget.navBarKey!.currentContext == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowStatsTutorial());
      return;
    }

    final targets = <TargetFocus>[
      TargetFocus(
        identify: 'stats_nav_bar',
        keyTarget: widget.navBarKey!,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _buildTutorialContent(
              title: 'Estadísticas',
              description: 'Aquí puedes ver tus estadísticas más relevantes: loops creados, actividad, escritura, categorías y engagement.',
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
      onFinish: _markStatsTutorialSeen,
      onSkip: () {
        _markStatsTutorialSeen();
        return true;
      },
    ).show(context: context);
  }

  Widget _buildTutorialContent({
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

  Future<void> _markStatsTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = _currentUserId();
    await prefs.setBool('${_tutorialPrefKeyStats}_$userId', true);
    setState(() {
      _statsTutorialSeen = true;
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
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Estadísticas',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Resumen de tu actividad en LoopTalk',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildStatsSection(context, usuario.id),
                        const SizedBox(height: 28),
                        _buildSectionTitle('Actividad'),
                        const SizedBox(height: 16),
                        _buildTimelineSection(context, usuario.id),
                        const SizedBox(height: 28),
                        _buildSectionTitle('Escritura'),
                        const SizedBox(height: 16),
                        _buildWordsSection(context, usuario.id),
                        const SizedBox(height: 28),
                        _buildSectionTitle('Categorías'),
                        const SizedBox(height: 16),
                        _buildCategoryDistributionSection(context, usuario.id),
                        const SizedBox(height: 28),
                        _buildSectionTitle('Engagement'),
                        const SizedBox(height: 16),
                        _buildEngagementSection(context, usuario.id),
                        const SizedBox(height: 28),
                        _buildSectionTitle('Actividad reciente'),
                        const SizedBox(height: 16),
                        _buildRecentActivitySection(context, usuario.id),
                        const SizedBox(height: 24),
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
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
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
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        letterSpacing: -0.3,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
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
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.insights, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aún no has creado loops',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Comparte tu primera idea para ver aquí tu actividad.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final timelineEntries = _buildMonthlyTimeline(userTopicos);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.timeline, size: 20, color: Colors.black87),
                   SizedBox(width: 8),
                   Text(
                    'Loops por mes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...timelineEntries.asMap().entries.map(
                (entry) => Padding(
                  padding: EdgeInsets.only(bottom: entry.key < timelineEntries.length - 1 ? 14 : 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.value.period,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${entry.value.count}',
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.edit_note, size: 20, color: Colors.black87),
                   SizedBox(width: 8),
                   Text(
                    'Estadísticas de escritura',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildWordsStatRow(
                label: 'Total de palabras',
                value: '${wordsStats.totalWords}',
                icon: Icons.text_fields,
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: Colors.grey[200]),
              const SizedBox(height: 16),
              _buildWordsStatRow(
                label: 'Promedio por loop',
                value: '${wordsStats.averageWords}',
                icon: Icons.bar_chart,
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: Colors.grey[200]),
              const SizedBox(height: 16),
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
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Colors.black87),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const  Row(
                children: [
                  Icon(Icons.category, size: 20, color: Colors.black87),
                   SizedBox(width: 8),
                 Text(
                    'Loops por categoría',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: categoryStats.map(
                  (stat) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey[200]!, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          stat.categoryName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(16),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const  Row(
                    children: [
                      Icon(Icons.favorite, size: 20, color: Colors.black87),
                       SizedBox(width: 8),
                       Text(
                        'Interacción recibida',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildEngagementRow(
                    icon: Icons.thumb_up_outlined,
                    label: 'Likes recibidos',
                    value: '${stats.likes}',
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: Colors.grey[200]),
                  const SizedBox(height: 16),
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
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Colors.black87),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.update, size: 20, color: Colors.black87),
                       SizedBox(width: 8),
                       Text(
                        'Resumen de actividad',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (activityInfo.loopsThisWeek > 0)
                    _buildActivityRow(
                      icon: Icons.calendar_today,
                      text: 'Has creado ${activityInfo.loopsThisWeek} loop${activityInfo.loopsThisWeek == 1 ? '' : 's'} esta semana',
                    ),
                  if (activityInfo.loopsThisWeek > 0) const SizedBox(height: 16),
                  if (activityInfo.loopsThisWeek > 0)
                    Divider(height: 1, color: Colors.grey[200]),
                  if (activityInfo.loopsThisWeek > 0) const SizedBox(height: 16),
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
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Colors.black87),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
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

