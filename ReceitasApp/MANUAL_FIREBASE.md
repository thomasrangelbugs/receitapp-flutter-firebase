# Manual de Configuração do Firebase — ReceitApp

Este guia mostra, **passo a passo**, como criar e conectar o projeto Firebase
ao app Flutter (`ReceitApp`). Ao final, login/cadastro e o banco de dados
(Firestore) estarão funcionando.

Há **dois caminhos**:

- ✅ **Caminho A (recomendado):** automático, usando o **FlutterFire CLI**.
- 🛠️ **Caminho B (manual):** configurando os arquivos na mão.

---

## Pré-requisitos

1. Conta Google (gratuita).
2. Flutter SDK instalado (`flutter doctor` sem erros).
3. Node.js instalado (para o Firebase CLI).

---

## 1. Criar o projeto no Firebase Console

1. Acesse <https://console.firebase.google.com> e clique em **“Adicionar projeto”**.
2. Dê um nome (ex.: `receitapp`) e avance.
3. O Google Analytics é **opcional** — pode desativar para simplificar.
4. Aguarde a criação e clique em **“Continuar”**.

---

## 2. Ativar a Autenticação (Authentication)

1. No menu lateral: **Criação → Authentication → Começar**.
2. Aba **“Sign-in method”** (Método de login).
3. Habilite **“E-mail/senha”** e **salve**.

> É esse provedor que o app usa em `AuthService.signIn` e `AuthService.signUp`.

---

## 3. Criar o banco Cloud Firestore

1. No menu lateral: **Criação → Firestore Database → Criar banco de dados**.
2. Escolha o local (ex.: `southamerica-east1` — São Paulo).
3. Inicie em **modo de produção** (vamos definir regras adequadas abaixo).
4. Após criado, vá na aba **“Regras”** (Rules) e cole as regras abaixo:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Cada usuário só acessa o próprio documento de perfil.
    match /usuarios/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Receitas: o dono (userId) pode ler/escrever as suas.
    match /receitas/{receitaId} {
      allow read, write: if request.auth != null
        && request.resource.data.userId == request.auth.uid;
      allow read, delete: if request.auth != null
        && resource.data.userId == request.auth.uid;
    }

    // Listas: mesma lógica das receitas.
    match /listas/{listaId} {
      allow read, write: if request.auth != null
        && request.resource.data.userId == request.auth.uid;
      allow read, delete: if request.auth != null
        && resource.data.userId == request.auth.uid;
    }
  }
}
```

5. Clique em **“Publicar”**.

> O app usa as coleções `usuarios`, `receitas` e `listas` (definidas em
> `services/auth_service.dart`, `receita_service.dart` e `lista_service.dart`).

---

## Caminho A — Configuração automática (recomendado)

Com o FlutterFire CLI o `lib/firebase_options.dart` e o
`android/app/google-services.json` são gerados automaticamente e corretos.

```bash
# 1. Instale o Firebase CLI e faça login
npm install -g firebase-tools
firebase login

# 2. Instale o FlutterFire CLI
dart pub global activate flutterfire_cli

# 3. Dentro da pasta do projeto, conecte ao seu projeto Firebase
flutterfire configure
```

No `flutterfire configure`:
- Selecione o projeto criado no passo 1.
- Marque as plataformas (no mínimo **Android**).
- Confirme o **applicationId**: `br.diaboirl.receitasapp`.

Pronto. Isso **sobrescreve** o `firebase_options.dart` e cria o
`google-services.json` com os valores reais. Depois:

```bash
flutter pub get
flutter run
```

---

## Caminho B — Configuração manual

Use este caminho se não quiser instalar os CLIs.

### B.1. Registrar o app Android no Console
1. Na visão geral do projeto, clique no ícone do **Android**.
2. **Nome do pacote (package name):** `br.diaboirl.receitasapp`
   (precisa ser idêntico ao `applicationId` em `android/app/build.gradle`).
3. Registre o app e **baixe o `google-services.json`**.
4. Substitua o arquivo modelo em:
   ```
   android/app/google-services.json
   ```

### B.2. Preencher o `firebase_options.dart`
No Console: **Configurações do projeto (⚙️) → Geral → Seus apps**.
Copie os valores e edite `lib/firebase_options.dart`, substituindo os
campos `SUA_CHAVE_API`, `appId`, `messagingSenderId`, `projectId` e
`storageBucket` pelos valores reais de cada plataforma.

Exemplo (Android):

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSy...sua_chave',
  appId: '1:123456789012:android:abcdef123456',
  messagingSenderId: '123456789012',
  projectId: 'receitapp-xxxx',
  storageBucket: 'receitapp-xxxx.appspot.com',
);
```

> Os arquivos já existem como **modelo** no projeto; basta substituir os valores.

---

## 4. Rodar e testar

```bash
flutter pub get
flutter run
```

1. Crie uma conta na tela de **Cadastro**.
2. No Console, em **Authentication → Users**, o novo usuário deve aparecer.
3. Crie uma receita; em **Firestore → Dados**, confira a coleção `receitas`.

---

## 5. Problemas comuns

| Sintoma | Causa provável | Solução |
|--------|----------------|---------|
| App fecha ao abrir / “No Firebase App” | `firebase_options.dart` com valores fake | Rode `flutterfire configure` ou preencha manualmente |
| Build Android falha no `google-services` | `google-services.json` ausente/errado | Baixe o arquivo real e coloque em `android/app/` |
| `package_name` não confere | Pacote diferente do `applicationId` | Use `br.diaboirl.receitasapp` em ambos |
| Login dá “PERMISSION_DENIED” no Firestore | Regras de segurança | Publique as regras do passo 3 |
| `minSdkVersion` | `firebase_auth` exige API 23+ | Já configurado como `minSdk = 23` |

---

## 6. Índices do Firestore (se necessário)

As consultas filtram por `userId` e ordenam por `dataCriacao`. Em alguns
casos o Firestore pede um **índice composto**. Se aparecer um erro no console
com um link, basta **clicar no link** que o Firebase cria o índice
automaticamente. Os índices necessários são:

- Coleção `receitas`: `userId` (==) + `dataCriacao` (desc)
- Coleção `listas`: `userId` (==) + `dataCriacao` (desc)
