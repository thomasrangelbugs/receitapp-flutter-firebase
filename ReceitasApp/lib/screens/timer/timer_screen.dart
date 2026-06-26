import 'package:flutter/material.dart';

import '../../controllers/timer_controller.dart';

/// Tela do timer de cozinha (recurso extra).
///
/// Permite definir minutos e segundos, iniciar/pausar/reiniciar a contagem,
/// acompanhar o progresso visualmente e, ao chegar em 00:00, dispara um alarme
/// sonoro (via [TimerController]) e exibe a mensagem "Tempo esgotado!".
///
/// Esta tela e exibida como corpo do shell de navegacao, por isso NAO possui
/// Scaffold/AppBar proprios — eles vem do `NavShell`.
class TimerScreen extends StatefulWidget {
  /// Tempo sugerido (em minutos) quando o timer e aberto a partir de uma etapa.
  final int? minutosIniciais;

  const TimerScreen({super.key, this.minutosIniciais});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late final TimerController _controller;
  final _minutosController = TextEditingController(text: '0');
  final _segundosController = TextEditingController(text: '0');

  /// Evita exibir a mensagem de "tempo esgotado" mais de uma vez por contagem.
  bool _avisouTempoEsgotado = false;

  @override
  void initState() {
    super.initState();
    _controller = TimerController();
    _controller.addListener(_aoMudarController);

    // Se a tela foi aberta a partir de uma etapa, ja pre-configura o tempo.
    final minutos = widget.minutosIniciais;
    if (minutos != null && minutos > 0) {
      _minutosController.text = minutos.toString();
      _segundosController.text = '0';
      _controller.definirTempo(minutos, 0);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_aoMudarController);
    _controller.dispose();
    _minutosController.dispose();
    _segundosController.dispose();
    super.dispose();
  }

  /// Reage as mudancas do controller para exibir o aviso de tempo esgotado.
  void _aoMudarController() {
    if (_controller.concluido && !_avisouTempoEsgotado) {
      _avisouTempoEsgotado = true;
      // Adiado para fora do ciclo de notificacao/build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Tempo esgotado!'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      });
    }
    if (!_controller.concluido) {
      _avisouTempoEsgotado = false;
    }
  }

  /// Le os campos de minutos/segundos e aplica no controller.
  void _aplicarTempoDigitado() {
    final minutos = int.tryParse(_minutosController.text.trim()) ?? 0;
    final segundos = int.tryParse(_segundosController.text.trim()) ?? 0;
    _controller.definirTempo(minutos, segundos.clamp(0, 59));
  }

  /// Aplica um tempo rapido pre-definido (em minutos).
  void _aplicarPreset(int minutos) {
    _minutosController.text = minutos.toString();
    _segundosController.text = '0';
    _controller.definirTempo(minutos, 0);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          // Limita a largura para ficar agradavel em tablets/desktop.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _RelogioCircular(controller: _controller),
                    const SizedBox(height: 28),
                    _CamposDeTempo(
                      minutosController: _minutosController,
                      segundosController: _segundosController,
                      habilitado: !_controller.rodando,
                      onAlterado: _aplicarTempoDigitado,
                    ),
                    const SizedBox(height: 12),
                    _AtalhosDeTempo(
                      habilitado: !_controller.rodando,
                      onSelecionado: _aplicarPreset,
                    ),
                    const SizedBox(height: 24),
                    _Controles(controller: _controller),
                    if (_controller.alarmeAtivo) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _controller.pararAlarme,
                          icon: const Icon(Icons.notifications_off),
                          label: const Text('Parar alarme'),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Mostra a contagem regressiva grande dentro de um progresso circular.
class _RelogioCircular extends StatelessWidget {
  final TimerController controller;

  const _RelogioCircular({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 280, maxWidth: 280),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: controller.configurado ? controller.progresso : 0,
                strokeWidth: 12,
                backgroundColor: cores.primary.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                  controller.concluido ? cores.error : cores.primary,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.tempoFormatado,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 56,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.rodando
                      ? 'Em andamento'
                      : controller.concluido
                          ? 'Concluido'
                          : 'Pronto para iniciar',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Campos numericos para definir minutos e segundos.
class _CamposDeTempo extends StatelessWidget {
  final TextEditingController minutosController;
  final TextEditingController segundosController;
  final bool habilitado;
  final VoidCallback onAlterado;

  const _CamposDeTempo({
    required this.minutosController,
    required this.segundosController,
    required this.habilitado,
    required this.onAlterado,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: minutosController,
            enabled: habilitado,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(labelText: 'Minutos'),
            onChanged: (_) => onAlterado(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: segundosController,
            enabled: habilitado,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(labelText: 'Segundos'),
            onChanged: (_) => onAlterado(),
          ),
        ),
      ],
    );
  }
}

/// Botoes de atalho com tempos comuns de cozinha.
class _AtalhosDeTempo extends StatelessWidget {
  final bool habilitado;
  final ValueChanged<int> onSelecionado;

  const _AtalhosDeTempo({
    required this.habilitado,
    required this.onSelecionado,
  });

  @override
  Widget build(BuildContext context) {
    const presets = [1, 3, 5, 10, 15];
    return Wrap(
      spacing: 8,
      alignment: WrapAlignment.center,
      children: presets.map((minutos) {
        final rotulo = Text('$minutos min');
        // Quando o timer esta rodando, os atalhos ficam apenas informativos.
        return habilitado
            ? ActionChip(
                label: rotulo,
                onPressed: () => onSelecionado(minutos),
              )
            : Chip(label: rotulo);
      }).toList(),
    );
  }
}

/// Botoes Iniciar, Pausar e Reiniciar.
class _Controles extends StatelessWidget {
  final TimerController controller;

  const _Controles({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: controller.rodando || !controller.configurado
                ? null
                : controller.iniciar,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Iniciar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: controller.rodando ? controller.pausar : null,
            icon: const Icon(Icons.pause),
            label: const Text('Pausar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: controller.configurado ? controller.reiniciar : null,
            icon: const Icon(Icons.refresh),
            label: const Text('Reiniciar'),
          ),
        ),
      ],
    );
  }
}
