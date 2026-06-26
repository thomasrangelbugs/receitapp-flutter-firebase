import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'controllers/receitas_busca_controller.dart';
import 'controllers/tema_controller.dart';
import 'core/constants.dart';
import 'core/routes.dart';
import 'core/theme.dart';
import 'models/lista_model.dart';
import 'models/receita_model.dart';
import 'services/auth_service.dart';
import 'services/lista_service.dart';
import 'services/receita_service.dart';

/// Widget raiz do aplicativo.
///
/// Responsavel por:
/// - Construir o [GoRouter] uma unica vez (guardado em [_router]).
/// - Disponibilizar, acima do [MaterialApp], os fluxos (streams) de receitas e
///   listas do usuario logado. Manter esses provedores no topo garante que
///   QUALQUER tela (inclusive as abertas no navigator raiz, como detalhe e
///   formulario) tenha acesso aos dados sem lancar `ProviderNotFoundException`.
class ReceitApp extends StatefulWidget {
  const ReceitApp({super.key});

  @override
  State<ReceitApp> createState() => _ReceitAppState();
}

class _ReceitAppState extends State<ReceitApp> {
  GoRouter? _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // O router e criado apenas uma vez, reaproveitando o AuthService como
    // refreshListenable para reagir a login/logout.
    _router ??= criarRouter(context.read<AuthService>());
  }

  @override
  Widget build(BuildContext context) {
    // Observa o controller de tema para alternar claro/escuro dinamicamente.
    final temaController = context.watch<TemaController>();

    return _ProvedoresDeDados(
      child: MaterialApp.router(
        title: ConstantesApp.nomeApp,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.claro,
        darkTheme: AppTheme.escuro,
        themeMode: temaController.modo,
        routerConfig: _router,
      ),
    );
  }
}

/// Disponibiliza os dados do usuario (receitas e listas) para toda a arvore.
///
/// Observa o [AuthService]: sempre que o usuario muda (login/logout), os
/// streams sao recriados com o novo `userId`. Quando nao ha usuario logado,
/// fornecemos listas vazias para evitar leituras desnecessarias no Firestore.
class _ProvedoresDeDados extends StatelessWidget {
  final Widget child;

  const _ProvedoresDeDados({required this.child});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final receitaService = context.read<ReceitaService>();
    final listaService = context.read<ListaService>();
    final userId = authService.usuarioAtual?.uid;

    final streamReceitas = userId == null
        ? Stream<List<ReceitaModel>>.value(const [])
        : receitaService.listar(userId);
    final streamListas = userId == null
        ? Stream<List<ListaModel>>.value(const [])
        : listaService.listar(userId);

    return MultiProvider(
      providers: [
        StreamProvider<List<ReceitaModel>>.value(
          value: streamReceitas,
          initialData: const [],
          catchError: (_, __) => const [],
        ),
        StreamProvider<List<ListaModel>>.value(
          value: streamListas,
          initialData: const [],
          catchError: (_, __) => const [],
        ),
        // Controla a barra de busca da aba de receitas. Fica no topo para que
        // tanto a AppBar (no NavShell) quanto a tela de receitas o acessem.
        ChangeNotifierProvider<ReceitasBuscaController>(
          create: (_) => ReceitasBuscaController(),
        ),
      ],
      child: child,
    );
  }
}
