import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_colors.dart';
import '../../auth/data/auth_repository.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  bool _pushNotifications = true;
  bool _whatsappAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'PREFERENCES',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted),
            ),
          ),
          SwitchListTile(
            value: _pushNotifications,
            activeThumbColor: AppColors.primary,
            title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Receive instant alerts when matching vehicles are listed'),
            onChanged: (val) => setState(() => _pushNotifications = val),
          ),
          SwitchListTile(
            value: _whatsappAlerts,
            activeThumbColor: AppColors.primary,
            title: const Text('WhatsApp Alerts', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Notify me on WhatsApp for urgent wanted vehicle matches'),
            onChanged: (val) => setState(() => _whatsappAlerts = val),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'NETWORK & TRUST',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.security_outlined),
            title: const Text('Indore Dealer Verification Status'),
            subtitle: const Text('Verified Member #IND-2024-089'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help_outline_rounded),
            title: const Text('DealerNet Support & Helpdesk'),
            subtitle: const Text('Indore Coordinator: +91 98260 00111'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Support line: +91 98260 00111 (Indore Desk)')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of B2B Service & Rules'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.accent),
            title: const Text(
              'Log Out',
              style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700),
            ),
            onTap: () {
              final router = GoRouter.of(context);
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Log Out?'),
                  content: const Text('Are you sure you want to log out of your dealership account?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        ref.read(authProvider.notifier).logout();
                        router.go('/splash');
                      },
                      child: const Text('Log Out'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          const Center(
            child: Text(
              'DealerNet v1.0.0 (Indore Pilot Build)',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
