import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../vehicles/data/mock_data.dart';
import '../data/auth_repository.dart';

class DealerOnboardingView extends ConsumerStatefulWidget {
  const DealerOnboardingView({super.key});

  @override
  ConsumerState<DealerOnboardingView> createState() => _DealerOnboardingViewState();
}

class _DealerOnboardingViewState extends ConsumerState<DealerOnboardingView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _businessNameController = TextEditingController(text: 'Malwa Premium Cars');
  final TextEditingController _contactNameController = TextEditingController(text: 'Rajesh Sharma');
  final TextEditingController _whatsappController = TextEditingController();
  String _selectedCity = 'Indore';
  String _selectedArea = 'Vijay Nagar';

  @override
  void dispose() {
    _businessNameController.dispose();
    _contactNameController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(authProvider.notifier).completeOnboarding(
            businessName: _businessNameController.text.trim(),
            contactName: _contactNameController.text.trim(),
            city: _selectedCity,
            area: _selectedArea,
            whatsappNumber: _whatsappController.text.trim(),
          );
      if (success && mounted) {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dealership Setup'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dealership Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'This helps other dealers find and trust your inventory.',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),

                // Business Name
                TextFormField(
                  controller: _businessNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Dealership / Business Name *',
                    hintText: 'e.g. Malwa Premium Cars',
                    prefixIcon: Icon(Icons.storefront_outlined),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Please enter your dealership name' : null,
                ),
                const SizedBox(height: 16),

                // Contact Name
                TextFormField(
                  controller: _contactNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Dealer / Contact Person Name *',
                    hintText: 'e.g. Rajesh Sharma',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Please enter your contact name' : null,
                ),
                const SizedBox(height: 16),

                // City Dropdown (Locked to Indore for pilot)
                DropdownButtonFormField<String>(
                  initialValue: _selectedCity,
                  decoration: const InputDecoration(
                    labelText: 'City *',
                    prefixIcon: Icon(Icons.location_city_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Indore', child: Text('Indore, MP (Active Pilot)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCity = val);
                  },
                ),
                const SizedBox(height: 16),

                // Area Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedArea,
                  decoration: const InputDecoration(
                    labelText: 'Dealership Area in Indore *',
                    prefixIcon: Icon(Icons.pin_drop_outlined),
                  ),
                  items: MockData.indoreAreas
                      .map((area) => DropdownMenuItem(value: area, child: Text(area)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedArea = val);
                  },
                ),
                const SizedBox(height: 16),

                // WhatsApp Number (Optional)
                TextFormField(
                  controller: _whatsappController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'WhatsApp Number (Optional)',
                    hintText: 'Leave empty to use login phone number',
                    prefixIcon: Icon(Icons.chat_outlined, color: AppColors.whatsapp),
                  ),
                ),
                const SizedBox(height: 32),

                AppButton(
                  label: 'Start Adding Stock',
                  isLoading: authState.isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () {
                      ref.read(authProvider.notifier).logout();
                      context.go('/auth/mobile');
                    },
                    child: const Text(
                      'Use a different mobile number',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
