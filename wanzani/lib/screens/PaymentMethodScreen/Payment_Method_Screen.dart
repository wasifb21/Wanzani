import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    Stripe.publishableKey =
        'pk_test_51RPNSXHJxQ3o5bmkxAWEBb7OIUyI28yZOtGUEnYmeYCrTB5z0L04QYPYsrOUOLSlpl0UkMYfvH7v9bUUvRzy7OUD00LqPXEC5a';
  }

  Future<Map<String, dynamic>> _createPaymentIntent(
    String amount,
    String currency,
  ) async {
    const secretKey =
        'sk_test_51RPNSXHJxQ3o5bmkPVbDOtQqszClRMW0UcZGRQwfZgDrCkSGn8x6IO0FY41TNDGX6SIJhubzU5VUbzJ4B0ZXRWnY001dMquCCE';

    final url = Uri.parse('https://api.stripe.com/v1/payment_intents');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $secretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'amount': (int.parse(amount) * 100).toString(), // cents
        'currency': currency,
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return {'clientSecret': body['client_secret']};
    } else {
      throw Exception('Stripe API Error: ${response.body}');
    }
  }

  Future<void> _updatePayment() async {
    setState(() => _loading = true);
    try {
      final data = await _createPaymentIntent('10', 'usd');

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: data['clientSecret'],
          merchantDisplayName: 'Wanzani',
          style: ThemeMode.light,
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            testEnv: true,
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('payment_success'.tr())));
    } on StripeException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${'payment_failed'.tr()}: ${e.error.localizedMessage}',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${'unexpected_error'.tr()}: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'payment_method'.tr(),
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'payment_details'.tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'payment_method'.tr(),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Image.asset('assets/visa_icon.png', width: 40, height: 40),
                    const SizedBox(width: 12),
                    Text(
                      'visa_ending'.tr(args: ['4242']),
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'expires'.tr(args: ['09/25']),
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                const SizedBox(height: 24),
                Text(
                  'billing_address'.tr(),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 12),
                const Text(
                  '123 Main Street',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                const SizedBox(height: 4),
                const Text(
                  'New York, NY 10001',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _updatePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00AEEF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'update_payment'.tr(),
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
