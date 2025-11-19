import 'package:flutter/material.dart';

class VistaNotificaciones extends StatelessWidget {
  const VistaNotificaciones({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notificaciones',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.white),
            onPressed: () {
              // Marcar todas como leídas
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildNotificationCard(
            icon: Icons.favorite,
            iconColor: Colors.red,
            title: 'Nuevo me gusta',
            message: 'A alguien le gustó tu comentario',
            time: 'Hace 5 min',
            isRead: false,
          ),
          _buildNotificationCard(
            icon: Icons.comment,
            iconColor: Colors.blue,
            title: 'Nuevo comentario',
            message: 'Tienes un nuevo comentario en tu publicación',
            time: 'Hace 1 hora',
            isRead: false,
          ),
          _buildNotificationCard(
            icon: Icons.person_add,
            iconColor: Colors.green,
            title: 'Nuevo seguidor',
            message: 'Tienes un nuevo seguidor',
            time: 'Hace 2 horas',
            isRead: true,
          ),
          _buildNotificationCard(
            icon: Icons.category,
            iconColor: Colors.orange,
            title: 'Nueva categoría disponible',
            message: 'Explora las nuevas categorías agregadas',
            time: 'Hace 1 día',
            isRead: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String time,
    required bool isRead,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isRead ? 0 : 2,
      color: isRead ? Colors.grey[50] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(message, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        trailing: !isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }
}
