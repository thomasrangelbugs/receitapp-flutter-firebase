/// Representa uma etapa do modo de preparo.
class EtapaModel {
  /// Ordem da etapa no preparo.
  final int ordem;

  /// Descricao detalhada da etapa.
  final String descricao;

  /// Tempo sugerido em minutos para a etapa.
  final int? tempoPasso;

  const EtapaModel({
    required this.ordem,
    required this.descricao,
    this.tempoPasso,
  });

  EtapaModel copyWith({
    int? ordem,
    String? descricao,
    int? tempoPasso,
  }) {
    return EtapaModel(
      ordem: ordem ?? this.ordem,
      descricao: descricao ?? this.descricao,
      tempoPasso: tempoPasso ?? this.tempoPasso,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ordem': ordem,
      'descricao': descricao,
      'tempoPasso': tempoPasso,
    };
  }

  factory EtapaModel.fromMap(Map<String, dynamic> map) {
    return EtapaModel(
      ordem: map['ordem'] as int? ?? 0,
      descricao: map['descricao'] as String? ?? '',
      tempoPasso: map['tempoPasso'] as int?,
    );
  }
}
