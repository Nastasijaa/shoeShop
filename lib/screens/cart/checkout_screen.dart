import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shoeshop/consts/app_colors.dart';
import 'package:shoeshop/consts/stripe_config.dart';
import 'package:shoeshop/providers/cart_provider.dart';
import 'package:shoeshop/screens/inner_screen/orders/orders_screen.dart';
import 'package:shoeshop/services/address_service.dart';
import 'package:shoeshop/services/product_integrity_service.dart';
import 'package:shoeshop/services/stock_service.dart';
import 'package:shoeshop/services/stripe_payment_service.dart';
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
  bool _isPlacingOrder = false;
  bool _isPrefillingAddress = true;

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  bool _isPermissionDenied(Object e) {
    return e is FirebaseException && e.code == "permission-denied";
  }

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

  Future<void> _loadDefaultAddress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isPrefillingAddress = false;
      });
      return;
    }

    try {
      final savedAddress = await AddressService.loadDefaultAddress(
        user.uid,
      ).timeout(const Duration(seconds: 5));
      if (!mounted) {
        return;
      }

      if (savedAddress != null) {
        _firstNameController.text = savedAddress.firstName;
        _lastNameController.text = savedAddress.lastName;
        _phoneController.text = savedAddress.phone;
        _emailController.text = savedAddress.email;
        _addressController.text = savedAddress.address;
        _cityController.text = savedAddress.city;
      } else if ((user.email ?? '').trim().isNotEmpty) {
        _emailController.text = user.email!.trim();
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      if ((user.email ?? '').trim().isNotEmpty &&
          _emailController.text.trim().isEmpty) {
        _emailController.text = user.email!.trim();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPrefillingAddress = false;
        });
      }
    }
  }

  CheckoutAddress _addressFromForm() {
    return CheckoutAddress(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.lightCardColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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

  String _friendlyErrorMessage(Object error) {
    if (error is StateError) {
      return error.message;
    }
    final raw = error.toString();
    if (raw.trim().isNotEmpty) {
      return "Greska pri placanju: $raw";
    }
    return "Greska pri placanju. Pokusaj ponovo.";
  }

  int _toMinorCurrencyUnit(double amount) {
    return (amount * 100).round();
  }

  void _showInvalidDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Neispravan unos"),
          content: const Text("Proveri format emaila, pokusaj ponovo."),
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

  Future<void> _submitPayment() async {
    final isFormValid = _formKey.currentState!.validate();
    if (!isFormValid) {
      if (_allFieldsFilled() &&
          (!_isEmailValid(_emailController.text) ||
              !_isPhoneValid(_phoneController.text))) {
        _showInvalidDialog();
      }
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Prijavi se da bi izvrsio placanje.")),
      );
      return;
    }

    try {
      await ProductIntegrityService.syncMissingProducts(
        context,
      ).timeout(const Duration(seconds: 5));
      if (!mounted) {
        return;
      }
    } catch (_) {
      // Ne blokiraj placanje ako integrity sync ne uspe.
    }
    final cartProvider = context.read<CartProvider>();
    if (cartProvider.itemCount == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Korpa je prazna.")));
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    final discountAmount = cartProvider.discountAmount;
    final totalBeforeDiscount = cartProvider.totalPrice;
    final totalAfterDiscount = cartProvider.discountedTotalPrice;
    final subtotal = discountAmount > 0
        ? totalAfterDiscount
        : totalBeforeDiscount;
    final shippingCost = subtotal >= _freeShippingThreshold || subtotal == 0
        ? 0.0
        : _shippingFee;
    final grandTotal = subtotal + shippingCost;

    try {
      final stripeResult = await StripePaymentService.instance.presentPaymentSheet(
        amountInMinorUnit: _toMinorCurrencyUnit(grandTotal),
        currency: "RSD",
        customerEmail: _emailController.text.trim(),
        customerName:
            "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}",
      );
      if (!stripeResult.approved) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Placanje je otkazano.")));
        return;
      }

      final now = FieldValue.serverTimestamp();
      final orderId = FirebaseFirestore.instance.collection("orders").doc().id;
      final orderRef = FirebaseFirestore.instance
          .collection("orders")
          .doc(orderId);
      final userOrderRef = FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("orders")
          .doc(orderId);
      final cartItems = cartProvider.items.values.toList(growable: false);

      final items = cartItems
          .map(
            (item) => {
              "cartItemId": item.id,
              "productId": item.productId,
              "title": item.title,
              "description": item.description ?? "",
              "imageUrl": item.imageUrl,
              "size": item.size,
              "quantity": item.quantity,
              "price": item.price,
              "lineTotal": item.price * item.quantity,
            },
          )
          .toList(growable: false);

      final orderData = {
        "orderNumber": orderId.substring(0, 8).toUpperCase(),
        "orderId": orderId,
        "userId": user.uid,
        "userEmail": user.email ?? _emailController.text.trim(),
        "customerFirstName": _firstNameController.text.trim(),
        "customerLastName": _lastNameController.text.trim(),
        "customerFullName":
            "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}",
        "phone": _phoneController.text.trim(),
        "email": _emailController.text.trim(),
        "address": _addressController.text.trim(),
        "city": _cityController.text.trim(),
        "paymentProvider": "stripe",
        "paymentStatus": "paid",
        "paymentMode": StripeConfig.isLiveMode ? "live" : "test",
        "paymentIntentId": stripeResult.paymentIntentId ?? "",
        "orderStatus": "primljen",
        "currency": "RSD",
        "subtotal": subtotal,
        "discountAmount": discountAmount,
        "shippingCost": shippingCost,
        "grandTotal": grandTotal,
        "itemCount": cartProvider.itemCount,
        "totalQuantity": cartProvider.totalQuantity,
        "items": items,
        "createdAt": now,
        "updatedAt": now,
      };

      var writeSucceeded = false;

      // Try persist in user's scope first.
      try {
        await userOrderRef.set(orderData, SetOptions(merge: true));
        writeSucceeded = true;
      } catch (e) {
        if (!_isPermissionDenied(e)) {
          rethrow;
        }
      }

      // Mirror to top-level orders for admin overview when rules allow it.
      try {
        await orderRef.set(orderData, SetOptions(merge: true));
        writeSucceeded = true;
      } catch (e) {
        if (!_isPermissionDenied(e)) {
          rethrow;
        }
      }

      if (!writeSucceeded) {
        throw StateError(
          "Nemate dozvolu za cuvanje porudzbine. Proveri Firestore rules.",
        );
      }

      // Stock update should not break successful payment/order flow.
      try {
        await StockService.decreaseStockForOrder(cartItems);
      } catch (e) {
        if (!_isPermissionDenied(e)) {
          debugPrint("Stock update skipped: $e");
        }
      }

      await AddressService.saveDefaultAddress(user.uid, _addressFromForm());

      cartProvider.clear();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Uplata uspesna. Porudzbina je kreirana."),
        ),
      );
      Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName);
    } catch (e) {
      debugPrint("Checkout payment error: $e");
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_friendlyErrorMessage(e))));
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final discountAmount = cartProvider.discountAmount;
    final totalBeforeDiscount = cartProvider.totalPrice;
    final totalAfterDiscount = cartProvider.discountedTotalPrice;
    final subtotal = discountAmount > 0
        ? totalAfterDiscount
        : totalBeforeDiscount;
    final shippingCost = subtotal >= _freeShippingThreshold || subtotal == 0
        ? 0
        : _shippingFee;
    final grandTotal = subtotal + shippingCost;
    return Scaffold(
      appBar: AppBar(title: const TitelesTextWidget(label: "Checkout")),
      body: SafeArea(
        child: _isPrefillingAddress
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
                          onPressed: _isPlacingOrder ? null : _submitPayment,
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
                          child: Text(
                            _isPlacingOrder ? "Kreiranje..." : "Pay online",
                          ),
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
