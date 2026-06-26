import 'package:flutter/material.dart';

/// Utilitario para exibir mensagens de erro ou sucesso.
class ErrorHandler {
  /// Exibe um SnackBar de erro.
  static void mostrarErro(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  /// Exibe um SnackBar de sucesso.
  static void mostrarSucesso(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }
}
