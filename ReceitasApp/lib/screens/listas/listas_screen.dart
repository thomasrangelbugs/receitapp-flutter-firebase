import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/error_handler.dart';
import '../../models/lista_model.dart';
import '../../models/receita_model.dart';
import '../../services/lista_service.dart';
import '../../widgets/common/empty_state.dart';

class ListasScreen extends StatelessWidget {
  const ListasScreen({super.key});

  Future<void> _excluirLista(
    BuildContext context,
    ListaModel lista,
  ) async {
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
    final receitasPorId = {
      for (final receita in receitas) receita.id: receita,
    };

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 600));
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
          if (listas.isEmpty)
            EmptyStateWidget(
              icone: Icons.list_alt,
              titulo: 'Nenhuma lista criada',
              descricao: 'Crie listas com suas receitas favoritas.',
              acao: ElevatedButton(
                onPressed: () => context.go(Rotas.caminhoListaNova),
                child: const Text('Nova lista'),
              ),
            )
          else
            ...listas.map((lista) {
              final preview = lista.receitaIds
                  .map((id) => receitasPorId[id]?.titulo)
                  .whereType<String>()
                  .take(3)
                  .toList();
              final previewTexto =
                  preview.isEmpty ? 'Sem receitas' : preview.join(' • ');

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.list_alt),
                  ),
                  title: Text(lista.titulo),
                  subtitle: Text(previewTexto),
                  onTap: () => context.go(
                    '${Rotas.caminhoListas}/${lista.id}',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (valor) {
                      if (valor == 'editar') {
                        context.go(
                          '${Rotas.caminhoListas}/${lista.id}/editar',
                        );
                      } else if (valor == 'excluir') {
                        _excluirLista(context, lista);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'editar',
                        child: Text('Editar'),
                      ),
                      PopupMenuItem(
                        value: 'excluir',
                        child: Text('Excluir'),
                      ),
                    ],
                  ),
                ),
              );
            }),
            ],
          ),
        ),
      ),
    );
  }
}
