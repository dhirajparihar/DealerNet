import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../data/notifications_provider.dart';
import '../domain/notification_item.dart';

class NotificationsView extends ConsumerWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(notificationsProvider.notifier).markAllAsRead();
              },
              child: const Text('Mark all read', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No new notifications.',
              subtitle: 'You will receive alerts here when matching cars or dealer inquiries arrive.',
            )
          : ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 64),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                IconData icon;
                Color iconBg;
                Color iconColor;

                switch (notif.type) {
                  case NotificationType.vehicleMatch:
                  case NotificationType.wantedMatch:
                    icon = Icons.directions_car_rounded;
                    iconBg = AppColors.statusAvailableBg;
                    iconColor = AppColors.statusAvailable;
                    break;
                  case NotificationType.interestAlert:
                    icon = Icons.chat_bubble_outline_rounded;
                    iconBg = AppColors.verifiedBg;
                    iconColor = AppColors.verified;
                    break;
                  case NotificationType.verificationUpdate:
                    icon = Icons.verified_user_rounded;
                    iconBg = AppColors.statusInfoBg;
                    iconColor = AppColors.statusInfo;
                    break;
                  case NotificationType.expiryAlert:
                    icon = Icons.access_time_rounded;
                    iconBg = AppColors.statusReservedBg;
                    iconColor = AppColors.statusReserved;
                    break;
                }

                return ListTile(
                  tileColor: notif.isRead ? Colors.transparent : Colors.white,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  title: Text(
                    notif.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 3),
                      Text(
                        notif.body,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormatter.formatFreshness(notif.createdAt),
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  onTap: () {
                    ref.read(notificationsProvider.notifier).markAsRead(notif.id);
                    if (notif.routeUrl != null) {
                      context.push(notif.routeUrl!);
                    }
                  },
                );
              },
            ),
    );
  }
}
