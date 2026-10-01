import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/constants/app_colors.dart';
import '../data/vehicles_provider.dart';

class ReportDialog extends ConsumerStatefulWidget {
  final String vehicleId;

  const ReportDialog({super.key, required this.vehicleId});

  @override
  ConsumerState<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends ConsumerState<ReportDialog> {
  final List<String> reasons = [
    'Vehicle sold but still listed',
    'Incorrect price / misleading details',
    'Duplicate listing',
    'Misleading photos',
    'Wrong dealer / not authorized',
    'Suspicious or fraudulent',
    'Other reason',
  ];

  late String _selectedReason;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedReason = reasons.first;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    ref.read(vehiclesProvider.notifier).reportVehicle(
          widget.vehicleId,
          _selectedReason,
          _notesController.text.trim(),
        );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you. The listing report has been submitted to Indore admin moderation.'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.flag_rounded, color: AppColors.accent, size: 22),
          SizedBox(width: 8),
          Text('Report Listing', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select the reason for reporting this inventory:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            RadioGroup<String>(
              groupValue: _selectedReason,
              onChanged: (val) {
                if (val != null) setState(() => _selectedReason = val);
              },
              child: Column(
                children: reasons.map((r) {
                  return RadioListTile<String>(
                    value: r,
                    title: Text(r, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    activeColor: AppColors.accent,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Additional details (optional)...',
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
          child: const Text('Submit Report'),
        ),
      ],
    );
  }
}
