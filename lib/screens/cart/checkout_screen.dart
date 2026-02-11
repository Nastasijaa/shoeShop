import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoeshop/consts/app_colors.dart';
import 'package:shoeshop/providers/cart_provider.dart';
import 'package:shoeshop/widgets/subtitle_text.dart';
import 'package:shoeshop/widgets/title_text.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  static const routeName = "/CheckoutScreen";

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const double _freeShippingThreshold = 20000;
  static const double _shippingFee = 400;
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.lightCardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightPrimary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkPrimary, width: 1.5),
      ),
    );
  }

  bool _allFieldsFilled() {
    return _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _addressController.text.trim().isNotEmpty &&
        _cityController.text.trim().isNotEmpty;
  }

  bool _isEmailValid(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
  }

  bool _isPhoneValid(String value) {
    return RegExp(r'^\d+$').hasMatch(value.trim());
  }

  void _showInvalidDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Neispravan unos"),
          content: const Text(
            "Proveri format emaila, pokusaj ponovo.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("U redu"),
            ),
          ],
        );
      },
    );
  }

  void _submitPayment() {
    final isFormValid = _formKey.currentState!.validate();
    if (!isFormValid) {
      if (_allFieldsFilled() &&
          (!_isEmailValid(_emailController.text) ||
              !_isPhoneValid(_phoneController.text))) {
        _showInvalidDialog();
      }
      return;
    }
    // Placeholder for payment API integration.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Payment API "),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final discountAmount = cartProvider.discountAmount;
    final totalBeforeDiscount = cartProvider.totalPrice;
    final totalAfterDiscount = cartProvider.discountedTotalPrice;
    final subtotal =
        discountAmount > 0 ? totalAfterDiscount : totalBeforeDiscount;
    final shippingCost =
        subtotal >= _freeShippingThreshold || subtotal == 0 ? 0 : _shippingFee;
    final grandTotal = subtotal + shippingCost;
    return Scaffold(
      appBar: AppBar(
        title: const TitelesTextWidget(label: "Checkout"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TitelesTextWidget(label: "Billing details"),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _firstNameController,
                  decoration: _inputDecoration("Ime"),
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Unesi ime";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _lastNameController,
                  decoration: _inputDecoration("Prezime"),
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Unesi prezime";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  decoration: _inputDecoration("Broj telefona"),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Unesi broj telefona";
                    }
                    if (!_isPhoneValid(value)) {
                      return "Broj telefona mora da sadrzi samo cifre";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  decoration: _inputDecoration("Email"),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Unesi email";
                    }
                    if (!_isEmailValid(value)) {
                      return "Email nije validan";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _addressController,
                  decoration: _inputDecoration("Adresa"),
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Unesi adresu";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _cityController,
                  decoration: _inputDecoration("Grad"),
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Unesi grad";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SubtitleTextWidget(
                        label: "Bex kurirska sluzba",
                        fontWeight: FontWeight.w700,
                      ),
                      const SizedBox(height: 2),
                      const SubtitleTextWidget(
                        label: "Isporuka za 2-3 dana.",
                      ),
                      const SizedBox(height: 2),
                      SubtitleTextWidget(
                        label: subtotal >= _freeShippingThreshold
                            ? "Postarina: Besplatna za iznos iznad 20000 RSD."
                            : "Postarina: 400 RSD za iznos ispod 20000 RSD.",
                        color: AppColors.darkPrimary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        child: TitelesTextWidget(
                          label:
                              "Total (${cartProvider.itemCount} products/${cartProvider.totalQuantity} items)",
                        ),
                      ),
                      if (discountAmount > 0)
                        SubtitleTextWidget(
                          label:
                              "Discount -${discountAmount.toStringAsFixed(2)} RSD",
                          color: Colors.green,
                        ),
                      SubtitleTextWidget(
                        label:
                            "Postarina ${shippingCost.toStringAsFixed(2)} RSD",
                      ),
                      SubtitleTextWidget(
                        label: "${grandTotal.toStringAsFixed(2)} RSD",
                        color: AppColors.darkPrimary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    child: const Text("Pay online"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
