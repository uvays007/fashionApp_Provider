import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comercial_app/helper/timehelper.dart';
import 'package:comercial_app/screens/global_screen/global.dart';
import 'package:flutter/material.dart';

class OrderPaymentPage extends StatefulWidget {
  final String total;
  const OrderPaymentPage({super.key, required this.total});

  @override
  State<OrderPaymentPage> createState() => _OrderPaymentPageState();
}

class _OrderPaymentPageState extends State<OrderPaymentPage> {
  String _selectedPayment = "UPI";

  final TextEditingController _upiController = TextEditingController();
  final TextEditingController _cardController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _couponController = TextEditingController();

  double discount = 0;
  bool couponApplied = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    double originalTotal = double.tryParse(widget.total) ?? 0;
    double finalTotal = (originalTotal - discount).clamp(0, double.infinity);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Order Confirmation"),
        backgroundColor: const Color(0xFFC19375),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SizedBox(height: 10),

            const Text(
              "Order Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _buildSummaryRow("Items Total", "Rs.$originalTotal"),
            _buildSummaryRow("Shipping", "Free"),

            if (discount > 0)
              _buildSummaryRow(
                "Discount",
                "- Rs.$discount",
                bold: true,
                color: Colors.green,
              ),

            const Divider(),
            _buildSummaryRow("Total Amount", "Rs.$finalTotal", bold: true),

            const SizedBox(height: 30),

            const Text(
              "Delivery Address",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Enter your home address...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Apply Coupon",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    decoration: InputDecoration(
                      hintText: "Enter coupon code",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC19375),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _applyCoupon,
                  child: Text(
                    couponApplied ? "Applied" : "Apply",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Select Payment Method",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _buildPaymentOption("UPI"),
            _buildPaymentOption("Debit Card"),

            const SizedBox(height: 20),

            if (_selectedPayment == "UPI") _buildUPISection(),
            if (_selectedPayment == "Debit Card") _buildCardSection(),

            const SizedBox(height: 40),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC19375),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                if (_addressController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter delivery address"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                _showPaymentSuccess(context, finalTotal);
              },
              child: const Text(
                "Confirm & Pay",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool bold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String method) {
    return RadioListTile<String>(
      title: Text(method),
      value: method,
      groupValue: _selectedPayment,
      activeColor: const Color(0xFFC19375),
      onChanged: (value) {
        setState(() => _selectedPayment = value!);
      },
    );
  }

  Widget _buildUPISection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Enter UPI ID",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _upiController,
          decoration: InputDecoration(
            hintText: "example@upi",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.account_balance_wallet),
          ),
        ),
      ],
    );
  }

  Widget _buildCardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Enter Card Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _cardController,
          decoration: InputDecoration(
            hintText: "Card Number",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.credit_card),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "MM/YY",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.datetime,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "CVV",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                obscureText: true,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _applyCoupon() {
    String code = _couponController.text.trim().toUpperCase();

    if (code == "SAVE10") {
      setState(() {
        discount = (double.parse(widget.total) * 0.10);
        couponApplied = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Coupon Applied! 10% discount"),
          backgroundColor: Colors.green,
        ),
      );
    } else if (code == "WELCOME50") {
      setState(() {
        discount = 50;
        couponApplied = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("₹50 OFF applied!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid coupon code"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPaymentSuccess(BuildContext context, double finalTotal) async {
    final cartSnapshot = await _firestore.collection("cart").get();
    List<Map<String, dynamic>> cartItems = cartSnapshot.docs
        .map((doc) => doc.data())
        .toList();

    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your cart is empty"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await _firestore.collection("orders").add({
      "items": cartItems,
      "total": finalTotal,
      "address": _addressController.text.trim(),
      "payment_method": _selectedPayment,
      "time": DateTime.now().toString(),
    });

    String productNames = cartItems.map((item) => item['name']).join(", ");

    notifications.add({
      "message": "Your order for $productNames has been placed successfully!",
      "time": timeAgo(DateTime.now()),
    });

    for (var doc in cartSnapshot.docs) {
      await doc.reference.delete();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 10),
            const Text(
              "Payment Successful!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              "Your order has been placed.\nTotal Paid: Rs.$finalTotal",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC19375),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
