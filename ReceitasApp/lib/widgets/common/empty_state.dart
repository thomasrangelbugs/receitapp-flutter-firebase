import 'package:flutter/material.dart';

/// Widget reutilizavel para estados vazios.
class EmptyStateWidget extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String? descricao;
  final Widget? acao;

  const EmptyStateWidget({
    super.key,
    required this.icone,
    required this.titulo,
    this.descricao,
    this.acao,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icone, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            titulo,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          if (descricao != null) ...[
            const SizedBox(height: 8),
            Text(
              descricao!,
              textAlign: TextAlign.center,
            ),
          ],
          if (acao != null) ...[
            const SizedBox(height: 16),
            acao!,
          ],
        ],
      ),
    );
  }
}
