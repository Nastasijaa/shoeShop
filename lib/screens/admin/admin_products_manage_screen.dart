import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shoeshop/consts/app_colors.dart';
import 'package:shoeshop/screens/admin/admin_dashboard_screen.dart';
import 'package:shoeshop/services/product_integrity_service.dart';
import 'package:shoeshop/widgets/title_text.dart';

class AdminProductsManageScreen extends StatefulWidget {
  const AdminProductsManageScreen({super.key});

  static const routeName = "/AdminProductsManageScreen";

  @override
  State<AdminProductsManageScreen> createState() =>
      _AdminProductsManageScreenState();
}

class _AdminProductsManageScreenState extends State<AdminProductsManageScreen> {
  final _searchController = TextEditingController();
  String _query = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteProduct(String productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Brisanje proizvoda"),
        content: const Text("Da li si sigurna da zelis da obrises proizvod?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Odustani"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Obrisi"),
          ),
        ],
      ),
    );
    if (confirm != true) {
      return;
    }

    try {
      final docRef = FirebaseFirestore.instance
          .collection('products')
          .doc(productId);
      final stocks = await docRef.collection('stocks').get();
      for (final stock in stocks.docs) {
        await stock.reference.delete();
      }
      await docRef.delete();

      if (!mounted) {
        return;
      }
      ProductIntegrityService.removeDeletedProductFromState(context, productId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Proizvod obrisan.")));
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Greska: $e")));
    }
  }

  Widget _buildProductImage(String? imageUrl) {
    final path = (imageUrl ?? "").trim();
    if (path.isEmpty) {
      return const Icon(Icons.image_outlined, color: AppColors.darkPrimary);
    }
    if (path.startsWith("http://") || path.startsWith("https://")) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.broken_image_outlined,
          color: AppColors.darkPrimary,
        ),
      );
    }
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.broken_image_outlined, color: AppColors.darkPrimary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const TitelesTextWidget(label: "Svi proizvodi")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Pretrazi proizvod...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _query = "";
                          });
                        },
                        icon: const Icon(Icons.clear),
                      ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _query = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Nema proizvoda."));
                }

                final docs = snapshot.data!.docs.where((doc) {
                  if (_query.isEmpty) {
                    return true;
                  }
                  final title = ((doc.data()['title'] as String?) ?? "")
                      .toLowerCase();
                  return title.contains(_query);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text("Nema rezultata."));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final title = (data['title'] as String?) ?? "Proizvod";
                    final price = (data['price'] as num?)?.toDouble() ?? 0;
                    final imageUrl = data['imageUrl'] as String?;

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 64,
                                height: 64,
                                child: _buildProductImage(imageUrl),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${price.toStringAsFixed(2)} RSD",
                                    style: const TextStyle(
                                      color: AppColors.darkPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: "Izmeni",
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                  AdminDashboardScreen.routeName,
                                  arguments: doc.id,
                                );
                              },
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              tooltip: "Obrisi",
                              onPressed: () => _deleteProduct(doc.id),
                              icon: const Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
