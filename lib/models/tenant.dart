class Tenant {
  final int id;
  final String name;

  Tenant({required this.id, required this.name});

  factory Tenant.fromJson(Map<String, dynamic> json) => Tenant(id: json['id'], name: json['name']);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
