import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shoeshop/services/address_service.dart';
import 'package:shoeshop/widgets/title_text.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  static const routeName = "/AddressScreen";

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAddress();
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

  Future<void> _loadAddress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final saved = await AddressService.loadDefaultAddress(user.uid);
    if (!mounted) {
      return;
    }

    if (saved != null) {
      _firstNameController.text = saved.firstName;
      _lastNameController.text = saved.lastName;
      _phoneController.text = saved.phone;
      _emailController.text = saved.email;
      _addressController.text = saved.address;
      _cityController.text = saved.city;
    } else if ((user.email ?? '').trim().isNotEmpty) {
      _emailController.text = user.email!.trim();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Prijavi se da sacuvas adresu.")),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final address = CheckoutAddress(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
      );
      await AddressService.saveDefaultAddress(user.uid, address);

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Adresa je sacuvana.")));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const TitelesTextWidget(label: "Address")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
          ? const Center(
              child: Text("Prijavi se da bi video i menjao svoju adresu."),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Podaci iz poslednje porudzbine su ovde sacuvani kao podrazumevani za checkout.",
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: _inputDecoration("Ime"),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? "Unesi ime"
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: _inputDecoration("Prezime"),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? "Unesi prezime"
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration("Broj telefona"),
                      validator: (value) {
                        final phone = value?.trim() ?? "";
                        if (phone.isEmpty) {
                          return "Unesi broj telefona";
                        }
                        if (!RegExp(r'^\d+$').hasMatch(phone)) {
                          return "Broj telefona mora da sadrzi samo cifre";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration("Email"),
                      validator: (value) {
                        final email = value?.trim() ?? "";
                        if (email.isEmpty) {
                          return "Unesi email";
                        }
                        if (!RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(email)) {
                          return "Email nije validan";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _addressController,
                      decoration: _inputDecoration("Adresa"),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? "Unesi adresu"
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _cityController,
                      decoration: _inputDecoration("Grad"),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? "Unesi grad"
                          : null,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveAddress,
                        child: Text(
                          _isSaving ? "Cuvanje..." : "Sacuvaj adresu",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
