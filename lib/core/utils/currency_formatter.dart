import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _indianFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  /// Formats amount in full Indian numbering format: e.g. ₹11,40,000
  static String formatRupees(num amount) {
    return _indianFormatter.format(amount);
  }

  /// Compact Indian format: e.g. ₹11.4 L or ₹85 K or ₹1.2 Cr
  static String formatCompact(num amount) {
    if (amount >= 10000000) {
      final cr = amount / 10000000;
      return '₹${cr.toStringAsFixed(cr.truncateToDouble() == cr ? 0 : 2)} Cr';
    } else if (amount >= 100000) {
      final lakh = amount / 100000;
      return '₹${lakh.toStringAsFixed(lakh.truncateToDouble() == lakh ? 0 : 1)} Lakh';
    } else if (amount >= 1000) {
      final k = amount / 1000;
      return '₹${k.toStringAsFixed(0)}K';
    }
    return '₹$amount';
  }

  /// Formats kilometers with comma separation, e.g. "42,000 km"
  static String formatKm(int km) {
    final formatter = NumberFormat('#,##,###');
    return '${formatter.format(km)} km';
  }
}
