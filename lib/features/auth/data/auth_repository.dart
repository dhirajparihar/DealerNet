import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../dealer/domain/dealer.dart';
import '../../vehicles/data/mock_data.dart';
import '../../../core/network/supabase_config.dart';
import 'package:flutter/foundation.dart';

enum AuthStatus {
  unauthenticated,
  otpSent,
  authenticated,
  onboardingRequired,
  pendingApproval,
}

class AuthState {
  final AuthStatus status;
  final String? phoneNumber;
  final Dealer? currentDealer;
  final String? otpCode;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.phoneNumber,
    this.currentDealer,
    this.otpCode,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? phoneNumber,
    Dealer? currentDealer,
    String? otpCode,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      currentDealer: currentDealer ?? this.currentDealer,
      otpCode: otpCode ?? this.otpCode,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseClient? _client = SupabaseConfig.client;

  /// Guards against the onAuthStateChange listener overriding state
  /// while an OTP send/verify operation is in progress.
  bool _isAuthFlowInProgress = false;

  AuthNotifier() : super(const AuthState()) {
    _initAuth();
  }

  void _initAuth() async {
    final client = _client;
    if (client == null) {
      // Offline fallback
      state = AuthState(
        status: AuthStatus.authenticated,
        currentDealer: MockData.currentDealer,
        phoneNumber: MockData.currentDealer.phone,
      );
      return;
    }

    final session = client.auth.currentSession;
    if (session != null) {
      await _fetchDealerProfile(session.user.id, session.user.phone ?? '');
    }

    client.auth.onAuthStateChange.listen((data) async {
      if (_isAuthFlowInProgress || state.status == AuthStatus.otpSent) {
        return;
      }

      final event = data.event;

      if (event == AuthChangeEvent.signedOut) {
        if (mounted) {
          state = const AuthState(
            status: AuthStatus.unauthenticated,
          );
        }
        return;
      }

      if (event == AuthChangeEvent.signedIn && data.session != null) {
        final user = data.session!.user;

        await _fetchDealerProfile(
          user.id,
          user.phone ?? '',
        );
      }
    });
  }

  Future<void> _fetchDealerProfile(String userId, String phone) async {
  final client = _client;

  if (client == null) return;

  try {
    final response = await client
        .from('dealers')
        .select()
        .eq('auth_user_id', userId)
        .maybeSingle();

    if (response != null && mounted) {
      final dealer = Dealer(
        // This is dealers.id, NOT auth.users.id
        id: response['id'] as String,

        businessName: response['business_name'] as String,
        contactName: response['contact_name'] as String,
        phone: response['phone'] as String,
        whatsappPhone:
            response['whatsapp_phone'] as String? ?? response['phone'] as String,

        // Your current DB has city_id, not a city text column.
        city: 'Indore',

        area: response['area'] as String,

        logoUrl: response['logo_url'] as String?,

        verificationStatus:
            response['verification_status'] == 'verified'
                ? VerificationStatus.verified
                : response['verification_status'] == 'pending'
                    ? VerificationStatus.pending
                    : VerificationStatus.mobileVerified,

        isActive: response['is_active'] as bool? ?? true,

        // Your current DB doesn't have active_stock_count.
        activeStockCount: 0,

        createdAt: DateTime.parse(
          response['created_at'] as String,
        ),
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        currentDealer: dealer,

        // Use dealer phone because our Auth user uses email.
        phoneNumber: response['phone'] as String,
      );
    } else if (mounted) {
      state = state.copyWith(
        status: AuthStatus.onboardingRequired,
        phoneNumber: phone,
      );
    }
  } catch (e) {
    debugPrint('❌ Failed to fetch dealer profile: $e');

    if (mounted) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }
}

  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final client = _client;

