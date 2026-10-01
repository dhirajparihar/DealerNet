import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/constants/app_colors.dart';
import '../data/auth_repository.dart';

class WelcomeFlowView extends ConsumerStatefulWidget {
  const WelcomeFlowView({super.key});

  @override
  ConsumerState<WelcomeFlowView> createState() => _WelcomeFlowViewState();
}

class _WelcomeFlowViewState extends ConsumerState<WelcomeFlowView> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSplash = true;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..addListener(() {
        setState(() {});
      });

    _handleInitialRouting();
  }

  void _handleInitialRouting() async {
    _progressController.forward();
    
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final authState = ref.read(authProvider);

    if (authState.status == AuthStatus.authenticated) {
      context.go('/home');
    } else if (authState.status == AuthStatus.onboardingRequired) {
      context.go('/onboarding/profile');
    } else if (authState.status == AuthStatus.pendingApproval) {
      context.go('/pending-approval');
    } else if (authState.status == AuthStatus.otpSent) {
      context.go('/auth/otp');
    } else {
      setState(() {
        _isSplash = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isSplash ? _buildSplashScreen() : _buildOnboardingCarousel(),
    );
  }

  // Screen 1: Clean, minimal splash screen
  Widget _buildSplashScreen() {
    return Stack(
      children: [
        Align(
          alignment: const Alignment(0, -0.15), // True optical center
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'DealerNet',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'B2B CAR DEALER NETWORK',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        // Subtle linear loading indicator at the bottom edge
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 4,
            width: double.infinity,
            color: AppColors.surfaceContainerHigh,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _progressController.value,
              child: Container(
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Screens 2 & 3: Editorial Card Layout Carousel
  Widget _buildOnboardingCarousel() {
    return Stack(
      children: [
        PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          children: [
            _buildEditorialCard(
              imageUrl: 'https://images.unsplash.com/photo-1560958089-b8a1929cea89?auto=format&fit=crop&w=800&q=80',
              title: 'Exclusive B2B\nNetwork',
              subtitle: 'Connect with verified Indore car dealers. Share inventory, find specific vehicles, and close deals faster in a trusted ecosystem.',
            ),
            _buildEditorialCard(
              imageUrl: 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?auto=format&fit=crop&w=800&q=80',
              title: 'Real-Time\nInventory',
              subtitle: 'Broadcast your newly acquired stock instantly to hundreds of active dealers. Turn over your inventory with zero commissions.',
            ),
          ],
        ),
        
        // Integrated Primary CTA fixed to bottom sheet area
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 24,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Continuous Carousel Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(2, (index) => _buildDot(index)),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == 1) {
                        context.go('/auth/mobile');
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.fastOutSlowIn,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentPage == 1 ? 'Get Started' : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  if (_currentPage == 0) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.go('/auth/mobile'),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        foregroundColor: AppColors.textSecondary,
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    const SizedBox(height: 56), // Maintain height structure
                  ]
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditorialCard({required String imageUrl, required String title, required String subtitle}) {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.background.withValues(alpha: 0.8),
                    AppColors.background,
                  ],
                  stops: const [0.6, 0.9, 1.0],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 6,
      width: _currentPage == index ? 24 : 6,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primary : AppColors.borderDark,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
