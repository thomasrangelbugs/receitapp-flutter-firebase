# Como rodar o ReceitApp em outra máquina

Guia completo para instalar o ambiente e executar o app do zero.
Tempo estimado: 30–60 min (a maior parte é download).

> ⚠️ Observação importante: na máquina onde o projeto foi montado havia uma
> política de segurança corporativa (**WDAC / Device Guard**) que bloqueia
> executáveis não assinados, e isso impede o Flutter de rodar. Use uma máquina
> **sem essa restrição** (PC pessoal). Para checar, veja a seção “Solução de
> problemas” no fim.

---

## 1. Instalar o Flutter

### Windows
1. Baixe o Flutter SDK (canal stable): <https://docs.flutter.dev/get-started/install/windows>
2. Extraia para uma pasta sem espaços/permissões especiais, ex.: `C:\src\flutter`.
3. Adicione `C:\src\flutter\bin` ao **PATH** do usuário.
4. Abra um **novo** PowerShell e rode:
   ```powershell
   flutter --version
   flutter doctor
   ```

### macOS / Linux
Siga <https://docs.flutter.dev/get-started/install> e adicione `flutter/bin` ao PATH.

> O `flutter doctor` mostra o que falta. Para rodar no **Android**, instale o
> **Android Studio** (que traz o SDK + emulador). Para rodar no **Chrome (web)**,
> só precisa do Chrome instalado.

---

## 2. Abrir o projeto e baixar dependências

Copie a pasta `ReceitasApp` para a máquina e, dentro dela, rode:

```bash
flutter pub get
```

> Se a pasta `android/` der algum problema de Gradle, você pode regenerar os
> arquivos de plataforma mantendo o código com:
> ```bash
> flutter create --org br.diaboirl .
> ```
> Isso recria `android/ios/web` sem apagar a pasta `lib/`.

---

## 3. Configurar o Firebase (obrigatório)

Sem isso, login e banco de dados não funcionam. O passo a passo detalhado está
em [`MANUAL_FIREBASE.md`](MANUAL_FIREBASE.md). Resumo do caminho recomendado:

```bash
# Instalar CLIs
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli

# Conectar ao seu projeto Firebase (gera firebase_options.dart e google-services.json)
flutterfire configure
```

No Firebase Console, lembre de:
- Ativar **Authentication → E-mail/senha**.
- Criar o **Cloud Firestore** e publicar as regras (ver `MANUAL_FIREBASE.md`).

---

## 4. Rodar o app

Liste os dispositivos disponíveis e rode:

```bash
flutter devices

# Opção mais rápida (navegador):
flutter run -d chrome

# Em um emulador/celular Android:
flutter run
```

### Como testar
1. Crie uma conta na tela de **Cadastro**.
2. Crie uma **receita** (pode colar uma URL de imagem ou deixar em branco para
   usar uma imagem de exemplo automática).
3. Crie uma **lista** e adicione receitas.
4. Abra o **Timer**, defina um tempo curto e ouça o alarme ao zerar.
5. Toque no ícone de **lua/sol** na AppBar para alternar **tema claro/escuro**.

---

## 5. Gerar o APK (opcional, para entregar instalável)

```bash
flutter build apk --release
# Arquivo gerado em: build/app/outputs/flutter-apk/app-release.apk
```

---

## Solução de problemas

| Problema | Solução |
|---------|---------|
| `dart.exe ... bloqueado pela política do Device Guard` | Máquina com WDAC. Use outro PC ou peça liberação à TI. |
| `No Firebase App '[DEFAULT]'` ao abrir | Rode `flutterfire configure` (passo 3). |
| Build Android falha no `google-services` | Coloque o `google-services.json` real em `android/app/`. |
| Imagens não aparecem | Precisa de internet (as imagens de exemplo vêm da web). |
| `flutter doctor` reclama de licenças Android | Rode `flutter doctor --android-licenses` e aceite. |

> Para checar a política WDAC no Windows:
> ```powershell
> (Get-CimInstance -Namespace root\Microsoft\Windows\DeviceGuard -ClassName Win32_DeviceGuard).CodeIntegrityPolicyEnforcementStatus
> ```
> Resultado `2` = bloqueio ativo (não roda Flutter). `0` = sem bloqueio (ok).
