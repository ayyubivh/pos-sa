import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_final/core/theme/app_theme.dart';
import 'package:pos_final/pages/notifications/view_model_manger/notifications_cubit.dart';

class DesktopStatusBar extends StatefulWidget {
  const DesktopStatusBar({super.key});

  @override
  State<DesktopStatusBar> createState() => _DesktopStatusBarState();
}

class _DesktopStatusBarState extends State<DesktopStatusBar> {
  late Timer _clock;
  String _time = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  @override
  void dispose() {
    _clock.cancel();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _time =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTheme = AppTheme.getCustomAppTheme(1);

    return Container(
      height: 28,
      color: customTheme.bgLayer2,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // App name / version
          Text(
            'EazyERP POS',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // Sync status indicator
          _SyncIndicator(),
          const SizedBox(width: 16),
          // Notification badge
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              final count = state is NotificationGetDataSuccessful
                  ? state.notifications.length
                  : 0;
              return Row(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$count',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onError,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(width: 16),
          // Clock
          Text(
            _time,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'Online',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
      ],
    );
  }
}
