import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// Initializes Supabase if credentials are provided
  static Future<void> initialize() async {
    if (url.isNotEmpty && anonKey.isNotEmpty) {
      try {
        await Supabase.initialize(
          url: url,
          anonKey: anonKey, // ignore: deprecated_member_use
        );
        _isInitialized = true;
        debugPrint('Supabase connected successfully to $url');
      } catch (e) {
        debugPrint('Supabase initialization failed: $e');
        _isInitialized = false;
      }
    } else {
      debugPrint(
        'Supabase credentials not set. Running in offline/demo mode with Riverpod in-memory state.',
      );
    }
  }

  static SupabaseClient? get client {
    if (_isInitialized) {
      return Supabase.instance.client;
    }
    return null;
  }
}
