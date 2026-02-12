import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shoeshop/consts/app_colors.dart';
import 'package:shoeshop/consts/app_constants.dart';
import 'package:shoeshop/screens/admin/admin_products_manage_screen.dart';
import 'package:shoeshop/screens/inner_screen/orders/orders_screen.dart';
import 'package:shoeshop/widgets/subtitle_text.dart';
import 'package:shoeshop/widgets/title_text.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  static const routeName = "/AdminDashboardScreen";

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();
  XFile? _pickedImage;
  String? _existingImageUrl;
  bool _isSaving = false;

  final Set<String> _selectedGenders = {};
  final Set<String> _selectedTypes = {};
  final Set<String> _selectedColors = {};
  final Set<String> _selectedMaterials = {};

  late final Map<int, TextEditingController> _sizeControllers;
  String? _selectedProductId;
  bool _isEditMode = false;
  bool _didReadRouteArgs = false;

  @override
  void initState() {
    super.initState();
    _sizeControllers = {
      for (final size in _sizes) size: TextEditingController(text: "0"),
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didReadRouteArgs) {
      return;
    }
    _didReadRouteArgs = true;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && arg.isNotEmpty) {
      _selectedProductId = arg;
      _loadProductForEdit(arg);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    for (final controller in _sizeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  List<int> get _sizes {
    if (_selectedGenders.contains("men")) {
      return [41, 42, 43, 44, 45, 46];
    }
    if (_selectedGenders.contains("women")) {
      return [36, 37, 38, 39, 40, 41];
    }
    return List.generate(13, (index) => 36 + index);
  }

  List<String> get _availableTypes {
    if (_selectedGenders.contains("men")) {
      return const ["flat", "sneakers"];
    }
    return AppConstants.filterTypes;
  }

  void _syncSizeControllers() {
    final sizes = _sizes;
    // Add missing controllers.
    for (final size in sizes) {
      _sizeControllers.putIfAbsent(
        size,
        () => TextEditingController(text: "0"),
      );
    }
    // Keep existing controllers for hidden sizes and dispose everything in
    // screen dispose(). This avoids disposing a controller still bound to an
    // active TextFormField during rebuild transitions.
  }

  void _prepareForNewProduct() {
    _titleController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _pickedImage = null;
    _existingImageUrl = null;
    _selectedGenders.clear();
    _selectedTypes.clear();
    _selectedColors.clear();
    _selectedMaterials.clear();
    for (final controller in _sizeControllers.values) {
      controller.text = "0";
    }
    _syncSizeControllers();
    _isEditMode = false;
  }

  Future<void> _loadProductForEdit(String productId) async {
    final doc = await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .get();
    if (!mounted) {
      return;
    }
    if (!doc.exists) {
      _showSnackBar("Proizvod nije pronadjen.");
      return;
    }
    final data = doc.data() ?? {};
    final gender = (data['gender'] as String?) ?? '';
    final type = (data['type'] as String?) ?? '';
    final color = (data['color'] as String?) ?? '';
    final material = (data['material'] as String?) ?? '';
    final title = (data['title'] as String?) ?? '';
    final description = (data['description'] as String?) ?? '';
    final price = (data['price'] as num?)?.toString() ?? '';

    final stocksSnap = await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .collection('stocks')
        .get();
    if (!mounted) {
      return;
    }

    setState(() {
      _titleController.text = title;
      _descriptionController.text = description;
      _priceController.text = price;
      _existingImageUrl = data['imageUrl'] as String?;
      _pickedImage = null;

      _selectedGenders
        ..clear()
        ..addAll(gender.isNotEmpty ? [gender] : []);
      _selectedTypes
        ..clear()
        ..addAll(type.isNotEmpty ? [type] : []);
      _selectedColors
        ..clear()
        ..addAll(color.isNotEmpty ? [color] : []);
      _selectedMaterials
        ..clear()
        ..addAll(material.isNotEmpty ? [material] : []);

      _syncSizeControllers();
      for (final controller in _sizeControllers.values) {
        controller.text = "0";
      }
      for (final stock in stocksSnap.docs) {
        final size = int.tryParse(stock.id);
        if (size != null) {
          final qty = stock.data()['qty'];
          final controller = _sizeControllers.putIfAbsent(
            size,
            () => TextEditingController(text: "0"),
          );
          controller.text = qty?.toString() ?? "0";
        }
      }

      _isEditMode = true;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _imagePicker.pickImage(source: source);
    if (image == null) {
      return;
    }
    setState(() {
      _pickedImage = image;
    });
  }

  void _showImagePickerSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TitelesTextWidget(label: "Dodaj sliku proizvoda"),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Kamera (uzivo)"),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text("Galerija"),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePickerSection() {
    final hasExistingImage =
        _existingImageUrl != null && _existingImageUrl!.trim().isNotEmpty;
    final existingImage = _existingImageUrl?.trim() ?? "";
    final isNetworkImage =
        existingImage.startsWith("http://") || existingImage.startsWith("https://");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TitelesTextWidget(
          label: "Slika proizvoda",
          color: AppColors.darkPrimary,
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.darkPrimary.withOpacity(0.15),
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _pickedImage == null
                      ? (!hasExistingImage
                          ? Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withOpacity(0.6),
                              child: const Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 48,
                                  color: AppColors.darkPrimary,
                                ),
                              ),
                            )
                          : isNetworkImage
                              ? Image.network(
                                  existingImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surface
                                          .withOpacity(0.6),
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image_outlined,
                                          size: 48,
                                          color: AppColors.darkPrimary,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Image.file(
                                  File(existingImage),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surface
                                          .withOpacity(0.6),
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image_outlined,
                                          size: 48,
                                          color: AppColors.darkPrimary,
                                        ),
                                      ),
                                    );
                                  },
                                ))
                      : Image.file(
                          File(_pickedImage!.path),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Galerija"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkPrimary,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Kamera"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _saveProduct() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    if (_selectedGenders.isEmpty ||
        _selectedTypes.isEmpty ||
        _selectedColors.isEmpty ||
        _selectedMaterials.isEmpty) {
      _showSnackBar("Izaberi pol, tip, boju i materijal.");
      return;
    }
    if (_pickedImage == null &&
        (_existingImageUrl == null || _existingImageUrl!.trim().isEmpty)) {
      _showSnackBar("Dodaj sliku proizvoda.");
      return;
    }
    final hasAnyQuantity = _sizes.any((size) {
      final controller = _sizeControllers[size];
      final qty = int.tryParse(controller?.text.trim() ?? "0") ?? 0;
      return qty > 0;
    });
    if (!hasAnyQuantity) {
      _showSnackBar("Unesi kolicinu za bar jedan broj.");
      return;
    }
    setState(() {
      _isSaving = true;
    });
    try {
      final isUpdate = _isEditMode && _selectedProductId != null;
      final docRef = isUpdate
          ? FirebaseFirestore.instance
              .collection('products')
              .doc(_selectedProductId)
          : FirebaseFirestore.instance.collection('products').doc();

      String? imageUrl = _existingImageUrl;
      if (_pickedImage != null) {
        imageUrl = _pickedImage!.path;
      }

      final data = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'gender': _selectedGenders.first,
        'type': _selectedTypes.first,
        'color': _selectedColors.first,
        'material': _selectedMaterials.first,
        'imageUrl': imageUrl ?? '',
        'imagePath': imageUrl ?? '',
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
        if (!isUpdate) 'createdAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(data, SetOptions(merge: true));

      final batch = FirebaseFirestore.instance.batch();
      for (final size in _sizes) {
        final controller = _sizeControllers[size];
        final qty = int.tryParse(controller?.text.trim() ?? "0") ?? 0;
        final stockRef = docRef.collection('stocks').doc(size.toString());
        batch.set(stockRef, {'size': size, 'qty': qty}, SetOptions(merge: true));
      }
      await batch.commit();

      _showSnackBar(isUpdate ? "Proizvod izmenjen." : "Proizvod sacuvan.");
      setState(() {
        _selectedProductId = docRef.id;
        _isEditMode = true;
        _existingImageUrl = imageUrl;
        _pickedImage = null;
      });
    } catch (e) {
      _showSnackBar("Greska: $e");
    } finally {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
    }
  }

  Widget _buildChipGroup({
    required String title,
    required List<String> options,
    required Set<String> selected,
    required String Function(String) labelBuilder,
    bool singleSelect = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitelesTextWidget(
          label: title,
          color: AppColors.darkPrimary,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected.contains(option);
            return FilterChip(
              label: Text(labelBuilder(option)),
              selected: isSelected,
              onSelected: (value) {
                setState(() {
                  if (singleSelect) {
                    selected.clear();
                  }
                  if (value) {
                    selected.add(option);
                  } else {
                    selected.remove(option);
                  }
                  if (selected == _selectedGenders) {
                    if (_selectedGenders.contains("men")) {
                      _selectedTypes.remove("heels");
                      _selectedTypes.remove("stikle");
                    }
                    _syncSizeControllers();
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSizeQuantityInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TitelesTextWidget(
          label: "Kolicina po broju",
          color: AppColors.darkPrimary,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _sizes.map((size) {
            final controller = _sizeControllers.putIfAbsent(
              size,
              () => TextEditingController(text: "0"),
            );
            return SizedBox(
              width: 90,
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Broj $size",
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "0";
                  }
                  final parsed = int.tryParse(value.trim());
                  if (parsed == null || parsed < 0) {
                    return "Err";
                  }
                  return null;
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TitelesTextWidget(
          label: "Admin",
          color: AppColors.darkPrimary,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitelesTextWidget(
                  label: _isEditMode ? "Modifikacija proizvoda" : "Proizvod",
                  color: AppColors.darkPrimary,
                ),
                const SizedBox(height: 12),
                _buildImagePickerSection(),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Naziv",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Unesi naziv";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Cena (RSD)",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Unesi cenu";
                    }
                    final parsed = double.tryParse(value.trim());
                    if (parsed == null || parsed <= 0) {
                      return "Neispravna cena";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Opis",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Unesi opis";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildChipGroup(
                  title: "Pol",
                  options: AppConstants.filterGenders,
                  selected: _selectedGenders,
                  labelBuilder: AppConstants.genderLabel,
                  singleSelect: true,
                ),
                const SizedBox(height: 16),
                _buildChipGroup(
                  title: "Tip obuce",
                  options: _availableTypes,
                  selected: _selectedTypes,
                  labelBuilder: AppConstants.typeLabel,
                  singleSelect: true,
                ),
                const SizedBox(height: 16),
                _buildChipGroup(
                  title: "Boja",
                  options: AppConstants.filterColors,
                  selected: _selectedColors,
                  labelBuilder: AppConstants.colorLabel,
                ),
                const SizedBox(height: 16),
                _buildChipGroup(
                  title: "Materijal",
                  options: AppConstants.materialTypes,
                  selected: _selectedMaterials,
                  labelBuilder: AppConstants.materialFilterLabel,
                  singleSelect: true,
                ),
                const SizedBox(height: 16),
                _buildSizeQuantityInputs(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      _isSaving
                          ? "Cuvanje..."
                          : (_isEditMode
                              ? "Sacuvaj izmene proizvoda"
                              : "Sacuvaj novi proizvod"),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const TitelesTextWidget(
                  label: "Admin opcije",
                  color: AppColors.darkPrimary,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushNamed(AdminProductsManageScreen.routeName);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.inventory_2_outlined),
                    label: const Text("Ucitaj proizvod"),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed(OrdersScreen.routeName);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.receipt_long),
                    label: const Text("Pregled porudzbina"),
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
