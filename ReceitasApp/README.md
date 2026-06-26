# ReceitApp — App de Receitas (Flutter + Firebase)

Aplicativo mobile de **receitas culinárias** desenvolvido em **Flutter + Dart**, com
**Firebase Authentication** (login/cadastro) e **Cloud Firestore** (banco de dados).
Cada usuário gerencia suas próprias receitas e listas, e ainda conta com um
**timer de cozinha com alarme sonoro** como recurso extra.

> Projeto acadêmico individual. Código em português, comentado e organizado,
> separando regras de negócio (`services`) da interface (`screens`/`widgets`).

---

## ✨ Funcionalidades

| Requisito do trabalho | Onde está implementado |
|-----------------------|------------------------|
| Login e cadastro de usuário | `screens/auth`, `services/auth_service.dart` |
| 2 CRUDs completos com validação | Receitas e Listas (`screens/receitas`, `screens/listas`) |
| Listagem / relatório dos dados | Listas com busca, ordenação e contagem |
| Menu de navegação centralizado | `BottomNavigationBar` em `widgets/common/nav_shell.dart` |
| Recurso extra | Timer com alarme (`screens/timer`, `controllers/timer_controller.dart`) |
| UI/UX cuidadosa e responsiva | Tema central (`core/theme.dart`) + layouts adaptáveis |

### Design e experiência
- **Visual moderno (Material 3):** paleta gastronômica (terracota + verde),
  tipografia Playfair Display + Inter, cards arredondados com banner de imagem
  e AppBar com gradiente.
- **Tema claro/escuro dinâmico:** botão na AppBar alterna instantaneamente
  (e respeita o tema do sistema por padrão).
- **Imagens em cada receita:** o usuário pode informar uma URL ou deixar em
  branco — nesse caso o app exibe automaticamente uma imagem de exemplo
  (estável por receita), com carregamento e fallback elegantes.
- **Responsivo:** grade adaptativa de receitas (1 coluna no celular, 2+ em
  telas largas) e conteúdo centralizado com largura máxima em telas grandes.

### Detalhes
- **Autenticação:** login, cadastro (com confirmação de senha), logout com
  confirmação e mensagens de erro amigáveis. Redirecionamento automático
  (logado → Início; deslogado → Login) via `go_router`.
- **CRUD de Receitas:** título, descrição, tempo de preparo, porções,
  ingredientes (nome/quantidade/unidade) e etapas numeradas com tempo opcional.
  Busca por título e exclusão com confirmação.
- **CRUD de Listas:** título e receitas vinculadas (seleção por checkbox),
  tela de detalhe com as receitas da lista e atalho para o detalhe de cada uma.
- **Timer:** define minutos/segundos, atalhos rápidos, contagem regressiva
  grande, progresso circular, alarme sonoro + vibração ao zerar e botão para
  parar o alarme. Pode ser aberto já preenchido a partir de uma etapa da receita.

---

## 🧱 Arquitetura

```
lib/
├── main.dart                # Bootstrap: Firebase, Providers e runApp
├── app.dart                 # MaterialApp.router + provedores de dados (streams)
├── firebase_options.dart    # Opções do Firebase por plataforma
├── core/                    # Tema, rotas, constantes e tratamento de erros
├── models/                  # ReceitaModel, ListaModel, IngredienteModel, EtapaModel
├── services/                # AuthService, ReceitaService, ListaService (Firestore)
├── controllers/             # TimerController, ReceitasBuscaController, TemaController
├── screens/
│   ├── auth/                # splash, login, cadastro
│   ├── home/                # tela inicial (resumo)
│   ├── receitas/            # lista, formulário, detalhe
│   ├── listas/              # lista, formulário, detalhe
│   └── timer/               # timer de cozinha
└── widgets/
    └── common/              # AppBar, EmptyState, logout, NavShell, ReceitaCard, ReceitaImagem
```

> Para instruções detalhadas de execução em outra máquina, veja
> [`COMO_RODAR.md`](COMO_RODAR.md).

**Padrões usados**
- **Provider** para injeção de dependências e estado reativo.
- **StreamProvider** (em `app.dart`) expõe as receitas/listas do usuário logado
  para toda a árvore, evitando erros de escopo nas telas de detalhe/formulário.
- **GoRouter** com `StatefulShellRoute` para o menu inferior persistente.

---

## 🛠️ Tecnologias

- Flutter 3.x / Dart 3.x
- `firebase_core`, `firebase_auth`, `cloud_firestore`
- `provider`, `go_router`
- `audioplayers` (alarme), `uuid`, `intl`, `google_fonts`

---

## 🚀 Como executar

> Pré-requisitos: [Flutter SDK](https://docs.flutter.dev/get-started/install)
> instalado e um dispositivo/emulador Android.

```bash
# 1. Instale as dependências
flutter pub get

# 2. Configure o Firebase (ver MANUAL_FIREBASE.md)
#    O jeito recomendado é o FlutterFire CLI:
dart pub global activate flutterfire_cli
flutterfire configure

# 3. Rode o app
flutter run
```

O **passo 2 é obrigatório**: sem um projeto Firebase real, o login e o banco
não funcionarão. O passo a passo completo (com prints conceituais) está em
[`MANUAL_FIREBASE.md`](MANUAL_FIREBASE.md).

> Caso falte alguma pasta de plataforma (iOS, Web, Windows), gere com:
> `flutter create .` (executado dentro da pasta do projeto). A pasta `android/`
> já vem pronta neste repositório.

---

## 🧪 Testes

```bash
flutter test
```

Há testes do `TimerController` e um smoke test de widget em `test/widget_test.dart`.

---

## 📁 Onde colocar as credenciais

| Plataforma | Arquivo | Observação |
|------------|---------|------------|
| Todas | `lib/firebase_options.dart` | Gerado pelo `flutterfire configure` |
| Android | `android/app/google-services.json` | Substitua o modelo pelo seu arquivo real |

Nunca versione credenciais reais em repositórios públicos.

---

## 📸 Telas (para o relatório)

Sugestão de prints a incluir na entrega: Splash, Login, Cadastro, Início,
Lista de Receitas, Formulário de Receita, Detalhe da Receita, Listas,
Detalhe da Lista e Timer em contagem.
