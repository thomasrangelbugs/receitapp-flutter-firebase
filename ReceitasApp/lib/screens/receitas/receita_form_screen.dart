import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/error_handler.dart';
import '../../models/etapa_model.dart';
import '../../models/ingrediente_model.dart';
import '../../models/receita_model.dart';
import '../../services/auth_service.dart';
import '../../services/receita_service.dart';
import '../../widgets/common/app_bar_padrao.dart';
import '../../widgets/common/receita_imagem.dart';

/// Tela de criacao e edicao de receitas.
class ReceitaFormScreen extends StatefulWidget {
  final String? idReceita;

  const ReceitaFormScreen({super.key, this.idReceita});

  @override
  State<ReceitaFormScreen> createState() => _ReceitaFormScreenState();
}

class _ReceitaFormScreenState extends State<ReceitaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _tempoController = TextEditingController();
  final _porcoesController = TextEditingController();
  final _imagemController = TextEditingController();
  final List<_IngredienteForm> _ingredientes = [];
  final List<_EtapaForm> _etapas = [];

  bool _carregando = false;
  bool _carregandoInicial = false;
  bool _erroIngredientes = false;
  bool _erroEtapas = false;
  DateTime? _dataCriacao;

  @override
  void initState() {
    super.initState();
    if (widget.idReceita != null) {
      _carregarReceita();
    } else {
      _adicionarIngrediente();
      _adicionarEtapa();
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _tempoController.dispose();
    _porcoesController.dispose();
    _imagemController.dispose();
    for (final item in _ingredientes) {
      item.dispose();
    }
    for (final etapa in _etapas) {
      etapa.dispose();
    }
    super.dispose();
  }

  Future<void> _carregarReceita() async {
    setState(() => _carregandoInicial = true);
    final receitaService = context.read<ReceitaService>();
    final receita = await receitaService.buscarPorId(widget.idReceita!);
    if (receita == null) {
      if (mounted) {
        ErrorHandler.mostrarErro(context, 'Receita nao encontrada.');
        Navigator.of(context).pop();
      }
      return;
    }

    _tituloController.text = receita.titulo;
    _descricaoController.text = receita.descricao;
    _tempoController.text = receita.tempoPreparo.toString();
    _porcoesController.text = receita.porcoes.toString();
    _imagemController.text = receita.imagemUrl;
    _dataCriacao = receita.dataCriacao;

    _ingredientes.clear();
    for (final ingrediente in receita.ingredientes) {
      _ingredientes.add(
        _IngredienteForm(
          nome: ingrediente.nome,
          quantidade: ingrediente.quantidade,
          unidade: ingrediente.unidade,
        ),
      );
    }
    _etapas.clear();
    for (final etapa in receita.etapas) {
      _etapas.add(
        _EtapaForm(
          descricao: etapa.descricao,
          tempoPasso: etapa.tempoPasso,
        ),
      );
    }

    setState(() => _carregandoInicial = false);
  }

  void _adicionarIngrediente() {
    setState(() {
      _ingredientes.add(_IngredienteForm());
      _erroIngredientes = false;
    });
  }

  void _removerIngrediente(int index) {
    setState(() {
      _ingredientes.removeAt(index).dispose();
    });
  }

  void _adicionarEtapa() {
    setState(() {
      _etapas.add(_EtapaForm());
      _erroEtapas = false;
    });
  }

  void _removerEtapa(int index) {
    setState(() {
      _etapas.removeAt(index).dispose();
    });
  }

  void _moverEtapa(int index, int delta) {
    final novoIndex = index + delta;
    if (novoIndex < 0 || novoIndex >= _etapas.length) {
      return;
    }
    setState(() {
      final etapa = _etapas.removeAt(index);
      _etapas.insert(novoIndex, etapa);
    });
  }

  bool _validarListas() {
    setState(() {
      _erroIngredientes = _ingredientes.isEmpty;
      _erroEtapas = _etapas.isEmpty;
    });
    return !_erroIngredientes && !_erroEtapas;
  }

  Future<void> _salvar() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (!_validarListas()) {
      return;
    }

    setState(() => _carregando = true);
    try {
      final userId = context.read<AuthService>().usuarioAtual?.uid;
      if (userId == null) {
        throw 'Usuario nao autenticado.';
      }

      final ingredientes = _ingredientes
          .map(
            (item) => IngredienteModel(
              nome: item.nomeController.text.trim(),
              quantidade: item.quantidadeController.text.trim(),
              unidade: item.unidade,
            ),
          )
          .toList();

      final etapas = <EtapaModel>[];
      for (var i = 0; i < _etapas.length; i++) {
        final etapa = _etapas[i];
        final tempoTexto = etapa.tempoController.text.trim();
        final tempo = tempoTexto.isEmpty ? null : int.tryParse(tempoTexto);
        etapas.add(
          EtapaModel(
            ordem: i + 1,
            descricao: etapa.descricaoController.text.trim(),
            tempoPasso: tempo,
          ),
        );
      }

      final tempoPreparo = int.parse(_tempoController.text.trim());
      final porcoes = int.parse(_porcoesController.text.trim());
      final dataCriacao = _dataCriacao ?? DateTime.now();

      final receita = ReceitaModel(
        id: widget.idReceita ?? '',
        userId: userId,
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        tempoPreparo: tempoPreparo,
        porcoes: porcoes,
        imagemUrl: _imagemController.text.trim(),
        ingredientes: ingredientes,
        etapas: etapas,
        dataCriacao: dataCriacao,
      );

      final receitaService = context.read<ReceitaService>();
      if (widget.idReceita == null) {
        await receitaService.criar(receita);
        if (mounted) {
          ErrorHandler.mostrarSucesso(context, 'Receita criada.');
        }
      } else {
        await receitaService.atualizar(receita);
        if (mounted) {
          ErrorHandler.mostrarSucesso(context, 'Receita atualizada.');
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (erro) {
      if (mounted) {
        ErrorHandler.mostrarErro(
          context,
          erro is String ? erro : 'Nao foi possivel salvar a receita.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  String? _validarTexto(String? valor, String mensagem) {
    if (valor == null || valor.trim().isEmpty) {
      return mensagem;
    }
    return null;
  }

  String? _validarNumero(String? valor, String mensagem) {
    if (valor == null || valor.trim().isEmpty) {
      return mensagem;
    }
    final numero = int.tryParse(valor);
    if (numero == null || numero <= 0) {
      return 'Informe um valor valido.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final tituloAppBar =
        widget.idReceita == null ? 'Nova receita' : 'Editar receita';

    if (_carregandoInicial) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBarPadrao(
        titulo: tituloAppBar,
        mostrarVoltar: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Informacoes basicas',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(labelText: 'Titulo'),
                  validator: (valor) =>
                      _validarTexto(valor, 'Informe o titulo.'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descricaoController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Descricao'),
                  validator: (valor) =>
                      _validarTexto(valor, 'Informe a descricao.'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _tempoController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Tempo (min)',
                        ),
                        validator: (valor) =>
                            _validarNumero(valor, 'Informe o tempo.'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _porcoesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Porcoes',
                        ),
                        validator: (valor) =>
                            _validarNumero(valor, 'Informe as porcoes.'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: ReceitaImagem(
                    chave: _tituloController.text,
                    imagemUrl: _imagemController.text,
                    altura: 160,
                    raio: 18,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _imagemController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'URL da imagem (opcional)',
                    helperText: 'Deixe em branco para usar uma imagem de exemplo',
                    prefixIcon: Icon(Icons.image_outlined),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ingredientes',
                        style: Theme.of(context).textTheme.titleLarge),
                    TextButton.icon(
                      onPressed: _adicionarIngrediente,
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar'),
                    ),
                  ],
                ),
                if (_erroIngredientes)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Adicione pelo menos 1 ingrediente.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ..._ingredientes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: item.nomeController,
                            decoration:
                                const InputDecoration(labelText: 'Ingrediente'),
                            validator: (valor) =>
                                _validarTexto(valor, 'Informe o ingrediente.'),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: item.quantidadeController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Quantidade',
                                  ),
                                  validator: (valor) => _validarTexto(
                                    valor,
                                    'Informe a quantidade.',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: item.unidade,
                                  items: _unidades
                                      .map(
                                        (unidade) => DropdownMenuItem(
                                          value: unidade,
                                          child: Text(unidade),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (valor) {
                                    setState(() {
                                      item.unidade = valor ?? _unidades.first;
                                    });
                                  },
                                  decoration:
                                      const InputDecoration(labelText: 'Unidade'),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _removerIngrediente(index),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Modo de preparo',
                        style: Theme.of(context).textTheme.titleLarge),
                    TextButton.icon(
                      onPressed: _adicionarEtapa,
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar'),
                    ),
                  ],
                ),
                if (_erroEtapas)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Adicione pelo menos 1 etapa.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ..._etapas.asMap().entries.map((entry) {
                  final index = entry.key;
                  final etapa = entry.value;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text('Etapa ${index + 1}'),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.arrow_upward),
                                onPressed: () => _moverEtapa(index, -1),
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_downward),
                                onPressed: () => _moverEtapa(index, 1),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _removerEtapa(index),
                              ),
                            ],
                          ),
                          TextFormField(
                            controller: etapa.descricaoController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Descricao',
                            ),
                            validator: (valor) {
                              if (valor == null || valor.trim().isEmpty) {
                                return 'Informe a etapa.';
                              }
                              if (valor.trim().length < 10) {
                                return 'Use pelo menos 10 caracteres.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: etapa.tempoController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Tempo estimado (min)',
                            ),
                            validator: (valor) {
                              if (valor == null || valor.trim().isEmpty) {
                                return null;
                              }
                              final numero = int.tryParse(valor);
                              if (numero == null || numero <= 0) {
                                return 'Informe um tempo valido.';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
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
                        : const Text('Salvar receita'),
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

const List<String> _unidades = [
  'g',
  'kg',
  'ml',
  'l',
  'xicara',
  'colher',
  'unidade',
];

class _IngredienteForm {
  final TextEditingController nomeController;
  final TextEditingController quantidadeController;
  String unidade;

  _IngredienteForm({
    String? nome,
    String? quantidade,
    this.unidade = 'g',
  })  : nomeController = TextEditingController(text: nome ?? ''),
        quantidadeController = TextEditingController(text: quantidade ?? '');

  void dispose() {
    nomeController.dispose();
    quantidadeController.dispose();
  }
}

class _EtapaForm {
  final TextEditingController descricaoController;
  final TextEditingController tempoController;

  _EtapaForm({String? descricao, int? tempoPasso})
      : descricaoController = TextEditingController(text: descricao ?? ''),
        tempoController = TextEditingController(
          text: tempoPasso == null ? '' : tempoPasso.toString(),
        );

  void dispose() {
    descricaoController.dispose();
    tempoController.dispose();
  }
}
