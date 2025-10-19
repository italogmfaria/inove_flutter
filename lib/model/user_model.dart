class UserModel {
  final int? id;
  final String name;
  final String cpf;
  final String email;
  final String password;
  final DateTime? birthDate;
  final int? schoolId;

  UserModel({
    this.id,
    required this.name,
    required this.cpf,
    required this.email,
    required this.password,
    this.birthDate,
    this.schoolId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      cpf: json['cpf'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'])
          : null,
      schoolId: json['schoolId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cpf': cpf,
      'email': email,
      'password': password,
      'birthDate': birthDate?.toIso8601String(),
      'schoolId': schoolId,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? cpf,
    String? email,
    String? password,
    DateTime? birthDate,
    int? schoolId,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      cpf: cpf ?? this.cpf,
      email: email ?? this.email,
      password: password ?? this.password,
      birthDate: birthDate ?? this.birthDate,
      schoolId: schoolId ?? this.schoolId,
    );
  }
}
