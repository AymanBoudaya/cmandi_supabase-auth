import 'package:caferesto/features/shop/models/cart_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/constants/enums.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../personalization/models/address_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final OrderStatus status;
  final double totalAmount;
  final DateTime orderDate;
  final String paymentMethod;
  final AddressModel? address;
  final DateTime? deliveryDate;
  final List<CartItemModel> items;

  OrderModel({
    required this.id,
    this.userId = '',
    required this.status,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    this.paymentMethod = 'Payement à la caisse',
    this.deliveryDate,
    this.address,
  });

  String get formattedOrderDate => THelperFunctions.getFormattedDate(orderDate);

  String get formattedDeliveryDate => deliveryDate != null
      ? THelperFunctions.getFormattedDate(deliveryDate!)
      : '';

  String get orderStatusText => status == OrderStatus.delivered
      ? 'Livrée'
      : status == OrderStatus.shipped
          ? 'Livraison en cours'
          : 'En cours de traitement';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'paymentMethod': paymentMethod,
      'status': status.toString(),
      'totalAmount': totalAmount,
      'orderDate': orderDate,
      'deliveryDate': deliveryDate,
      'address': address?.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory OrderModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return OrderModel(
      id: data['id'] as String,
      userId: data['UserId'] as String,
      status:
          OrderStatus.values.firstWhere((e) => e.toString() == data['Status']),
      totalAmount: data['totalAmount'] as double,
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      paymentMethod: data['PaymentMethod'] as String,
      address: AddressModel.fromJson2(data['address'] as Map<String, dynamic>),
      deliveryDate: data['deliveryDate'] != null
          ? (data['deliveryDate'] as Timestamp).toDate()
          : null,
      items: (data['items'] as List<dynamic>)
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
