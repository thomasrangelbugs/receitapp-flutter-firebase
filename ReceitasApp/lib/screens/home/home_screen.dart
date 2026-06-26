import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../models/lista_model.dart';
import '../../models/receita_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/receita_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final receitas = context.watch<List<ReceitaModel>>();
    final listas = context.watch<List<ListaModel>>();
    final usuario = context.read<AuthService>().usuarioAtual;
    final nomeUsuario = usuario?.displayName ?? 'Chef';
    final dataAtual = DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(
      DateTime.now(),
    );

    final receitaRecente = receitas.isNotEmpty ? receitas.first : null;
    final listaRecente = listas.isNotEmpty ? listas.first : null;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
          Text(
            'Ola, $nomeUsuario',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 4),
          Text(
            dataAtual,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _ResumoCard(
            totalReceitas: receitas.length,
            totalListas: listas.length,
          ),
          const SizedBox(height: 24),
          if (receitaRecente == null && listaRecente == null)
            EmptyStateWidget(
              icone: Icons.auto_awesome,
              titulo: 'Nenhuma receita ainda',
              descricao: 'Crie sua primeira receita para comecar.',
              acao: ElevatedButton(
                onPressed: () => context.go(Rotas.caminhoReceitaNova),
                child: const Text('Criar receita'),
              ),
            )
          else ...[
            _SecaoTitulo(
              titulo: 'Ultima receita adicionada',
              acao: TextButton(
                onPressed: () => context.go(Rotas.caminhoReceitas),
                child: const Text('Ver todas'),
              ),
            ),
            if (receitaRecente != null)
              _ReceitaResumo(receita: receitaRecente),
            const SizedBox(height: 20),
            _SecaoTitulo(
              titulo: 'Lista mais recente',
              acao: TextButton(
                onPressed: () => context.go(Rotas.caminhoListas),
                child: const Text('Ver listas'),
              ),
            ),
            if (listaRecente != null) _ListaResumo(lista: listaRecente),
          ],
          const SizedBox(height: 16),
          _SecaoTitulo(
            titulo: 'Acesso rapido',
            acao: const SizedBox.shrink(),
          ),
          Row(
            children: [
              Expanded(
                child: _BotaoAcao(
                  icone: Icons.add,
                  texto: 'Nova receita',
                  onTap: () => context.go(Rotas.caminhoReceitaNova),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BotaoAcao(
                  icone: Icons.playlist_add,
                  texto: 'Nova lista',
                  onTap: () => context.go(Rotas.caminhoListaNova),
                ),
              ),
            ],
          ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResumoCard extends StatelessWidget {
  final int totalReceitas;
  final int totalListas;

  const _ResumoCard({
    required this.totalReceitas,
    required this.totalListas,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ResumoItem(
              titulo: 'Receitas',
              valor: totalReceitas.toString(),
              icone: Icons.receipt_long,
            ),
            _ResumoItem(
              titulo: 'Listas',
              valor: totalListas.toString(),
              icone: Icons.list_alt,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumoItem extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;

  const _ResumoItem({
    required this.titulo,
    required this.valor,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icone, size: 28, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(valor, style: Theme.of(context).textTheme.titleLarge),
        Text(titulo),
      ],
    );
  }
}

class _SecaoTitulo extends StatelessWidget {
  final String titulo;
  final Widget acao;

  const _SecaoTitulo({
    required this.titulo,
    required this.acao,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(titulo, style: Theme.of(context).textTheme.titleLarge),
        acao,
      ],
    );
  }
}

class _ReceitaResumo extends StatelessWidget {
  final ReceitaModel receita;

  const _ReceitaResumo({required this.receita});

  @override
  Widget build(BuildContext context) {
    return ReceitaCard(
      receita: receita,
      onTap: () => context.go('${Rotas.caminhoReceitas}/${receita.id}'),
    );
  }
}

class _ListaResumo extends StatelessWidget {
  final ListaModel lista;

  const _ListaResumo({required this.lista});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.playlist_add_check),
        title: Text(lista.titulo),
        subtitle: Text('${lista.receitaIds.length} receitas'),
        onTap: () => context.go('${Rotas.caminhoListas}/${lista.id}'),
      ),
    );
  }
}

class _BotaoAcao extends StatelessWidget {
  final IconData icone;
  final String texto;
  final VoidCallback onTap;

  const _BotaoAcao({
    required this.icone,
    required this.texto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Icon(icone, size: 28),
              const SizedBox(height: 8),
              Text(texto, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
