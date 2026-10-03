import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../auth/data/auth_repository.dart';
import '../data/mock_data.dart';
import '../data/vehicles_provider.dart';
import '../domain/vehicle.dart';
import '../../dealer/domain/dealer.dart';
import 'package:uuid/uuid.dart';

class AddVehicleFlowView extends ConsumerStatefulWidget {
  const AddVehicleFlowView({super.key});

  @override
  ConsumerState<AddVehicleFlowView> createState() => _AddVehicleFlowViewState();
}

class _AddVehicleFlowViewState extends ConsumerState<AddVehicleFlowView> {
  int _currentStep = 0;

  // Photos State
  final List<String> _photos = [
    'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?auto=format&fit=crop&w=800&q=80',
  ];

  // Details State
  String _make = 'Maruti Suzuki';
  String _model = 'Swift';
  final TextEditingController _variantController = TextEditingController(text: 'ZXi');
  final TextEditingController _yearController = TextEditingController(text: '2022');
  final TextEditingController _kmController = TextEditingController(text: '34000');
  final TextEditingController _priceController = TextEditingController(text: '680000');
  String _fuelType = 'Petrol';
  String _transmission = 'Manual';
  String _area = 'Vijay Nagar';
  final TextEditingController _colourController = TextEditingController(text: 'Pearl White');
  int _ownerCount = 1;
  final TextEditingController _regStateController = TextEditingController(text: 'MP-09');
  final TextEditingController _notesController = TextEditingController(text: 'Single owner, pristine condition, full company service book.');

  final _detailsFormKey = GlobalKey<FormState>();
  bool _isPublishing = false;

