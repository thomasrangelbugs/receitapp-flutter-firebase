import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de lista de receitas favoritada.
class ListaModel {
  /// Identificador da lista.
  final String id;

  /// Usuario dono da lista.
  final String userId;

  /// Titulo da lista.
  final String titulo;

  /// Identificadores das receitas associadas.
  final List<String> receitaIds;

  /// Data de criacao.
  final DateTime dataCriacao;

  const ListaModel({
    required this.id,
    required this.userId,
    required this.titulo,
    required this.receitaIds,
    required this.dataCriacao,
  });

  ListaModel copyWith({
    String? id,
    String? userId,
    String? titulo,
    List<String>? receitaIds,
    DateTime? dataCriacao,
  }) {
    return ListaModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      titulo: titulo ?? this.titulo,
      receitaIds: receitaIds ?? this.receitaIds,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'titulo': titulo,
      'receitaIds': receitaIds,
      'dataCriacao': Timestamp.fromDate(dataCriacao),
    };
  }

  factory ListaModel.fromMap(Map<String, dynamic> map, String id) {
    final valorData = map['dataCriacao'];
    final dataCriacao = _extrairData(valorData);

    return ListaModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      titulo: map['titulo'] as String? ?? '',
      receitaIds: List<String>.from(map['receitaIds'] as List<dynamic>? ?? []),
      dataCriacao: dataCriacao,
    );
  }
}

DateTime _extrairData(dynamic valorData) {
  if (valorData is Timestamp) {
    return valorData.toDate();
  }
  if (valorData is DateTime) {
    return valorData;
  }
  return DateTime.fromMillisecondsSinceEpoch(0);
}
