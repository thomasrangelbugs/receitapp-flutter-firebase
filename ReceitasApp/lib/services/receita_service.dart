import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/receita_model.dart';

/// Serviço responsavel pelo CRUD de receitas no Firestore.
class ReceitaService {
  final CollectionReference<Map<String, dynamic>> _colecao =
      FirebaseFirestore.instance.collection('receitas');
  final Uuid _uuid = const Uuid();

  /// Cria uma nova receita para o usuario.
  Future<void> criar(ReceitaModel receita) async {
    final id = receita.id.isNotEmpty ? receita.id : _uuid.v4();
    final novaReceita = receita.copyWith(id: id);
    await _colecao.doc(id).set(novaReceita.toMap());
  }

  /// Atualiza os dados da receita existente.
  Future<void> atualizar(ReceitaModel receita) async {
    await _colecao.doc(receita.id).update(receita.toMap());
  }

  /// Remove a receita pelo identificador.
  Future<void> excluir(String receitaId) async {
    await _colecao.doc(receitaId).delete();
  }

  /// Fluxo de receitas filtradas pelo usuario.
  Stream<List<ReceitaModel>> listar(String userId) {
    return _colecao
        .where('userId', isEqualTo: userId)
        .orderBy('dataCriacao', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ReceitaModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Busca uma receita pelo identificador.
  Future<ReceitaModel?> buscarPorId(String receitaId) async {
    final doc = await _colecao.doc(receitaId).get();
    if (!doc.exists) {
      return null;
    }
    return ReceitaModel.fromMap(doc.data()!, doc.id);
  }

  /// Filtra a lista de receitas pelo titulo (cliente).
  List<ReceitaModel> filtrarPorTitulo(
    List<ReceitaModel> receitas,
    String termo,
  ) {
    if (termo.trim().isEmpty) {
      return receitas;
    }
    final termoLower = termo.toLowerCase();
    return receitas
        .where((receita) => receita.titulo.toLowerCase().contains(termoLower))
        .toList();
  }
}
