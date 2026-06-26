/// Representa um ingrediente da receita.
class IngredienteModel {
  /// Nome do ingrediente (ex.: Farinha).
  final String nome;

  /// Quantidade em formato texto (ex.: 200).
  final String quantidade;

  /// Unidade de medida (ex.: g, ml, unidade).
  final String unidade;

  const IngredienteModel({
    required this.nome,
    required this.quantidade,
    required this.unidade,
  });

  IngredienteModel copyWith({
    String? nome,
    String? quantidade,
    String? unidade,
  }) {
    return IngredienteModel(
      nome: nome ?? this.nome,
      quantidade: quantidade ?? this.quantidade,
      unidade: unidade ?? this.unidade,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'quantidade': quantidade,
      'unidade': unidade,
    };
  }

  factory IngredienteModel.fromMap(Map<String, dynamic> map) {
    return IngredienteModel(
      nome: map['nome'] as String? ?? '',
      quantidade: map['quantidade'] as String? ?? '',
      unidade: map['unidade'] as String? ?? '',
    );
  }
}
