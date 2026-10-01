import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../auth/data/auth_repository.dart';
import '../../vehicles/data/mock_data.dart';
import '../data/wanted_provider.dart';
import '../domain/wanted_request.dart';

class AddWantedView extends ConsumerStatefulWidget {
  const AddWantedView({super.key});

  @override
  ConsumerState<AddWantedView> createState() => _AddWantedViewState();
}

class _AddWantedViewState extends ConsumerState<AddWantedView> {
  final _formKey = GlobalKey<FormState>();
  String _make = 'Hyundai';
  String _model = 'Creta';
  final TextEditingController _budgetController = TextEditingController(text: '1500000');
  final TextEditingController _kmLimitController = TextEditingController(text: '45000');
  final TextEditingController _minYearController = TextEditingController(text: '2021');
  String _fuelType = 'Diesel';
  String _transmission = 'Automatic';
  String _area = 'Vijay Nagar';
  final TextEditingController _notesController = TextEditingController(text: 'Immediate payment ready, customer waiting in showroom.');
  bool _isLoading = false;

  @override
  void dispose() {
    _budgetController.dispose();
    _kmLimitController.dispose();
    _minYearController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 600));

      final currentDealer = ref.read(authProvider).currentDealer ?? MockData.currentDealer;
      final now = DateTime.now();

      final req = WantedRequest(
        id: 'want-${now.millisecondsSinceEpoch}',
        dealerId: currentDealer.id,
        dealerName: currentDealer.businessName,
        dealerPhone: currentDealer.phone,
        dealerWhatsapp: currentDealer.whatsappPhone,
        make: _make,
        model: _model,
        yearMin: int.tryParse(_minYearController.text),
        yearMax: 2025,
        budgetMax: int.tryParse(_budgetController.text),
        kmMax: int.tryParse(_kmLimitController.text),
        fuelType: _fuelType,
        transmission: _transmission,
        city: 'Indore',
        area: _area,
        notes: _notesController.text.trim(),
        matchingCount: 1,
        createdAt: now,
      );

      ref.read(wantedProvider.notifier).addWantedRequest(req);

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wanted stock request published to Indore dealers!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableModels = MockData.modelsByMake[_make] ?? ['Other'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Post Wanted Stock'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Broadcast Customer Demand',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Let other Indore dealers know when you have a buyer ready for a car you do not currently stock.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Make
              DropdownButtonFormField<String>(
                initialValue: _make,
                decoration: const InputDecoration(labelText: 'Make *'),
                items: MockData.makes.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _make = val;
                      _model = (MockData.modelsByMake[val] ?? ['Other']).first;
                    });
                  }
                },
              ),
              const SizedBox(height: 14),

              // Model
              DropdownButtonFormField<String>(
                initialValue: availableModels.contains(_model) ? _model : availableModels.first,
                decoration: const InputDecoration(labelText: 'Model *'),
                items: availableModels.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _model = val);
                },
              ),
              const SizedBox(height: 14),

              // Budget & KM
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(labelText: 'Max Budget (₹)', prefixText: '₹ '),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _minYearController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(labelText: 'Min Model Year', hintText: '2020'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Fuel & Transmission
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _fuelType,
                      decoration: const InputDecoration(labelText: 'Fuel'),
                      items: MockData.fuelTypes.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _fuelType = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _transmission,
                      decoration: const InputDecoration(labelText: 'Transmission'),
                      items: MockData.transmissions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _transmission = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Area in Indore
              DropdownButtonFormField<String>(
                initialValue: _area,
                decoration: const InputDecoration(labelText: 'Preferred Dealership Area'),
                items: MockData.indoreAreas.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _area = val);
                },
              ),
              const SizedBox(height: 14),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Demand Notes',
                  hintText: 'Customer requirement details, preferred colors, payment readiness...',
                ),
              ),
              const SizedBox(height: 32),

              AppButton(
                label: 'Publish Wanted Request',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
