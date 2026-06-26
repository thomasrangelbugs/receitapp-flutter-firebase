import 'package:cloud_firestore/cloud_firestore.dart';

import 'etapa_model.dart';
import 'ingrediente_model.dart';

/// Modelo que representa uma receita.
class ReceitaModel {
  /// Identificador da receita.
  final String id;

  /// Usuario dono da receita.
  final String userId;

  /// Titulo da receita.
  final String titulo;

  /// Descricao curta da receita.
  final String descricao;

  /// Tempo total de preparo em minutos.
  final int tempoPreparo;

  /// Quantidade de porcoes da receita.
  final int porcoes;

  /// URL opcional da imagem da receita. Quando vazia, o app exibe uma
  /// imagem de exemplo escolhida automaticamente.
  final String imagemUrl;

  /// Lista de ingredientes.
  final List<IngredienteModel> ingredientes;

  /// Lista de etapas do preparo.
  final List<EtapaModel> etapas;

  /// Data de criacao.
  final DateTime dataCriacao;

  const ReceitaModel({
    required this.id,
    required this.userId,
    required this.titulo,
    required this.descricao,
    required this.tempoPreparo,
    required this.porcoes,
    required this.ingredientes,
    required this.etapas,
    required this.dataCriacao,
    this.imagemUrl = '',
  });

  ReceitaModel copyWith({
    String? id,
    String? userId,
    String? titulo,
    String? descricao,
    int? tempoPreparo,
    int? porcoes,
    List<IngredienteModel>? ingredientes,
    List<EtapaModel>? etapas,
    DateTime? dataCriacao,
    String? imagemUrl,
  }) {
    return ReceitaModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      tempoPreparo: tempoPreparo ?? this.tempoPreparo,
      porcoes: porcoes ?? this.porcoes,
      ingredientes: ingredientes ?? this.ingredientes,
      etapas: etapas ?? this.etapas,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      imagemUrl: imagemUrl ?? this.imagemUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'titulo': titulo,
      'descricao': descricao,
      'tempoPreparo': tempoPreparo,
      'porcoes': porcoes,
      'imagemUrl': imagemUrl,
      'ingredientes': ingredientes.map((item) => item.toMap()).toList(),
      'etapas': etapas.map((item) => item.toMap()).toList(),
      'dataCriacao': Timestamp.fromDate(dataCriacao),
    };
  }

  factory ReceitaModel.fromMap(Map<String, dynamic> map, String id) {
    final listaIngredientes = (map['ingredientes'] as List<dynamic>? ?? [])
        .map((item) => IngredienteModel.fromMap(item as Map<String, dynamic>))
        .toList();
    final listaEtapas = (map['etapas'] as List<dynamic>? ?? [])
        .map((item) => EtapaModel.fromMap(item as Map<String, dynamic>))
        .toList();
    final valorData = map['dataCriacao'];
    final dataCriacao = _extrairData(valorData);

    return ReceitaModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      titulo: map['titulo'] as String? ?? '',
      descricao: map['descricao'] as String? ?? '',
      tempoPreparo: map['tempoPreparo'] as int? ?? 0,
      porcoes: map['porcoes'] as int? ?? 0,
      imagemUrl: map['imagemUrl'] as String? ?? '',
      ingredientes: listaIngredientes,
      etapas: listaEtapas,
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
