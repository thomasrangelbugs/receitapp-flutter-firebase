import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/error_handler.dart';
import '../../models/receita_model.dart';
import '../../services/auth_service.dart';
import '../../services/lista_service.dart';
import '../../services/receita_service.dart';
import '../../widgets/common/app_bar_padrao.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/receita_imagem.dart';

class ReceitaDetalheScreen extends StatelessWidget {
  final String idReceita;

  const ReceitaDetalheScreen({super.key, required this.idReceita});

  Future<void> _excluirReceita(BuildContext context, ReceitaModel receita) async {
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
        context.pop();
      }
    } catch (erro) {
      if (context.mounted) {
        ErrorHandler.mostrarErro(context, 'Falha ao excluir receita.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final receitaService = context.read<ReceitaService>();

    return FutureBuilder<ReceitaModel?>(
      future: receitaService.buscarPorId(idReceita),
      builder: (context, snapshot) {
        final receita = snapshot.data;
        return Scaffold(
          appBar: AppBarPadrao(
            titulo: 'Detalhe da receita',
            mostrarVoltar: true,
            acoes: receita == null
                ? []
                : [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Editar',
                      onPressed: () => context.go(
                        '${Rotas.caminhoReceitas}/${receita.id}/editar',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Excluir',
                      onPressed: () => _excluirReceita(context, receita),
                    ),
                  ],
          ),
          body: Builder(
            builder: (context) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (receita == null) {
                return const EmptyStateWidget(
                  icone: Icons.error_outline,
                  titulo: 'Receita nao encontrada',
                  descricao: 'Tente voltar e acessar novamente.',
                );
              }

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  ReceitaImagem(
                    chave: receita.id.isNotEmpty
                        ? receita.id
                        : receita.titulo,
                    imagemUrl: receita.imagemUrl,
                    altura: 220,
                    raio: 22,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    receita.titulo,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(receita.descricao),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icone: Icons.timer,
                        texto: '${receita.tempoPreparo} min',
                      ),
                      _InfoChip(
                        icone: Icons.restaurant,
                        texto: '${receita.porcoes} porcoes',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Ingredientes',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  ...receita.ingredientes.map(
                    (ingrediente) => ListTile(
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(ingrediente.nome),
                      subtitle: Text(
                        '${ingrediente.quantidade} ${ingrediente.unidade}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Modo de preparo',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  ...receita.etapas.map(
                    (etapa) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Etapa ${etapa.ordem}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(etapa.descricao),
                            if (etapa.tempoPasso != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${etapa.tempoPasso} min',
                                  ),
                                  const Spacer(),
                                  TextButton.icon(
                                    onPressed: () {
                                      context.go(
                                        Rotas.caminhoTimer,
                                        extra: etapa.tempoPasso,
                                      );
                                    },
                                    icon: const Icon(Icons.play_arrow),
                                    label: const Text('Iniciar timer'),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icone;
  final String texto;

  const _InfoChip({required this.icone, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icone, size: 18),
      label: Text(texto),
    );
  }
}
