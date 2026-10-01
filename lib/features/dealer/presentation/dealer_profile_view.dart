import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/data/auth_repository.dart';
import '../../vehicles/data/mock_data.dart';
import '../../vehicles/data/vehicles_provider.dart';

class DealerProfileView extends ConsumerStatefulWidget {
  const DealerProfileView({super.key});

  @override
  ConsumerState<DealerProfileView> createState() => _DealerProfileViewState();
}

class _DealerProfileViewState extends ConsumerState<DealerProfileView> {
  bool _isEditing = false;
  late TextEditingController _businessController;
  late TextEditingController _contactController;
  late TextEditingController _whatsappController;
  late String _area;

  @override
  void initState() {
    super.initState();
    final dealer = ref.read(authProvider).currentDealer ?? MockData.currentDealer;
    _businessController = TextEditingController(text: dealer.businessName);
    _contactController = TextEditingController(text: dealer.contactName);
    _whatsappController = TextEditingController(text: dealer.whatsappPhone);
    _area = dealer.area;
  }

  @override
  void dispose() {
    _businessController.dispose();
    _contactController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  void _save() {
    final current = ref.read(authProvider).currentDealer ?? MockData.currentDealer;
    final updated = current.copyWith(
      businessName: _businessController.text.trim(),
      contactName: _contactController.text.trim(),
      whatsappPhone: _whatsappController.text.trim(),
      area: _area,
    );
    ref.read(authProvider.notifier).updateProfile(updated);
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dealership profile updated successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dealer = ref.watch(authProvider).currentDealer ?? MockData.currentDealer;
    final myStock = ref.watch(myStockProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dealership Profile', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 22),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Dealer Hero Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x2009090B),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      dealer.businessName.isNotEmpty ? dealer.businessName[0] : 'D',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.textOnPrimary),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    dealer.businessName,
                    style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.3),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dealer.contactName} • ${dealer.area}, ${dealer.city}',
                    style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  const VerifiedDealerBadge(),
                  const SizedBox(height: 18),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('My Stock', '${myStock.length} Cars'),
                      _buildStatColumn('Market City', dealer.city),
                      _buildStatColumn('Network ID', dealer.id.length > 8 ? dealer.id.substring(0, 8) : dealer.id),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Profile Information Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Dealership Info',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          if (_isEditing) {
                            _save();
                          } else {
                            setState(() => _isEditing = true);
                          }
                        },
                        icon: Icon(_isEditing ? Icons.check_circle_outline : Icons.edit_outlined, size: 16, color: AppColors.primary),
                        label: Text(
                          _isEditing ? 'Save Changes' : 'Edit Info',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (!_isEditing) ...[
                    _buildInfoTile('Business Name', dealer.businessName, Icons.storefront_outlined),
                    _buildInfoTile('Contact Person', dealer.contactName, Icons.person_outline),
                    _buildInfoTile('Login Phone', dealer.phone, Icons.phone_outlined),
                    _buildInfoTile('WhatsApp Number', dealer.whatsappPhone, Icons.chat_bubble_outline),
                    _buildInfoTile('Dealership Area', '${dealer.area}, Indore', Icons.location_on_outlined),
                  ] else ...[
                    TextFormField(
                      controller: _businessController,
                      decoration: const InputDecoration(labelText: 'Business Name'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(labelText: 'Contact Person Name'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _whatsappController,
                      decoration: const InputDecoration(labelText: 'WhatsApp Number'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _area,
                      decoration: const InputDecoration(labelText: 'Dealership Area'),
                      items: MockData.indoreAreas
                          .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _area = val);
                      },
                    ),
                    const SizedBox(height: 18),
                    AppButton(label: 'Save Changes', onPressed: _save),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // View Stock Action Button
            OutlinedButton.icon(
              onPressed: () => context.go('/my-stock'),
              icon: const Icon(Icons.inventory_2_outlined, size: 18),
              label: const Text('Manage Stock Inventory'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                side: const BorderSide(color: AppColors.primary, width: 1.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                context.go('/splash');
              },
              icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
              label: const Text('Log Out', style: TextStyle(color: AppColors.error)),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: -0.3),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}

