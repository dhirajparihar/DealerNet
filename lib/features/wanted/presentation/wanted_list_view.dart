import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/url_helper.dart';
import '../../../core/widgets/empty_state.dart';
import '../data/wanted_provider.dart';

class WantedListView extends ConsumerWidget {
  const WantedListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wantedRequests = ref.watch(wantedProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: wantedRequests.isEmpty
          ? EmptyState(
              icon: Icons.campaign_outlined,
              title: 'No wanted vehicle requests.',
              subtitle: 'Tell 30+ Indore dealers what customer cars you are actively sourcing.',
              actionLabel: 'Post Wanted Requirement',
              onAction: () => context.push('/wanted/add'),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              itemCount: wantedRequests.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final req = wantedRequests[index];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border, width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + Match Count Pill
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                req.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            if (req.matchingCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.statusAvailableBg,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.statusAvailable.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.bolt_rounded, size: 13, color: AppColors.statusAvailable),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${req.matchingCount} Matches in Stock',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.statusAvailable,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Specs Row
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (req.budgetMax != null)
                              _buildPill(Icons.currency_rupee, 'Max ${CurrencyFormatter.formatCompact(req.budgetMax!)}'),
                            if (req.yearMin != null)
                              _buildPill(Icons.calendar_today_outlined, '${req.yearMin}-${req.yearMax ?? "Now"}'),
                            if (req.fuelType.isNotEmpty)
                              _buildPill(Icons.local_gas_station_outlined, req.fuelType),
                            if (req.transmission.isNotEmpty)
                              _buildPill(Icons.settings_outlined, req.transmission),
                            _buildPill(Icons.location_on_outlined, req.area),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Dealer Notes Callout Box
                        if (req.notes.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              '"${req.notes}"',
                              style: const TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Requesting Dealer Line + Action CTA
                        Row(
                          children: [
                            const Icon(Icons.storefront_rounded, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 5),
                            Text(
                              req.dealerName,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            // Quick WhatsApp Action Button
                            OutlinedButton.icon(
                              onPressed: () {
                                UrlHelper.openWhatsApp(
                                  phoneNumber: req.dealerWhatsapp,
                                  message:
                                      'Hi ${req.dealerName}, I saw your Wanted demand for ${req.title} on DealerNet Indore. I have a matching car available in my stock.',
                                );
                              },
                              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15, color: Color(0xFF15803D)),
                              label: const Text('I Have Stock', style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.w800, fontSize: 12.5)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.whatsappBorder, width: 1.0),
                                backgroundColor: AppColors.whatsappBg,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/wanted/add'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          icon: const Icon(Icons.add_rounded, color: AppColors.textOnPrimary, size: 22),
          label: const Text('Post Wanted', style: TextStyle(color: AppColors.textOnPrimary, fontWeight: FontWeight.w800, fontSize: 14)),
        ),
      ),
    );
  }

  Widget _buildPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

