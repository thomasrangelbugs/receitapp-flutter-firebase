import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth/cadastro_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/listas/lista_detalhe_screen.dart';
import '../screens/listas/lista_form_screen.dart';
import '../screens/listas/listas_screen.dart';
import '../screens/receitas/receita_detalhe_screen.dart';
import '../screens/receitas/receita_form_screen.dart';
import '../screens/receitas/receitas_screen.dart';
import '../screens/timer/timer_screen.dart';
import '../services/auth_service.dart';
import '../widgets/common/nav_shell.dart';
import 'constants.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _homeNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _receitasNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _listasNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _timerNavigatorKey =
    GlobalKey<NavigatorState>();

GoRouter criarRouter(AuthService authService) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Rotas.caminhoSplash,
    refreshListenable: authService,
    redirect: (context, state) {
      final caminho = state.uri.path;
      final autenticado = authService.usuarioAtual != null;
      final rotaPublica = caminho == Rotas.caminhoLogin ||
          caminho == Rotas.caminhoCadastro;
      final rotaSplash = caminho == Rotas.caminhoSplash;

      if (!autenticado && !rotaPublica && !rotaSplash) {
        return Rotas.caminhoLogin;
      }
      if (autenticado && rotaPublica) {
        return Rotas.caminhoHome;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Rotas.caminhoSplash,
        name: Rotas.nomeSplash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Rotas.caminhoLogin,
        name: Rotas.nomeLogin,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Rotas.caminhoCadastro,
        name: Rotas.nomeCadastro,
        builder: (context, state) => const CadastroScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: Rotas.caminhoHome,
                name: Rotas.nomeHome,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _receitasNavigatorKey,
            routes: [
              GoRoute(
                path: Rotas.caminhoReceitas,
                name: Rotas.nomeReceitas,
                builder: (context, state) => const ReceitasScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _listasNavigatorKey,
            routes: [
              GoRoute(
                path: Rotas.caminhoListas,
                name: Rotas.nomeListas,
                builder: (context, state) => const ListasScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _timerNavigatorKey,
            routes: [
              GoRoute(
                path: Rotas.caminhoTimer,
                name: Rotas.nomeTimer,
                builder: (context, state) {
                  // Quando o usuario abre o timer a partir de uma etapa da
                  // receita, o tempo sugerido (em minutos) chega via `extra`.
                  final minutosIniciais =
                      state.extra is int ? state.extra as int : null;
                  return TimerScreen(minutosIniciais: minutosIniciais);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Rotas.caminhoReceitaNova,
        name: Rotas.nomeReceitaNova,
        builder: (context, state) => const ReceitaFormScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Rotas.caminhoReceitaDetalhe,
        name: Rotas.nomeReceitaDetalhe,
        builder: (context, state) {
          final idReceita = state.pathParameters['id'] ?? '';
          return ReceitaDetalheScreen(idReceita: idReceita);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Rotas.caminhoReceitaEditar,
        name: Rotas.nomeReceitaEditar,
        builder: (context, state) {
          final idReceita = state.pathParameters['id'] ?? '';
          return ReceitaFormScreen(idReceita: idReceita);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Rotas.caminhoListaNova,
        name: Rotas.nomeListaNova,
        builder: (context, state) => const ListaFormScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Rotas.caminhoListaDetalhe,
        name: Rotas.nomeListaDetalhe,
        builder: (context, state) {
          final idLista = state.pathParameters['id'] ?? '';
          return ListaDetalheScreen(idLista: idLista);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Rotas.caminhoListaEditar,
        name: Rotas.nomeListaEditar,
        builder: (context, state) {
          final idLista = state.pathParameters['id'] ?? '';
          return ListaFormScreen(idLista: idLista);
        },
      ),
    ],
  );
}
