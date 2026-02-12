import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoeshop/services/assets_menager.dart';
import 'package:shoeshop/widgets/subtitle_text.dart';
import 'package:shoeshop/widgets/title_text.dart';

class OrdersWidget extends StatefulWidget {
  const OrdersWidget({super.key, required this.orderDoc, required this.isAdmin});

  final QueryDocumentSnapshot<Map<String, dynamic>> orderDoc;
  final bool isAdmin;

  @override
  State<OrdersWidget> createState() => _OrdersWidgetState();
}

class _OrdersWidgetState extends State<OrdersWidget> {
  static const List<String> _statusOptions = [
    "primljen",
    "poslat",
    "isporucen",
  ];
  bool _isUpdatingStatus = false;

  Color _statusColor(String status) {
    switch (status) {
      case "isporucen":
        return Colors.green.shade700;
      case "poslat":
        return Colors.orange.shade700;
      default:
        return Colors.blue.shade700;
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) {
      return "-";
    }
    final date = timestamp.toDate();
    String two(int value) => value.toString().padLeft(2, "0");
    return "${two(date.day)}.${two(date.month)}.${date.year} ${two(date.hour)}:${two(date.minute)}";
  }

  Future<void> _updateStatus(String nextStatus) async {
    setState(() {
      _isUpdatingStatus = true;
    });
    try {
      await widget.orderDoc.reference.update({
        "orderStatus": nextStatus,
        "updatedAt": FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status azuriran: $nextStatus")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Greska pri izmeni statusa: $e")));
    } finally {
      if (!mounted) return;
      setState(() {
        _isUpdatingStatus = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.orderDoc.data();
    final status = (data["orderStatus"] as String?) ?? "primljen";
    final orderNumber =
        (data["orderNumber"] as String?) ?? widget.orderDoc.id.substring(0, 8).toUpperCase();
    final total = (data["grandTotal"] as num?)?.toDouble() ?? 0.0;
    final quantity = (data["totalQuantity"] as num?)?.toInt() ?? 0;
    final paymentProvider = (data["paymentProvider"] as String?) ?? "stripe";
    final customerName = (data["customerFullName"] as String?) ?? "-";
    final customerEmail = (data["email"] as String?) ?? "-";
    final phone = (data["phone"] as String?) ?? "-";
    final address = (data["address"] as String?) ?? "-";
    final city = (data["city"] as String?) ?? "-";
    final createdAt = data["createdAt"] as Timestamp?;
    final items = (data["items"] as List?) ?? const [];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  "${AssetsMenager.imagePath}/bag/checkout.png",
                  height: 48,
                  width: 48,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitelesTextWidget(
                        label: "Order #$orderNumber",
                        fontSize: 16,
                      ),
                      const SizedBox(height: 4),
                      SubtitleTextWidget(
                        label: "$quantity artikala - ${total.toStringAsFixed(2)} RSD",
                        fontSize: 14,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _statusColor(status),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SubtitleTextWidget(
              label: "Datum: ${_formatDate(createdAt)}",
              fontSize: 13,
            ),
            SubtitleTextWidget(
              label: "Placanje: ${paymentProvider.toUpperCase()}",
              fontSize: 13,
            ),
            const SizedBox(height: 8),
            if (widget.isAdmin) ...[
              SubtitleTextWidget(label: "Kupac: $customerName", fontSize: 13),
              SubtitleTextWidget(label: "Email: $customerEmail", fontSize: 13),
              SubtitleTextWidget(label: "Telefon: $phone", fontSize: 13),
              SubtitleTextWidget(
                label: "Adresa: $address, $city",
                fontSize: 13,
              ),
            ],
            if (items.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              ...items.take(3).map((item) {
                if (item is! Map) {
                  return const SizedBox.shrink();
                }
                final title = (item["title"] ?? "-").toString();
                final size = (item["size"] ?? "-").toString();
                final itemQty = (item["quantity"] ?? "-").toString();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: SubtitleTextWidget(
                    label: "$title | broj $size | x$itemQty",
                    fontSize: 13,
                  ),
                );
              }),
              if (items.length > 3)
                SubtitleTextWidget(
                  label: "+${items.length - 3} jos artikala",
                  fontSize: 13,
                ),
            ],
            if (widget.isAdmin) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _statusOptions.contains(status) ? status : _statusOptions.first,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: "Promeni status",
                  border: OutlineInputBorder(),
                ),
                items: _statusOptions
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _isUpdatingStatus
                    ? null
                    : (value) async {
                        if (value == null || value == status) {
                          return;
                        }
                        await _updateStatus(value);
                      },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
