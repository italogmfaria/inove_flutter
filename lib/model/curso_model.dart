class CursoModel {
  final int? id;
  final String titulo;
  final String descricao;

  CursoModel({
    this.id,
    required this.titulo,
    required this.descricao,
  });

  factory CursoModel.fromJson(Map<String, dynamic> json) {
    return CursoModel(
      id: json['id'],
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
    };
  }

  CursoModel copyWith({
    int? id,
    String? titulo,
    String? descricao,
  }) {
    return CursoModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
    );
  }
}
