import 'package:m18_residences/models/additional_charges.dart';

class Bill {
  final int id;
  final int tenantId;
  final int readingId;
  final int roomCharges;
  final int electricCharges;
  final List<AdditionalCharge>? additionalCharges;
  final int totalAmount;
  final DateTime createdAt;
  final int currReading;
  final int prevReading;
  final int consumption;
  final bool paid;
  final String? receiptUrl;

  Bill({
    required this.id,
    required this.tenantId,
    required this.readingId,
    required this.roomCharges,
    required this.electricCharges,
    required this.totalAmount,
    required this.createdAt,
    required this.currReading,
    required this.prevReading,
    required this.consumption,
    required this.paid,
    this.receiptUrl,
    this.additionalCharges,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    final billJson = json['bill'] ?? {};
    final reading = json['reading'] ?? {};

    return Bill(
      id: billJson['id'],
      readingId: billJson['reading_id'],
      tenantId: billJson['tenant_id'],
      roomCharges: billJson['room_charges'],
      electricCharges: billJson['electric_charges'],
      totalAmount: billJson['total_amount'],
      createdAt: DateTime.parse(billJson['created_at']),
      paid: billJson['paid'],
      receiptUrl: billJson['receipt_url'],
      currReading: reading['curr_reading'] ?? 0,
      prevReading: reading['prev_reading'] ?? 0,
      consumption: reading['consumption'] ?? 0,
      additionalCharges:
          json['additional_charges'] != null ? (json['additional_charges'] as List).map((e) => AdditionalCharge.fromJson(e)).toList() : null,
    );
  }
}
