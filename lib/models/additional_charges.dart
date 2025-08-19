class AdditionalCharge {
  final int amount;
  final String description;

  AdditionalCharge({required this.amount, required this.description});

  factory AdditionalCharge.fromJson(Map<String, dynamic> json) {
    return AdditionalCharge(amount: json['amount'], description: json['description']);
  }
}
