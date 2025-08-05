class Bill {
  final int id;
  final int tenantId;
  final int readingId;
  final int roomCharges;
  final int electricCharges;
  final int additionalCharges;
  final String additionalDescription;
  final int totalAmount;
  final DateTime createdAt;
  final int currReading;
  final int prevReading;
  final int consumption;

  Bill({
    required this.id,
    required this.tenantId,
    required this.readingId,
    required this.roomCharges,
    required this.electricCharges,
    required this.additionalCharges,
    required this.additionalDescription,
    required this.totalAmount,
    required this.createdAt,
    required this.currReading,
    required this.prevReading,
    required this.consumption,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    final reading = json['reading'] ?? {};

    return Bill(
      id: json['id'],
      readingId: json['readingId'],
      tenantId: json['tenantId'],
      roomCharges: json['roomCharges'],
      electricCharges: json['electricCharges'],
      additionalCharges: json['additionalCharges'],
      additionalDescription: json['additionalDescription'] ?? '',
      totalAmount: json['totalAmount'],
      createdAt: DateTime.parse(json['createdAt']),
      currReading: reading['currReading'] ?? 0,
      prevReading: reading['prevReading'] ?? 0,
      consumption: reading['consumption'] ?? 0,
    );
  }
}
