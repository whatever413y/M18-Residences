class Tenant {
  final int? id;
  final String name;

  Tenant({this.id, required this.name});

  factory Tenant.fromJson(Map<String, dynamic> json) => Tenant(id: json['id'], name: json['name']);

  Map<String, dynamic> toJson() => {'name': name};
}
