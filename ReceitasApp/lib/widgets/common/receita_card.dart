import 'package:flutter/material.dart';

import '../../models/receita_model.dart';
import 'receita_imagem.dart';

/// Card moderno de receita com banner de imagem, titulo e informacoes rapidas.
///
/// Reutilizado na listagem de receitas e na tela inicial. Quando [onEditar] ou
/// [onExcluir] sao informados, exibe um menu de acoes sobre a imagem.
class ReceitaCard extends StatelessWidget {
  final ReceitaModel receita;
  final VoidCallback onTap;
  final VoidCallback? onEditar;
  final VoidCallback? onExcluir;

  const ReceitaCard({
    super.key,
    required this.receita,
    required this.onTap,
    this.onEditar,
    this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final temMenu = onEditar != null || onExcluir != null;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ReceitaImagem(
                  chave: receita.id.isNotEmpty ? receita.id : receita.titulo,
                  imagemUrl: receita.imagemUrl,
                  altura: 150,
                ),
                // Leve sombreado na base para dar profundidade.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.25),
                        ],
                      ),
                    ),
                  ),
                ),
                if (temMenu)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Material(
                      color: Colors.black.withOpacity(0.35),
                      shape: const CircleBorder(),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onSelected: (valor) {
                          if (valor == 'editar') {
                            onEditar?.call();
                          } else if (valor == 'excluir') {
                            onExcluir?.call();
                          }
                        },
                        itemBuilder: (context) => [
                          if (onEditar != null)
                            const PopupMenuItem(
                              value: 'editar',
                              child: Text('Editar'),
                            ),
                          if (onExcluir != null)
                            const PopupMenuItem(
                              value: 'excluir',
                              child: Text('Excluir'),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receita.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (receita.descricao.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      receita.descricao,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _Marcador(
                        icone: Icons.timer_outlined,
                        texto: '${receita.tempoPreparo} min',
                      ),
                      const SizedBox(width: 10),
                      _Marcador(
                        icone: Icons.restaurant_outlined,
                        texto: '${receita.porcoes} porcoes',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pequeno marcador com icone + texto (tempo, porcoes, etc.).
class _Marcador extends StatelessWidget {
  final IconData icone;
  final String texto;

  const _Marcador({required this.icone, required this.texto});

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 16, color: cor),
        const SizedBox(width: 4),
        Text(texto, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
