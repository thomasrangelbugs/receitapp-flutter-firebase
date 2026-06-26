import 'package:flutter/foundation.dart';

/// Controla a visibilidade da barra de busca em receitas.
class ReceitasBuscaController extends ChangeNotifier {
  bool _mostrarBusca = false;

  /// Indica se a barra de busca esta visivel.
  bool get mostrarBusca => _mostrarBusca;

  /// Alterna a visibilidade da busca.
  void alternar() {
    _mostrarBusca = !_mostrarBusca;
    notifyListeners();
  }

  /// Oculta a barra de busca.
  void ocultar() {
    if (_mostrarBusca) {
      _mostrarBusca = false;
      notifyListeners();
    }
  }
}
