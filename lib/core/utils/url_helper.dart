import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlHelper {
  UrlHelper._();

  /// Launch phone call with sanitized Indian phone number
  static Future<bool> makePhoneCall(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Error launching phone dialer: $e');
    }
    return false;
  }

  /// Launch WhatsApp with prefilled message
  static Future<bool> openWhatsApp({
    required String phoneNumber,
    String? message,
  }) async {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (!cleanNumber.startsWith('91') && cleanNumber.length == 10) {
      cleanNumber = '91$cleanNumber';
    }

    final query = message != null ? '?text=${Uri.encodeComponent(message)}' : '';
    final url = 'https://wa.me/$cleanNumber$query';
    final uri = Uri.parse(url);

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
      return false;
    }
  }
}
