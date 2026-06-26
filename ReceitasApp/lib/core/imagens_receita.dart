/// Utilitario para obter a imagem de uma receita.
///
/// Se o usuario informou uma URL, ela e usada. Caso contrario, escolhemos
/// uma imagem de comida de exemplo de forma deterministica (sempre a mesma
/// para a mesma receita), usando um servico publico de fotos.
class ImagensReceita {
  ImagensReceita._();

  /// Quantidade de variacoes de imagem de exemplo.
  static const int _totalExemplos = 30;

  /// Retorna a URL da imagem a ser exibida para a receita.
  ///
  /// [imagemUrl] tem prioridade; [chave] (id ou titulo) garante que a imagem
  /// de exemplo seja estavel para a mesma receita.
  static String urlPara({required String chave, String imagemUrl = ''}) {
    if (imagemUrl.trim().isNotEmpty) {
      return imagemUrl.trim();
    }
    final semente = chave.isEmpty ? 'receita' : chave;
    final indice = (semente.hashCode.abs() % _totalExemplos) + 1;
    // loremflickr entrega uma foto de comida estavel para cada "lock".
    return 'https://loremflickr.com/800/600/food,dish?lock=$indice';
  }
}
