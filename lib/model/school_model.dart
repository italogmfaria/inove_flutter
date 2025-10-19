class SchoolModel {
  final int? id;
  final String name;
  final String city;
  final String email;
  final String federativeUnit;

  SchoolModel({
    this.id,
    required this.name,
    required this.city,
    required this.email,
    required this.federativeUnit,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id'],
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      email: json['email'] ?? '',
      federativeUnit: json['federativeUnit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'email': email,
      'federativeUnit': federativeUnit,
    };
  }

  SchoolModel copyWith({
    int? id,
    String? name,
    String? city,
    String? email,
    String? federativeUnit,
  }) {
    return SchoolModel(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      email: email ?? this.email,
      federativeUnit: federativeUnit ?? this.federativeUnit,
    );
  }
}
