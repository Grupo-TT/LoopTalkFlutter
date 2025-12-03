import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/topico_bloc.dart';
import '../bloc/topico_state.dart';
import '../model/topico.dart';

class VistaPrueba extends StatelessWidget {
  const VistaPrueba({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess) {
              final usuario = state.usuario;
              return SingleChildScrollView(
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
                  ],
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
}

class _TimelineEntry {
  final String period;
  final int count;

  _TimelineEntry({required this.period, required this.count});
}

