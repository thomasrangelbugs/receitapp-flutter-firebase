import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Controla a logica do timer de cozinha.
class TimerController extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  Timer? _timer;
  Timer? _vibracaoTimer;
  Timer? _alarmeTimer;

  int _totalSegundos = 0;
  int _segundosRestantes = 0;
  bool _rodando = false;
  bool _concluido = false;
  bool _alarmeAtivo = false;

  /// Indica se o timer esta rodando.
  bool get rodando => _rodando;

  /// Indica se o timer foi concluido.
  bool get concluido => _concluido;

  /// Indica se o alarme esta tocando.
  bool get alarmeAtivo => _alarmeAtivo;

  /// Tempo total configurado em segundos.
  int get totalSegundos => _totalSegundos;

  /// Tempo restante em segundos.
  int get segundosRestantes => _segundosRestantes;

  /// Retorna o progresso de 0.0 a 1.0.
  double get progresso {
    if (_totalSegundos == 0) {
      return 0;
    }
    return _segundosRestantes / _totalSegundos;
  }

  /// Retorna o tempo formatado.
  String get tempoFormatado {
    final minutos = _segundosRestantes ~/ 60;
    final segundos = _segundosRestantes % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
  }

  /// Indica se o timer possui tempo configurado.
  bool get configurado => _totalSegundos > 0;

  /// Define o tempo do timer.
  void definirTempo(int minutos, int segundos) {
    final total = (minutos * 60) + segundos;
    if (total <= 0) {
      return;
    }
    _totalSegundos = total;
    _segundosRestantes = total;
    _concluido = false;
    _rodando = false;
    notifyListeners();
  }

  /// Inicia a contagem.
  void iniciar() {
    if (_rodando || _segundosRestantes <= 0) {
      return;
    }
    _rodando = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_segundosRestantes <= 1) {
        _segundosRestantes = 0;
        _finalizar();
      } else {
        _segundosRestantes--;
        notifyListeners();
      }
    });
    notifyListeners();
  }

  /// Pausa a contagem.
  void pausar() {
    _timer?.cancel();
    _rodando = false;
    notifyListeners();
  }

  /// Reinicia o timer com o tempo inicial.
  void reiniciar() {
    _timer?.cancel();
    _pararAlarmeInterno();
    _segundosRestantes = _totalSegundos;
    _rodando = false;
    _concluido = false;
    notifyListeners();
  }

  /// Para o alarme manualmente.
  Future<void> pararAlarme() async {
    await _pararAlarmeInterno();
    notifyListeners();
  }

  Future<void> _finalizar() async {
    _timer?.cancel();
    _rodando = false;
    _concluido = true;
    notifyListeners();
    await _tocarAlarme();
  }

  Future<void> _tocarAlarme() async {
    if (_alarmeAtivo) {
      return;
    }
    _alarmeAtivo = true;
    notifyListeners();

    await _player.setReleaseMode(ReleaseMode.loop);
    try {
      // Som empacotado no app (funciona offline).
      await _player.play(AssetSource('sounds/alarme.wav'));
    } catch (_) {
      // Fallback: caso o asset nao esteja disponivel, usa um som online.
      try {
        await _player.play(
          UrlSource(
            'https://actions.google.com/sounds/v1/alarms/beep_short.ogg',
          ),
        );
      } catch (_) {
        // Sem audio disponivel: mantemos apenas a vibracao/aviso visual.
      }
    }

    _vibracaoTimer?.cancel();
    _vibracaoTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => HapticFeedback.heavyImpact(),
    );
    _alarmeTimer?.cancel();
    _alarmeTimer = Timer(
      const Duration(seconds: 30),
      () => _pararAlarmeInterno(),
    );
  }

  Future<void> _pararAlarmeInterno() async {
    _alarmeTimer?.cancel();
    _vibracaoTimer?.cancel();
    _alarmeAtivo = false;
    await _player.stop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _vibracaoTimer?.cancel();
    _alarmeTimer?.cancel();
    _player.dispose();
    super.dispose();
  }
}
