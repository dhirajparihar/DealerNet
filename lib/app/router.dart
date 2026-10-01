import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'main_navigation_shell.dart';
import '../features/auth/presentation/welcome_flow_view.dart';
import '../features/auth/presentation/mobile_login_view.dart';
import '../features/auth/presentation/otp_verification_view.dart';
import '../features/auth/presentation/dealer_onboarding_view.dart';
import '../features/auth/presentation/pending_approval_view.dart';
import '../features/home/presentation/home_view.dart';
import '../features/search/presentation/search_view.dart';
import '../features/wanted/presentation/wanted_list_view.dart';
import '../features/wanted/presentation/add_wanted_view.dart';
import '../features/vehicles/presentation/my_stock_view.dart';
import '../features/vehicles/presentation/vehicle_detail_view.dart';
import '../features/vehicles/presentation/add_vehicle_flow_view.dart';
import '../features/dealer/presentation/dealer_profile_view.dart';
import '../features/notifications/presentation/notifications_view.dart';
import '../features/settings/presentation/settings_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/data/auth_repository.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

class RouterNotifier extends Listenable {
  final Ref ref;
  VoidCallback? _listener;

  RouterNotifier(this.ref) {
    ref.listen<AuthState>(authProvider, (_, __) {
      _listener?.call();
    });
  }

  @override
  void addListener(VoidCallback listener) {
    _listener = listener;
  }

  @override
  void removeListener(VoidCallback listener) {
    _listener = null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final path = state.uri.toString();
      final isAuthRoute = path.startsWith('/auth') || path == '/splash';
      final isOnboardingRoute = path == '/onboarding/profile';
      
      switch (authState.status) {
        case AuthStatus.unauthenticated:
          // Must be on an auth route; redirect if not
          if (!isAuthRoute) return '/splash';
          return null;
        case AuthStatus.otpSent:
          // Allow auth routes (login + otp screens)
          if (!isAuthRoute) return '/auth/mobile';
          return null;
        case AuthStatus.onboardingRequired:
          if (path == '/splash') return '/onboarding/profile';
          if (isAuthRoute || isOnboardingRoute) return null;
          return '/onboarding/profile';
        case AuthStatus.pendingApproval:
          if (path != '/pending-approval') return '/pending-approval';
          return null;
        case AuthStatus.authenticated:
          // Redirect away from auth/onboarding screens to home
          if (isAuthRoute || isOnboardingRoute) return '/home';
          return null;
      }
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const WelcomeFlowView(),
      ),
      GoRoute(
        path: '/auth/mobile',
        builder: (context, state) => const MobileLoginView(),
      ),
      GoRoute(
        path: '/auth/otp',
        builder: (context, state) => const OtpVerificationView(),
      ),
      GoRoute(
        path: '/onboarding/profile',
        builder: (context, state) => const DealerOnboardingView(),
      ),
      GoRoute(
        path: '/pending-approval',
        builder: (context, state) => const PendingApprovalView(),
      ),

      // 4-Tab Bottom Navigation Shell
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainNavigationShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeView(),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchView(),
          ),
          GoRoute(
            path: '/wanted',
            builder: (context, state) => const WantedListView(),
          ),
          GoRoute(
            path: '/my-stock',
            builder: (context, state) => const MyStockView(),
          ),
        ],
      ),

      // Standalone / Sub-routes
      GoRoute(
        path: '/vehicle/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddVehicleFlowView(),
      ),
      GoRoute(
        path: '/vehicle/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return VehicleDetailView(vehicleId: id);
        },
      ),
      GoRoute(
        path: '/wanted/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddWantedView(),
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsView(),
      ),
      GoRoute(
        path: '/profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DealerProfileView(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsView(),
      ),
    ],
  );
});
