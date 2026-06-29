import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:priora/features/shared/auth/data/auth_state.dart';
import 'package:priora/features/shared/auth/data/auth_bloc.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationsTap;

  const HomeHeader({
    super.key,
    this.onProfileTap,
    this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Dynamic Avatar from API - taps to Profile tab
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            String? photoUrl;
            if (state is AuthAuthenticated) {
              photoUrl = state.profilePhotoUrl;
            }
            final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

            return GestureDetector(
              onTap: onProfileTap,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                ),
                child: ClipOval(
                  child: hasPhoto
                      ? Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person, color: Color(0xFF64748B)),
                        )
                      : Container(
                          color: const Color(0xFFE2E8F0),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF64748B),
                            size: 24,
                          ),
                        ),
                ),
              ),
            );
          },
        ),
        // Priora Title
        Text(
          'Priora',
          style: theme.textTheme.titleLarge?.copyWith(
            color: const Color(0xFF0256C2),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        // Notifications bell with mini active badge
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF0256C2),
                size: 28,
              ),
              onPressed: onNotificationsTap ?? () => context.push('/notifications'),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
