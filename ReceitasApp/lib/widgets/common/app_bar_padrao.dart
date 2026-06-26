import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/tema_controller.dart';
import '../../core/theme.dart';
import 'logout_button.dart';

/// AppBar padrao do aplicativo.
///
/// Aplica o gradiente da identidade visual, um botao para alternar entre tema
/// claro/escuro e (opcionalmente) o botao de logout. Mantem a aparencia
/// consistente em todas as telas.
class AppBarPadrao extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  final List<Widget> acoes;
  final bool mostrarVoltar;
  final bool mostrarLogout;

  const AppBarPadrao({
    super.key,
    required this.titulo,
    this.acoes = const [],
    this.mostrarVoltar = false,
    this.mostrarLogout = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final temaController = context.watch<TemaController>();
    final escuro = temaController.estaEscuro(context);

    return AppBar(
      title: Text(titulo),
      automaticallyImplyLeading: mostrarVoltar,
      // Gradiente quente da identidade visual.
      flexibleSpace: const DecoratedBox(
        decoration: BoxDecoration(gradient: AppTheme.gradientePrincipal),
      ),
      actions: [
        ...acoes,
        IconButton(
          tooltip: escuro ? 'Tema claro' : 'Tema escuro',
          icon: Icon(escuro ? Icons.light_mode : Icons.dark_mode),
          onPressed: () => context.read<TemaController>().alternar(context),
        ),
        if (mostrarLogout) const BotaoLogout(),
      ],
    );
  }
}
