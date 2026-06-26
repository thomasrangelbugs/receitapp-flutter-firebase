import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/lista_model.dart';

/// Serviço responsavel pelo CRUD de listas no Firestore.
class ListaService {
  final CollectionReference<Map<String, dynamic>> _colecao =
      FirebaseFirestore.instance.collection('listas');
  final Uuid _uuid = const Uuid();

  /// Cria uma nova lista.
  Future<void> criar(ListaModel lista) async {
    final id = lista.id.isNotEmpty ? lista.id : _uuid.v4();
    final novaLista = lista.copyWith(id: id);
    await _colecao.doc(id).set(novaLista.toMap());
  }

  /// Atualiza a lista existente.
  Future<void> atualizar(ListaModel lista) async {
    await _colecao.doc(lista.id).update(lista.toMap());
  }

  /// Exclui a lista.
  Future<void> excluir(String listaId) async {
    await _colecao.doc(listaId).delete();
  }

  /// Fluxo de listas do usuario.
  Stream<List<ListaModel>> listar(String userId) {
    return _colecao
        .where('userId', isEqualTo: userId)
        .orderBy('dataCriacao', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ListaModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Busca uma lista pelo identificador.
  Future<ListaModel?> buscarPorId(String listaId) async {
    final doc = await _colecao.doc(listaId).get();
    if (!doc.exists) {
      return null;
    }
    return ListaModel.fromMap(doc.data()!, doc.id);
  }

  /// Remove uma receita de todas as listas do usuario.
  Future<void> removerReceitaDasListas({
    required String userId,
    required String receitaId,
  }) async {
    final query = await _colecao
        .where('userId', isEqualTo: userId)
        .where('receitaIds', arrayContains: receitaId)
        .get();

    if (query.docs.isEmpty) {
      return;
    }

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in query.docs) {
      batch.update(doc.reference, {
        'receitaIds': FieldValue.arrayRemove([receitaId]),
      });
    }
    await batch.commit();
  }
}
