import 'package:flutter/material.dart';
import '../services/firebase_profile_service.dart';

/// A reusable avatar widget that displays a user's profile photo from Firebase.
/// Falls back to an icon if no photo is available.
class UserAvatar extends StatelessWidget {
  final int? userId;
  final double radius;
  final Color? backgroundColor;
  final Color? iconColor;

  const UserAvatar({
    super.key,
    required this.userId,
    this.radius = 20,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return _buildDefaultAvatar();
    }

    final profileService = FirebaseProfileService();

    return FutureBuilder<String?>(
      future: profileService.getProfilePhoto(userId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingAvatar();
        }

        final fotoUrl = snapshot.data;

        if (fotoUrl != null && fotoUrl.isNotEmpty) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: backgroundColor ?? Colors.grey[200],
            backgroundImage: NetworkImage(fotoUrl),
            onBackgroundImageError: (_, __) {},
            child: null,
          );
        }

        return _buildDefaultAvatar();
      },
    );
  }

  Widget _buildDefaultAvatar() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey[200],
      child: Icon(
        Icons.person,
        color: iconColor ?? Colors.grey[600],
        size: radius,
      ),
    );
  }

  Widget _buildLoadingAvatar() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey[200],
      child: SizedBox(
        width: radius,
        height: radius,
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

/// Stream-based avatar that updates in real-time when the user changes their photo.
class UserAvatarStream extends StatelessWidget {
  final int? userId;
  final double radius;
  final Color? backgroundColor;
  final Color? iconColor;

  const UserAvatarStream({
    super.key,
    required this.userId,
    this.radius = 20,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return _buildDefaultAvatar();
    }

    final profileService = FirebaseProfileService();

    return StreamBuilder<String?>(
      stream: profileService.getProfilePhotoStream(userId!),
      builder: (context, snapshot) {
        final fotoUrl = snapshot.data;

        if (fotoUrl != null && fotoUrl.isNotEmpty) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: backgroundColor ?? Colors.grey[200],
            backgroundImage: NetworkImage(fotoUrl),
            onBackgroundImageError: (_, __) {},
            child: null,
          );
        }

        return _buildDefaultAvatar();
      },
    );
  }

  Widget _buildDefaultAvatar() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey[200],
      child: Icon(
        Icons.person,
        color: iconColor ?? Colors.grey[600],
        size: radius,
      ),
    );
  }
}
