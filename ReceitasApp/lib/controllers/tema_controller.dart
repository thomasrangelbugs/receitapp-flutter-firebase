import 'package:flutter/material.dart';

/// Controla o modo de tema (claro/escuro) do aplicativo.
///
/// Inicia seguindo o sistema e permite alternar manualmente pelo botao na
/// AppBar. Como estende [ChangeNotifier], qualquer widget que o observe e
/// reconstruido ao alternar o tema.
class TemaController extends ChangeNotifier {
  ThemeMode _modo = ThemeMode.system;

  /// Modo de tema atual.
  ThemeMode get modo => _modo;

  /// Indica se o tema escuro esta ativo, considerando tambem o modo "system".
  bool estaEscuro(BuildContext context) {
    if (_modo == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return _modo == ThemeMode.dark;
  }

  /// Alterna entre claro e escuro com base no estado visivel atual.
  void alternar(BuildContext context) {
    _modo = estaEscuro(context) ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
