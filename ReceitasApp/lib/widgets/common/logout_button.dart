import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/error_handler.dart';
import '../../services/auth_service.dart';

/// Botao de logout com confirmacao.
class BotaoLogout extends StatelessWidget {
  const BotaoLogout({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Sair',
      onPressed: () => _confirmarLogout(context),
    );
  }

  Future<void> _confirmarLogout(BuildContext context) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sair da conta?'),
          content: const Text('Voce sera desconectado do aplicativo.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );

    if (confirmou != true) {
      return;
    }

    try {
      await context.read<AuthService>().signOut();
      if (context.mounted) {
        context.go(Rotas.caminhoLogin);
      }
    } catch (erro) {
      if (context.mounted) {
        ErrorHandler.mostrarErro(
          context,
          'Nao foi possivel sair. Tente novamente.',
        );
      }
    }
  }
}