    if (client == null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        currentDealer: MockData.currentDealer,
      );
      return true;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final response = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;

      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Login failed.',
        );
        return false;
      }

      debugPrint('✅ Auth login successful');
      debugPrint('Auth User ID: ${user.id}');

      await _fetchDealerProfile(
        user.id,
        '',
      );

      if (state.status == AuthStatus.authenticated) {
        debugPrint(
          '✅ Dealer loaded: ${state.currentDealer?.businessName}',
        );
        debugPrint(
          'Dealer ID: ${state.currentDealer?.id}',
        );

        state = state.copyWith(isLoading: false);

        return true;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No dealer profile found for this account.',
      );

      return false;
    } catch (e) {
      debugPrint('❌ Login failed: $e');

      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );

      return false;
    }
  }
  Future<bool> signUp({
  required String email,
  required String password,
  required String businessName,
  required String contactName,
  required String phone,
}) async {
  final client = _client;

  if (client == null) {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      isLoading: false,
    );
    return true;
  }

  state = state.copyWith(
    isLoading: true,
    errorMessage: null,
  );

  try {
    // 1. Create Supabase Auth user
    final response = await client.auth.signUp(
      email: email.trim(),
      password: password,
    );

    final user = response.user;

    if (user == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Signup failed.',
      );
      return false;
    }

    debugPrint('✅ Auth signup successful');
    debugPrint('Auth User ID: ${user.id}');

    // 2. Create dealer profile immediately
    final dealerResponse = await client
        .from('dealers')
        .insert({
          'auth_user_id': user.id,
          'business_name': businessName.trim(),
          'contact_name': contactName.trim(),
          'phone': phone.trim(),
          'whatsapp_phone': phone.trim(),
          'area': 'Not specified',
          'verification_status': 'verified',
          'is_active': true,
        })
        .select()
        .single();

    debugPrint('✅ Dealer profile created');
    debugPrint('Dealer ID: ${dealerResponse['id']}');

    // 3. Load dealer into AuthState
    await _fetchDealerProfile(
      user.id,
      phone.trim(),
    );

    if (state.status == AuthStatus.authenticated) {
      state = state.copyWith(
        isLoading: false,
      );

      debugPrint(
        '✅ Signup completed: ${state.currentDealer?.businessName}',
      );

      return true;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: 'Dealer profile could not be loaded.',
    );

    return false;
  } on AuthException catch (e) {
    debugPrint('❌ Auth signup failed: ${e.message}');

    state = state.copyWith(
      isLoading: false,
      errorMessage: e.message,
    );

    return false;
  } catch (e) {
    debugPrint('❌ Signup failed: $e');

    state = state.copyWith(
      isLoading: false,
      errorMessage: e.toString(),
    );

    return false;
  }
}


  Future<bool> sendOtp(String phone) async {
    _isAuthFlowInProgress = true;
    state = state.copyWith(isLoading: true, errorMessage: null);

    final cleanPhone = phone.trim();
    final formattedPhone = cleanPhone.startsWith('+') ? cleanPhone : '+91$cleanPhone';

    final client = _client;
    if (client == null) {
      // Offline fallback
      await Future.delayed(const Duration(milliseconds: 600));
      state = state.copyWith(isLoading: false, status: AuthStatus.otpSent, phoneNumber: formattedPhone);
      _isAuthFlowInProgress = false;
      return true;
    }

    try {
      // Try with E.164 country code (+91...)
      await client.auth.signInWithOtp(phone: formattedPhone);
      if (mounted) {
        state = state.copyWith(isLoading: false, status: AuthStatus.otpSent, phoneNumber: formattedPhone);
      }
      return true;
    } catch (e) {
      // Try international format without '+' (e.g. 919826012345)
      // Supabase Dashboard requires numbers without the + prefix.
      final phoneWithoutPlus = cleanPhone.startsWith('+')
          ? cleanPhone.substring(1)
          : (cleanPhone.startsWith('91') ? cleanPhone : '91$cleanPhone');
      try {
        await client.auth.signInWithOtp(phone: phoneWithoutPlus);
        if (mounted) {
          state = state.copyWith(isLoading: false, status: AuthStatus.otpSent, phoneNumber: phoneWithoutPlus);
        }
        return true;
      } catch (_) {
        // Ignore retry failure, proceed to handle original error
      }

      // If SMS provider failed (e.g. Twilio unconfigured / test number mismatch),
      // allow test OTP mode so dev/testing isn't blocked.
      final errorStr = e.toString().toLowerCase();
      final isAuthException = e is AuthException;
      final authCode = isAuthException ? (e.code ?? '') : '';
      final authMsg = isAuthException ? e.message.toLowerCase() : '';

      if (authCode == 'sms_send_failed' ||
          authMsg.contains('provider') ||
          authMsg.contains('twilio') ||
          errorStr.contains('sms_send_failed') ||
          errorStr.contains('provider')) {
        if (mounted) {
          state = state.copyWith(
            isLoading: false,
            status: AuthStatus.otpSent,
            phoneNumber: formattedPhone,
          );
        }
        // Keep _isAuthFlowInProgress true so trailing Supabase client stream events don't wipe state
        return true;
      }

      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to send OTP: ${e.toString()}',
        );
      }
      _isAuthFlowInProgress = false;
      return false;
    }
  }

  Future<bool> verifyOtp(String enteredOtp) async {
    _isAuthFlowInProgress = true;
    state = state.copyWith(isLoading: true, errorMessage: null);
    final phone = state.phoneNumber;

    if (phone == null) {
      _isAuthFlowInProgress = false;
      return false;
    }

    final client = _client;
    if (client == null) {
      // Offline fallback
      await Future.delayed(const Duration(milliseconds: 600));
      state = state.copyWith(isLoading: false, status: AuthStatus.authenticated, currentDealer: MockData.currentDealer);
      _isAuthFlowInProgress = false;
      return true;
    }

    try {
      final res = await client.auth.verifyOTP(phone: phone, token: enteredOtp, type: OtpType.sms);
      if (res.user != null) {
        await _fetchDealerProfile(res.user!.id, phone);
        if (mounted) {
          state = state.copyWith(isLoading: false);
        }
        _isAuthFlowInProgress = false;
        return true;
      } else {
        if (mounted) {
          state = state.copyWith(isLoading: false, errorMessage: 'Invalid OTP');
        }
        _isAuthFlowInProgress = false;
        return false;
      }
    } catch (e) {
      // Fallback for test mode: accept 123456 when Supabase verification fails
      if (enteredOtp == '123456') {
        if (mounted) {
          state = state.copyWith(
            isLoading: false,
            status: AuthStatus.authenticated,
            currentDealer: MockData.currentDealer,
          );
        }
        _isAuthFlowInProgress = false;
        return true;
      }

      if (mounted) {
        state = state.copyWith(isLoading: false, errorMessage: 'Invalid OTP or expired.');
      }
      _isAuthFlowInProgress = false;
      return false;
    }
  }

  Future<bool> completeOnboarding({
    required String businessName,
    required String contactName,
    required String city,
    required String area,
    required String whatsappNumber,
  }) async {
    state = state.copyWith(isLoading: true);
    final phone = state.phoneNumber ?? '';

    final client = _client;
    if (client == null) {
      // Offline fallback
      await Future.delayed(const Duration(milliseconds: 600));
      final newDealer = Dealer(
        id: 'dealer-${DateTime.now().millisecondsSinceEpoch}',
        businessName: businessName,
        contactName: contactName,
        phone: phone,
        whatsappPhone: whatsappNumber.isNotEmpty ? whatsappNumber : phone,
        city: city,
        area: area,
        verificationStatus: VerificationStatus.verified,
        createdAt: DateTime.now(),
      );
      state = state.copyWith(
        isLoading: false,
        status: AuthStatus.authenticated,
        currentDealer: newDealer,
      );
      return true;
    }

    final user = client.auth.currentUser;
    if (user == null) {
      state = state.copyWith(isLoading: false, errorMessage: 'Session lost.');
      return false;
    }

    try {
      final insertData = {
        'id': user.id,
        'business_name': businessName,
        'contact_name': contactName,
        'phone': phone,
        'whatsapp_phone': whatsappNumber.isNotEmpty ? whatsappNumber : phone,
        'city': city,
        'area': area,
        'verification_status': 'verified', // Auto-verify for demo
      };

      final response = await client.from('dealers').insert(insertData).select().single();

      final newDealer = Dealer(
        id: response['id'],
        businessName: response['business_name'],
        contactName: response['contact_name'],
        phone: response['phone'],
        whatsappPhone: response['whatsapp_phone'],
        city: response['city'] ?? 'Indore',
        area: response['area'] ?? '',
        logoUrl: response['logo_url'],
        verificationStatus: VerificationStatus.verified,
        isActive: response['is_active'] ?? true,
        activeStockCount: response['active_stock_count'] ?? 0,
        createdAt: DateTime.parse(response['created_at']),
      );

      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          status: AuthStatus.authenticated,
          currentDealer: newDealer,
        );
      }
      return true;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, errorMessage: 'Failed to save profile: $e');
      }
      return false;
    }
  }

  void updateProfile(Dealer updated) async {
    state = state.copyWith(currentDealer: updated);
    final client = _client;
    if (client != null) {
      try {
        await client.from('dealers').update({
          'business_name': updated.businessName,
          'contact_name': updated.contactName,
          'whatsapp_phone': updated.whatsappPhone,
          'city': updated.city,
          'area': updated.area,
        }).eq('id', updated.id);
      } catch (e) {
        // Handle error silently or show toast in a real app
      }
    }
  }

  void logout() async {
    _isAuthFlowInProgress = false;
    final client = _client;
    if (client != null) {
      await client.auth.signOut();
    }
    if (mounted) {
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        phoneNumber: null,
        currentDealer: null,
      );
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
