import 'package:flutter/material.dart';

import '../../core/imagens_receita.dart';
import '../../core/theme.dart';

/// Exibe a imagem de uma receita com cantos arredondados, estado de
/// carregamento e um fallback elegante (gradiente + icone) caso a imagem
/// nao carregue (sem internet, URL invalida, etc.).
class ReceitaImagem extends StatelessWidget {
  /// Chave estavel da receita (id ou titulo) para a imagem de exemplo.
  final String chave;

  /// URL informada pelo usuario (opcional).
  final String imagemUrl;

  /// Altura da imagem. Se nulo, ocupa o espaco disponivel.
  final double? altura;

  /// Largura da imagem. Se nulo, ocupa toda a largura.
  final double? largura;

  /// Raio dos cantos.
  final double raio;

  const ReceitaImagem({
    super.key,
    required this.chave,
    this.imagemUrl = '',
    this.altura,
    this.largura,
    this.raio = 0,
  });

  @override
  Widget build(BuildContext context) {
    final url = ImagensReceita.urlPara(chave: chave, imagemUrl: imagemUrl);

    return ClipRRect(
      borderRadius: BorderRadius.circular(raio),
      child: Image.network(
        url,
        height: altura,
        width: largura ?? double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progresso) {
          if (progresso == null) {
            return child;
          }
          return _Placeholder(altura: altura, carregando: true);
        },
        errorBuilder: (context, error, stack) {
          return _Placeholder(altura: altura, carregando: false);
        },
      ),
    );
  }
}

/// Fundo gradiente exibido durante o carregamento ou em caso de erro.
class _Placeholder extends StatelessWidget {
  final double? altura;
  final bool carregando;

  const _Placeholder({required this.altura, required this.carregando});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: altura,
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppTheme.gradientePrincipal),
      child: Center(
        child: carregando
            ? const SizedBox(
                height: 26,
                width: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : const Icon(
                Icons.restaurant_menu,
                color: Colors.white,
                size: 40,
              ),
      ),
    );
  }
}
