import 'package:flutter/foundation.dart';

class StripeConfig {
  const StripeConfig._();

  // Stripe publishable key (pk_test_... or pk_live_...).
  static const String _publishableKeyPrimary = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: String.fromEnvironment(
      'STRIPE_PUBLISHABLEKEY',
      defaultValue: String.fromEnvironment('STRIPE_PK', defaultValue: ''),
    ),
  );
  static String get publishableKey => _publishableKeyPrimary.trim();

  // iOS merchant identifier (required on iOS for Apple Pay).
  static const String merchantIdentifier = String.fromEnvironment(
    'STRIPE_MERCHANT_IDENTIFIER',
    defaultValue: 'merchant.com.example.shoeshop',
  );

  // Backend endpoint that creates PaymentIntent and returns client secret.
  static const String _paymentIntentUrlPrimary = String.fromEnvironment(
    'STRIPE_PAYMENT_INTENT_URL',
    defaultValue: String.fromEnvironment(
      'PAYMENT_INTENT_URL',
      defaultValue: '',
    ),
  );

  static const String _backendBaseUrl = String.fromEnvironment(
    'STRIPE_BACKEND_BASE_URL',
    defaultValue: String.fromEnvironment('BACKEND_BASE_URL', defaultValue: ''),
  );

  static const String _defaultDevUrl = String.fromEnvironment(
    'STRIPE_LOCAL_PAYMENT_INTENT_URL',
    defaultValue: 'http://10.0.2.2:8787/payment-intent',
  );

  static const String _stockUpdateUrlPrimary = String.fromEnvironment(
    'STRIPE_STOCK_UPDATE_URL',
    defaultValue: '',
  );

  static const String _defaultDevStockUrl = String.fromEnvironment(
    'STRIPE_LOCAL_STOCK_UPDATE_URL',
    defaultValue: 'http://10.0.2.2:8787/decrease-stock',
  );

  static String get paymentIntentUrl {
    final direct = _paymentIntentUrlPrimary.trim();
    if (direct.isNotEmpty) {
      return direct;
    }
    final base = _backendBaseUrl.trim();
    if (base.isNotEmpty) {
      final sanitized = base.endsWith('/')
          ? base.substring(0, base.length - 1)
          : base;
      return '$sanitized/payment-intent';
    }
    if (!kReleaseMode) {
      return _defaultDevUrl;
    }
    return '';
  }

  static String get stockUpdateUrl {
    final direct = _stockUpdateUrlPrimary.trim();
    if (direct.isNotEmpty) {
      return direct;
    }
    final base = _backendBaseUrl.trim();
    if (base.isNotEmpty) {
      final sanitized = base.endsWith('/')
          ? base.substring(0, base.length - 1)
          : base;
      return '$sanitized/decrease-stock';
    }
    final paymentUrl = _paymentIntentUrlPrimary.trim();
    if (paymentUrl.isNotEmpty && paymentUrl.endsWith('/payment-intent')) {
      return paymentUrl.replaceFirst('/payment-intent', '/decrease-stock');
    }
    if (!kReleaseMode) {
      return _defaultDevStockUrl;
    }
    return '';
  }

  static String get configErrorMessage {
    if (publishableKey.isEmpty) {
      return "Nedostaje STRIPE_PUBLISHABLE_KEY (pk_test_...).";
    }
    if (!publishableKey.startsWith('pk_')) {
      return "Neispravan Stripe publishable key. Koristi pk_test_... ili pk_live_....";
    }
    if (paymentIntentUrl.isEmpty) {
      return "Nedostaje STRIPE_PAYMENT_INTENT_URL.";
    }
    return "Stripe nije konfigurisan.";
  }

  static const String merchantDisplayName = 'ShoeShop';

  static bool get hasValidPublishableKey =>
      publishableKey.isNotEmpty && publishableKey.startsWith('pk_');

  static bool get hasPaymentIntentUrl => paymentIntentUrl.isNotEmpty;

  static bool get isConfigured => hasValidPublishableKey && hasPaymentIntentUrl;

  static bool get isLiveMode => publishableKey.startsWith('pk_live_');
}
