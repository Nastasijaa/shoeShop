import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shoeshop/consts/stripe_config.dart';

class StripePaymentResult {
  const StripePaymentResult({
    required this.approved,
    this.paymentIntentId,
  });

  final bool approved;
  final String? paymentIntentId;
}

class StripePaymentService {
  const StripePaymentService._();

  static const StripePaymentService instance = StripePaymentService._();

  Future<StripePaymentResult> presentPaymentSheet({
    required int amountInMinorUnit,
    required String currency,
    required String customerEmail,
    required String customerName,
  }) async {
    if (!StripeConfig.isConfigured) {
      throw StateError(StripeConfig.configErrorMessage);
    }
    if (amountInMinorUnit <= 0) {
      throw StateError("Iznos za placanje mora biti veci od 0.");
    }

    final paymentIntentData = await _createPaymentIntent(
      amountInMinorUnit: amountInMinorUnit,
      currency: currency,
      customerEmail: customerEmail,
      customerName: customerName,
    );

    final clientSecret = paymentIntentData['clientSecret'] as String?;
    if (clientSecret == null || clientSecret.isEmpty) {
      throw StateError("Backend nije vratio validan Stripe client secret.");
    }

    final customerId = paymentIntentData['customerId'] as String?;
    final ephemeralKey = paymentIntentData['ephemeralKey'] as String?;
    final paymentIntentId = paymentIntentData['paymentIntentId'] as String?;
    final hasCustomerData =
        customerId != null &&
        customerId.isNotEmpty &&
        ephemeralKey != null &&
        ephemeralKey.isNotEmpty;

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: StripeConfig.merchantDisplayName,
          paymentIntentClientSecret: clientSecret,
          customerId: hasCustomerData ? customerId : null,
          customerEphemeralKeySecret: hasCustomerData ? ephemeralKey : null,
          style: ThemeMode.system,
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      return StripePaymentResult(
        approved: true,
        paymentIntentId: paymentIntentId,
      );
    } on StripeException catch (e) {
      final isCanceled = e.error.code == FailureCode.Canceled;
      if (isCanceled) {
        return const StripePaymentResult(approved: false);
      }
      throw StateError("Stripe greska: ${e.error.localizedMessage ?? e.error.code}");
    } on PlatformException catch (e) {
      final details = e.message ?? e.code;
      throw StateError("Stripe platform greska: $details");
    } catch (e) {
      throw StateError("Neocekivana greska u Stripe placanju: $e");
    }
  }

  Future<Map<String, dynamic>> _createPaymentIntent({
    required int amountInMinorUnit,
    required String currency,
    required String customerEmail,
    required String customerName,
  }) async {
    late final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse(StripeConfig.paymentIntentUrl),
            headers: const {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'amount': amountInMinorUnit,
              'currency': currency.toLowerCase(),
              'customerEmail': customerEmail,
              'customerName': customerName,
            }),
          )
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw StateError(
        "Stripe backend ne odgovara (timeout). Proveri STRIPE_PAYMENT_INTENT_URL.",
      );
    } catch (_) {
      throw StateError(
        "Ne mogu da kontaktiram Stripe backend. Proveri internet i URL endpoint-a.",
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String backendMessage = '';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final errorMessage = decoded['error'];
          if (errorMessage is String) {
            backendMessage = errorMessage;
          }
        }
      } catch (_) {}
      throw StateError(
        backendMessage.isNotEmpty
            ? "Backend greska (${response.statusCode}): $backendMessage"
            : "Backend greska pri kreiranju Stripe naplate (${response.statusCode}).",
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw StateError("Neocekivan odgovor backend-a za Stripe naplatu.");
    }
    return decoded;
  }
}
