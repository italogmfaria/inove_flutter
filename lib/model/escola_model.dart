class EscolaModel {
  final int? id;
  final String nome;

  EscolaModel({
    this.id,
    required this.nome,
  });

  factory EscolaModel.fromJson(Map<String, dynamic> json) {
    return EscolaModel(
      id: json['id'],
      nome: json['nome'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
    };
  }

  EscolaModel copyWith({
    int? id,
    String? nome,
    String? cnpj,
  }) {
    return EscolaModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
    );
  }
}
