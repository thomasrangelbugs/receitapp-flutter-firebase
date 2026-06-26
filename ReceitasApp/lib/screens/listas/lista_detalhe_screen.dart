import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/error_handler.dart';
import '../../models/lista_model.dart';
import '../../models/receita_model.dart';
import '../../services/lista_service.dart';
import '../../widgets/common/app_bar_padrao.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/receita_imagem.dart';

class ListaDetalheScreen extends StatelessWidget {
  final String idLista;

  const ListaDetalheScreen({super.key, required this.idLista});

  Future<void> _excluirLista(BuildContext context, ListaModel lista) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir lista?'),
          content: Text('Tem certeza que deseja excluir ${lista.titulo}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmou != true) {
      return;
    }

    try {
      await context.read<ListaService>().excluir(lista.id);
      if (context.mounted) {
        ErrorHandler.mostrarSucesso(context, 'Lista excluida.');
        context.pop();
      }
    } catch (erro) {
      if (context.mounted) {
        ErrorHandler.mostrarErro(context, 'Falha ao excluir lista.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final listas = context.watch<List<ListaModel>>();
    final receitas = context.watch<List<ReceitaModel>>();
    final lista = listas.firstWhereOrNull((item) => item.id == idLista);

    if (lista == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final receitasMap = {for (final r in receitas) r.id: r};
    final receitasDaLista = lista.receitaIds
        .map((id) => receitasMap[id])
        .whereType<ReceitaModel>()
        .toList();

    return Scaffold(
      appBar: AppBarPadrao(
        titulo: lista.titulo,
        mostrarVoltar: true,
        acoes: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
            onPressed: () => context.go(
              '${Rotas.caminhoListas}/${lista.id}/editar',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Excluir',
            onPressed: () => _excluirLista(context, lista),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Receitas na lista',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => context.go(
                      '${Rotas.caminhoListas}/${lista.id}/editar',
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: receitasDaLista.isEmpty
                    ? const EmptyStateWidget(
                        icone: Icons.restaurant_menu,
                        titulo: 'Lista sem receitas',
                        descricao: 'Adicione receitas para organizar.',
                      )
                    : ListView.builder(
                        itemCount: receitasDaLista.length,
                        itemBuilder: (context, index) {
                          final receita = receitasDaLista[index];
                          return Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              leading: SizedBox(
                                width: 56,
                                height: 56,
                                child: ReceitaImagem(
                                  chave: receita.id.isNotEmpty
                                      ? receita.id
                                      : receita.titulo,
                                  imagemUrl: receita.imagemUrl,
                                  raio: 12,
                                ),
                              ),
                              title: Text(receita.titulo),
                              subtitle: Text(
                                '${receita.tempoPreparo} min • ${receita.porcoes} porcoes',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  final novaLista = lista.copyWith(
                                    receitaIds: lista.receitaIds
                                        .where((id) => id != receita.id)
                                        .toList(),
                                  );
                                  context
                                      .read<ListaService>()
                                      .atualizar(novaLista);
                                },
                              ),
                              onTap: () => context.go(
                                '${Rotas.caminhoReceitas}/${receita.id}',
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension ListaModelIterable on Iterable<ListaModel> {
  ListaModel? firstWhereOrNull(bool Function(ListaModel) test) {
    for (final item in this) {
      if (test(item)) {
        return item;
      }
    }
    return null;
  }
}
