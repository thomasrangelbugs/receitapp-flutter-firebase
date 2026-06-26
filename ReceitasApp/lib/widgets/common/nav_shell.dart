import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/receitas_busca_controller.dart';
import '../../core/constants.dart';
import 'app_bar_padrao.dart';

/// Shell com a navegacao inferior e a AppBar dinamica do aplicativo.
///
/// Envolve as 4 abas principais (Inicio, Receitas, Listas e Timer). Os fluxos
/// de dados (receitas/listas) e o [ReceitasBuscaController] sao fornecidos no
/// nivel do app (ver `app.dart`), garantindo acesso consistente tanto aqui
/// quanto nas telas filhas.
class NavShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const NavShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarPadrao(
        titulo: _tituloAtual(navigationShell.currentIndex),
        acoes: _acoesParaIndex(context, navigationShell.currentIndex),
      ),
      body: navigationShell,
      floatingActionButton:
          _fabParaIndex(context, navigationShell.currentIndex),
        bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => _irParaBranch(index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Receitas',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Listas',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Timer',
          ),
        ],
      ),
    );
  }

  void _irParaBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  String _tituloAtual(int index) {
    switch (index) {
      case 0:
        return 'Inicio';
      case 1:
        return 'Receitas';
      case 2:
        return 'Listas';
      case 3:
        return 'Timer';
      default:
        return 'ReceitApp';
    }
  }

  List<Widget> _acoesParaIndex(BuildContext context, int index) {
    switch (index) {
      case 1:
        return [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Pesquisar',
            onPressed: () {
              context.read<ReceitasBuscaController>().alternar();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nova receita',
            onPressed: () => context.go(Rotas.caminhoReceitaNova),
          ),
        ];
      case 2:
        return [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nova lista',
            onPressed: () => context.go(Rotas.caminhoListaNova),
          ),
        ];
      default:
        return [];
    }
  }

  Widget? _fabParaIndex(BuildContext context, int index) {
    switch (index) {
      case 1:
        return FloatingActionButton(
          onPressed: () => context.go(Rotas.caminhoReceitaNova),
          child: const Icon(Icons.add),
        );
      case 2:
        return FloatingActionButton(
          onPressed: () => context.go(Rotas.caminhoListaNova),
          child: const Icon(Icons.playlist_add),
        );
      default:
        return null;
    }
  }
}
