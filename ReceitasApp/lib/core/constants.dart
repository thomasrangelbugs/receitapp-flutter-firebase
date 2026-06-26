class ConstantesApp {
  static const String nomeApp = 'ReceitApp';
  static const Duration duracaoSplash = Duration(seconds: 2);
  static const double raioPadrao = 16;
  static const double espacoPadrao = 16;
}

class Rotas {
  static const String nomeSplash = 'splash';
  static const String nomeLogin = 'login';
  static const String nomeCadastro = 'cadastro';
  static const String nomeHome = 'home';
  static const String nomeReceitas = 'receitas';
  static const String nomeReceitaNova = 'receita_nova';
  static const String nomeReceitaDetalhe = 'receita_detalhe';
  static const String nomeReceitaEditar = 'receita_editar';
  static const String nomeListas = 'listas';
  static const String nomeListaNova = 'lista_nova';
  static const String nomeListaDetalhe = 'lista_detalhe';
  static const String nomeListaEditar = 'lista_editar';
  static const String nomeTimer = 'timer';

  static const String caminhoSplash = '/';
  static const String caminhoLogin = '/login';
  static const String caminhoCadastro = '/cadastro';
  static const String caminhoHome = '/home';
  static const String caminhoReceitas = '/receitas';
  static const String caminhoReceitaNova = '/receitas/nova';
  static const String caminhoReceitaDetalhe = '/receitas/:id';
  static const String caminhoReceitaEditar = '/receitas/:id/editar';
  static const String caminhoListas = '/listas';
  static const String caminhoListaNova = '/listas/nova';
  static const String caminhoListaDetalhe = '/listas/:id';
  static const String caminhoListaEditar = '/listas/:id/editar';
  static const String caminhoTimer = '/timer';
}
