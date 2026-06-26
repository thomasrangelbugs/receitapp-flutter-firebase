import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/receitas_busca_controller.dart';
import '../../core/constants.dart';
import '../../core/error_handler.dart';
import '../../models/receita_model.dart';
import '../../services/auth_service.dart';
import '../../services/lista_service.dart';
import '../../services/receita_service.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/receita_card.dart';

class ReceitasScreen extends StatefulWidget {
  const ReceitasScreen({super.key});

  @override
  State<ReceitasScreen> createState() => _ReceitasScreenState();
}

class _ReceitasScreenState extends State<ReceitasScreen> {
  final _buscaController = TextEditingController();

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _excluirReceita(
    BuildContext context,
    ReceitaModel receita,
  ) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir receita?'),
          content: Text('Tem certeza que deseja excluir ${receita.titulo}?'),
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
      final userId = context.read<AuthService>().usuarioAtual?.uid;
      await context.read<ReceitaService>().excluir(receita.id);
      if (userId != null) {
        await context.read<ListaService>().removerReceitaDasListas(
              userId: userId,
              receitaId: receita.id,
            );
      }
      if (context.mounted) {
        ErrorHandler.mostrarSucesso(context, 'Receita excluida.');
      }
    } catch (erro) {
      if (context.mounted) {
        ErrorHandler.mostrarErro(context, 'Falha ao excluir receita.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final receitas = context.watch<List<ReceitaModel>>();
    final buscaController = context.watch<ReceitasBuscaController>();
    final receitasFiltradas = context
        .read<ReceitaService>()
        .filtrarPorTitulo(receitas, _buscaController.text);

    return Column(
      children: [
        if (buscaController.mostrarBusca)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _buscaController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Buscar receita...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _buscaController.clear();
                    buscaController.ocultar();
                    setState(() {});
                  },
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 600));
            },
            child: receitasFiltradas.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 60),
                      EmptyStateWidget(
                        icone: Icons.receipt_long,
                        titulo: buscaController.mostrarBusca
                            ? 'Nenhuma receita encontrada'
                            : 'Nenhuma receita cadastrada',
                        descricao: buscaController.mostrarBusca
                            ? 'Tente buscar com outro termo.'
                            : 'Adicione sua primeira receita.',
                        acao: ElevatedButton(
                          onPressed: () =>
                              context.go(Rotas.caminhoReceitaNova),
                          child: const Text('Nova receita'),
                        ),
                      ),
                    ],
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                    // Grid adaptativo: 1 coluna no celular, 2+ em telas largas.
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 460,
                      mainAxisExtent: 300,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: receitasFiltradas.length,
                    itemBuilder: (context, index) {
                      final receita = receitasFiltradas[index];
                      return ReceitaCard(
                        receita: receita,
                        onTap: () => context.go(
                          '${Rotas.caminhoReceitas}/${receita.id}',
                        ),
                        onEditar: () => context.go(
                          '${Rotas.caminhoReceitas}/${receita.id}/editar',
                        ),
                        onExcluir: () => _excluirReceita(context, receita),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
