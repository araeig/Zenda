import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_client.dart';

class UserAvatar extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final double size;
  final ThemeColors colors;

  const UserAvatar({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.avatarUrl,
    required this.size,
    required this.colors,
  });

  String get _initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.accent, colors.accent2],
        ),
      ),
      child: Text(
        _initials,
        style: TextStyle(
          color: colors.onAccent,
          fontSize: size * 0.3,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    final url = avatarUrl;
    if (url == null || url.isEmpty) return fallback;

    return ClipOval(
      child: Image.network(
        '${ApiClient.baseUrl}$url',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}