  void _showFastPasteDialog() {
    final TextEditingController pasteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.bolt_rounded, color: Colors.amber, size: 24),
              SizedBox(width: 8),
              Text('Paste from WhatsApp', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste your WhatsApp listing text to auto-fill specs in 1 second:',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pasteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'e.g. Creta 2021 SX Petrol 45000 km 12.5L Vijay Nagar Indore',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _parseWhatsAppText(pasteController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Specs auto-filled from text.')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Parse & Autofill'),
            ),
          ],
        );
      },
    );
  }

  void _parseWhatsAppText(String text) {
    if (text.isEmpty) return;
    final lower = text.toLowerCase();

    // Make & Model Detection
    for (final m in MockData.makes) {
      if (lower.contains(m.toLowerCase())) {
        _make = m;
        final models = MockData.modelsByMake[m] ?? ['Other'];
        for (final modelName in models) {
          if (lower.contains(modelName.toLowerCase())) {
            _model = modelName;
            break;
          }
        }
        break;
      }
    }

    // Year Detection (2010-2026)
    final yearMatch = RegExp(r'\b(20[12][0-9])\b').firstMatch(text);
    if (yearMatch != null) {
      _yearController.text = yearMatch.group(1)!;
    }

    // Price Detection (e.g., 12.5L, 6.8L, 680000, 1250000)
    final lakhMatch = RegExp(r'([0-9]+(?:\.[0-9]+)?)\s*(?:l|lakh|lakhs)', caseSensitive: false).firstMatch(text);
    if (lakhMatch != null) {
      final lakhs = double.tryParse(lakhMatch.group(1)!) ?? 0;
      if (lakhs > 0) {
        _priceController.text = (lakhs * 100000).toInt().toString();
      }
    } else {
      final rawPriceMatch = RegExp(r'\b([3-9][0-9]{5}|[1-9][0-9]{6})\b').firstMatch(text);
      if (rawPriceMatch != null) {
        _priceController.text = rawPriceMatch.group(1)!;
      }
    }

    // KM Detection (e.g., 45k, 45000 km, 45,000)
    final kmMatch = RegExp(r'([0-9]+(?:\.[0-9]+)?)\s*(?:k|km|000)', caseSensitive: false).firstMatch(text);
    if (kmMatch != null) {
      final kmVal = double.tryParse(kmMatch.group(1)!) ?? 0;
      if (kmVal < 500) {
        _kmController.text = (kmVal * 1000).toInt().toString();
      } else {
        _kmController.text = kmVal.toInt().toString();
      }
    }

    // Fuel Type
    if (lower.contains('petrol')) _fuelType = 'Petrol';
    if (lower.contains('diesel')) _fuelType = 'Diesel';
    if (lower.contains('cng')) _fuelType = 'CNG';
    if (lower.contains('ev') || lower.contains('electric')) _fuelType = 'Electric';

    // Transmission
    if (lower.contains('auto') || lower.contains('automatic') || lower.contains('amt') || lower.contains('dct')) {
      _transmission = 'Automatic';
    } else if (lower.contains('manual')) {
      _transmission = 'Manual';
    }

    setState(() {});
  }

  @override
  void dispose() {
    _variantController.dispose();
    _yearController.dispose();
    _kmController.dispose();
    _priceController.dispose();
    _colourController.dispose();
    _regStateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addSamplePhoto() {
    setState(() {
      _photos.add('https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=800&q=80');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vehicle photo attached successfully!')),
    );
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  void _onNext() {
    if (_currentStep == 0) {
      if (_photos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least 1 photo of the car.')),
        );
        return;
      }
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (_detailsFormKey.currentState?.validate() ?? false) {
        setState(() => _currentStep = 2);
      }
    } else if (_currentStep == 2) {
      _publishVehicle();
    }
  }

  void _publishVehicle() async {
    setState(() => _isPublishing = true);
    await Future.delayed(const Duration(milliseconds: 700));

    final currentDealer = ref.read(authProvider).currentDealer ?? MockData.currentDealer;
    final now = DateTime.now();
    final newVehicle = Vehicle(
      id: const Uuid().v4(),
      dealerId: currentDealer.id,
      dealerName: currentDealer.businessName,
      dealerPhone: currentDealer.phone,
      dealerWhatsapp: currentDealer.whatsappPhone,
      dealerVerified: currentDealer.verificationStatus == VerificationStatus.verified,
      make: _make,
      model: _model,
      variant: _variantController.text.trim(),
      year: int.tryParse(_yearController.text) ?? 2022,
      km: int.tryParse(_kmController.text) ?? 30000,
      priceRupees: int.tryParse(_priceController.text) ?? 600000,
      fuelType: _fuelType,
      transmission: _transmission,
      city: 'Indore',
      area: _area,
      colour: _colourController.text.trim(),
      ownerCount: _ownerCount,
      registrationState: _regStateController.text.trim(),
      insuranceStatus: 'Comprehensive Active',
      serviceHistory: 'Authorized Service Center Record',
      accidentCondition: 'Certified Non-Accidental',
      notes: _notesController.text.trim(),
      status: VehicleStatus.available,
      photos: List.from(_photos),
      lastAvailabilityConfirmedAt: now,
      publishedAt: now,
      createdAt: now,
    );

    final success = await ref.read(vehiclesProvider.notifier).addVehicle(newVehicle);

    if (!mounted) return;
    setState(() => _isPublishing = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to publish vehicle. Please try again.'),
        ),
      );
      return;
    }

    _showSuccessDialog(newVehicle);
  }

  void _showSuccessDialog(Vehicle vehicle) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.statusAvailableBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.statusAvailable, size: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'Vehicle Published!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Your ${vehicle.title} is now discoverable by all verified Indore dealers.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/my-stock');
                },
                icon: const Icon(Icons.inventory_2_rounded, size: 18),
                label: const Text('View in My Stock'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                  backgroundColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentStep = 0;
                    _photos.clear();
                  });
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                ),
                child: const Text('Add Another Vehicle'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Vehicle'),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vehicle draft saved locally!')),
              );
              context.pop();
            },
            child: const Text('Save Draft', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Step Progress Bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _buildStepIndicator(0, '1. Photos'),
                _buildStepDivider(0),
                _buildStepIndicator(1, '2. Details'),
                _buildStepDivider(1),
                _buildStepIndicator(2, '3. Review'),
              ],
            ),
          ),
          const Divider(height: 1),

          // Active Step Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStepContent(),
            ),
          ),

          // Bottom Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  if (_currentStep > 0) ...[
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentStep--),
                        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 50)),
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      label: _currentStep == 2 ? 'Publish Vehicle' : 'Continue',
                      isLoading: _isPublishing,
                      onPressed: _onNext,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int stepIndex, String title) {
    final isActive = _currentStep == stepIndex;
    final isDone = _currentStep > stepIndex;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isDone
                ? AppColors.statusAvailable
                : (isActive ? AppColors.primary : AppColors.surfaceMuted),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
                    '${stepIndex + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive || isDone ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(int stepIndex) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: _currentStep > stepIndex ? AppColors.statusAvailable : AppColors.border,
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPhotosStep();
      case 1:
        return _buildDetailsStep();
      case 2:
        return _buildReviewStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // Step 1: Photos (S09)
  Widget _buildPhotosStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Vehicle Photos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text(
          'Add 1 to 10 photos. Clear exterior and interior photos help dealers close deals faster.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _photos.length + 1,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            if (index == _photos.length) {
              return InkWell(
                onTap: _addSamplePhoto,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 32, color: AppColors.primary),
                      SizedBox(height: 8),
                      Text('+ Add Photo', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                ),
              );
            }

            return Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(_photos[index], fit: BoxFit.cover),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => _removePhoto(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ),
                if (index == 0)
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                      child: const Text('Cover', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  // Step 2: Details (S10)
  Widget _buildDetailsStep() {
    final availableModels = MockData.modelsByMake[_make] ?? ['Other'];

    return Form(
      key: _detailsFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Vehicle Specifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              TextButton.icon(
                onPressed: _showFastPasteDialog,
                icon: const Icon(Icons.bolt_rounded, size: 18, color: Colors.amber),
                label: const Text('Fast Paste', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Make Dropdown
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

          // Model Dropdown
          DropdownButtonFormField<String>(
            initialValue: availableModels.contains(_model) ? _model : availableModels.first,
            decoration: const InputDecoration(labelText: 'Model *'),
            items: availableModels.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _model = val);
            },
          ),
          const SizedBox(height: 14),

          // Variant
          TextFormField(
            controller: _variantController,
            decoration: const InputDecoration(labelText: 'Variant', hintText: 'e.g. ZXi, SX(O), VXi'),
          ),
          const SizedBox(height: 14),

          // Year and KM Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                  decoration: const InputDecoration(labelText: 'Year *', hintText: '2022'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _kmController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'KM Driven *', hintText: '40000'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Price in Rupees
          TextFormField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Asking Price (₹) *',
              hintText: 'e.g. 680000',
              prefixText: '₹ ',
            ),
            validator: (v) => v == null || v.isEmpty ? 'Please enter asking price' : null,
          ),
          const SizedBox(height: 14),

          // Fuel and Transmission Row
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _fuelType,
                  decoration: const InputDecoration(labelText: 'Fuel *'),
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
                  decoration: const InputDecoration(labelText: 'Transmission *'),
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
            decoration: const InputDecoration(labelText: 'Vehicle Location in Indore *'),
            items: MockData.indoreAreas.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _area = val);
            },
          ),
          const SizedBox(height: 14),

          // Colour and Owners
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _colourController,
                  decoration: const InputDecoration(labelText: 'Colour', hintText: 'White, Grey...'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _ownerCount,
                  decoration: const InputDecoration(labelText: 'Owners'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('1st Owner')),
                    DropdownMenuItem(value: 2, child: Text('2nd Owner')),
                    DropdownMenuItem(value: 3, child: Text('3rd Owner')),
                    DropdownMenuItem(value: 4, child: Text('4+ Owners')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _ownerCount = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Notes
          TextFormField(
            controller: _notesController,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Dealer Notes (Optional)', hintText: 'Features, battery status, warranty details...'),
          ),
        ],
      ),
    );
  }

  // Step 3: Review & Publish (S11)
  Widget _buildReviewStep() {
    final price = int.tryParse(_priceController.text) ?? 0;
    final km = int.tryParse(_kmController.text) ?? 0;
    final year = int.tryParse(_yearController.text) ?? 2022;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Review Before Publishing', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text(
          'Verify your listing details. Other Indore dealers will see exactly this card.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),

        // Live Preview Card
        Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_photos.isNotEmpty)
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Image.network(_photos.first, fit: BoxFit.cover),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '$year $_make $_model ${_variantController.text}'.trim(),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatCompact(price),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${CurrencyFormatter.formatKm(km)} • $_fuelType • $_transmission • $_ownerCount Owner',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '📍 $_area, Indore',
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.verifiedBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.verified_user_rounded, color: AppColors.verified),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Once published, your contact info is immediately accessible to registered dealers for direct Call or WhatsApp.',
                  style: TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
