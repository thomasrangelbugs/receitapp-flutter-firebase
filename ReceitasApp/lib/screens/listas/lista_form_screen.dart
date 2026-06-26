import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/error_handler.dart';
import '../../models/lista_model.dart';
import '../../models/receita_model.dart';
import '../../services/auth_service.dart';
import '../../services/lista_service.dart';
import '../../widgets/common/app_bar_padrao.dart';
import '../../widgets/common/empty_state.dart';

/// Tela de criacao e edicao de listas.
class ListaFormScreen extends StatefulWidget {
  final String? idLista;

  const ListaFormScreen({super.key, this.idLista});

  @override
  State<ListaFormScreen> createState() => _ListaFormScreenState();
}

class _ListaFormScreenState extends State<ListaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _buscaController = TextEditingController();
  final Set<String> _selecionadas = {};
  bool _carregando = false;
  bool _inicializado = false;
  DateTime? _dataCriacao;

  @override
  void dispose() {
    _tituloController.dispose();
    _buscaController.dispose();
    super.dispose();
  }

  void _preencherDados(List<ListaModel> listas) {
    if (_inicializado || widget.idLista == null) {
      return;
    }
    final lista = listas.where((item) => item.id == widget.idLista).toList();
    if (lista.isEmpty) {
      return;
    }
    final atual = lista.first;
    _tituloController.text = atual.titulo;
    _selecionadas
      ..clear()
      ..addAll(atual.receitaIds);
    _dataCriacao = atual.dataCriacao;
    _inicializado = true;
  }

  Future<void> _salvar() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_selecionadas.isEmpty) {
      ErrorHandler.mostrarErro(
        context,
        'Selecione pelo menos uma receita.',
      );
      return;
    }

    setState(() => _carregando = true);
    try {
      final userId = context.read<AuthService>().usuarioAtual?.uid;
      if (userId == null) {
        throw 'Usuario nao autenticado.';
      }

      final lista = ListaModel(
        id: widget.idLista ?? '',
        userId: userId,
        titulo: _tituloController.text.trim(),
        receitaIds: _selecionadas.toList(),
        dataCriacao: _dataCriacao ?? DateTime.now(),
      );

      final service = context.read<ListaService>();
      if (widget.idLista == null) {
        await service.criar(lista);
        if (mounted) {
          ErrorHandler.mostrarSucesso(context, 'Lista criada.');
        }
      } else {
        await service.atualizar(lista);
        if (mounted) {
          ErrorHandler.mostrarSucesso(context, 'Lista atualizada.');
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (erro) {
      if (mounted) {
        ErrorHandler.mostrarErro(
          context,
          erro is String ? erro : 'Nao foi possivel salvar a lista.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final listas = context.watch<List<ListaModel>>();
    final receitas = context.watch<List<ReceitaModel>>();
    _preencherDados(listas);

    final termo = _buscaController.text.trim().toLowerCase();
    final receitasFiltradas = termo.isEmpty
        ? receitas
        : receitas
            .where(
              (receita) => receita.titulo.toLowerCase().contains(termo),
            )
            .toList();

    return Scaffold(
      appBar: AppBarPadrao(
        titulo: widget.idLista == null ? 'Nova lista' : 'Editar lista',
        mostrarVoltar: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(labelText: 'Titulo'),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Informe um titulo.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _buscaController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar receitas',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: receitasFiltradas.isEmpty
                      ? const EmptyStateWidget(
                          icone: Icons.restaurant,
                          titulo: 'Nenhuma receita encontrada',
                          descricao: 'Crie receitas para montar suas listas.',
                        )
                      : ListView.builder(
                          itemCount: receitasFiltradas.length,
                          itemBuilder: (context, index) {
                            final receita = receitasFiltradas[index];
                            final selecionado =
                                _selecionadas.contains(receita.id);
                            return CheckboxListTile(
                              value: selecionado,
                              title: Text(receita.titulo),
                              subtitle: Text(
                                '${receita.tempoPreparo} min • ${receita.porcoes} porcoes',
                              ),
                              onChanged: (valor) {
                                setState(() {
                                  if (valor == true) {
                                    _selecionadas.add(receita.id);
                                  } else {
                                    _selecionadas.remove(receita.id);
                                  }
                                });
                              },
                            );
                          },
                        ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : _salvar,
                    child: _carregando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Salvar lista'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
