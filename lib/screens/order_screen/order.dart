import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:comercial_app/theme/Textstyles.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFC19375),
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Orders Found"));
          }

          var orders = snapshot.data!.docs;

          return ListView.separated(
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              String sixdigitId = orders[index].id.substring(0, 6);
              final order = orders[index].data();
              final List items = order['items'];

              final isPlaced = order['isPlaced'] ?? false;
              final status = order['status'] ?? "In Transit";

              return Container(
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order ID: #$sixdigitId",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 10,
                              color: _getStatusColor(status),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              status,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(status),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, itemIndex) {
                        final item = items[itemIndex];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  item['image'],
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 15),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['brandname'],
                                      style: AppTextStyles.semiBold.copyWith(
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),

                                    Text(
                                      item['name'],
                                      style: AppTextStyles.medium.copyWith(
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'qty:${item['qty'].toString()} ,',
                                          style: AppTextStyles.medium.copyWith(
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          'size:${item['size']}',
                                          style: AppTextStyles.medium.copyWith(
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              Text(
                                "${item['price']}",
                                style: AppTextStyles.bold.copyWith(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Icon(
                          isPlaced ? Icons.check_circle : Icons.cancel_outlined,
                          color: isPlaced ? Colors.green : Colors.redAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isPlaced ? "Order Placed" : "Not Placed",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isPlaced ? Colors.green : Colors.redAccent,
                          ),
                        ),
                        Spacer(),
                        Text(
                          "Total : RS ${order['total']}",
                          style: AppTextStyles.bold.copyWith(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'in transit':
        return Colors.orange;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}
