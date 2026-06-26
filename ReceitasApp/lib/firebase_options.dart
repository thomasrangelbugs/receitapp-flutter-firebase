import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        return android;
    }
  }

  // Substitua os valores abaixo pelos do seu projeto Firebase.
  // Para Android, adicione o google-services.json em android/app.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'SUA_CHAVE_API',
    appId: '1:000000000000:android:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'seu-projeto',
    storageBucket: 'seu-projeto.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'SUA_CHAVE_API',
    appId: '1:000000000000:ios:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'seu-projeto',
    storageBucket: 'seu-projeto.appspot.com',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'SUA_CHAVE_API',
    appId: '1:000000000000:web:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'seu-projeto',
    storageBucket: 'seu-projeto.appspot.com',
    authDomain: 'seu-projeto.firebaseapp.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'SUA_CHAVE_API',
    appId: '1:000000000000:windows:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'seu-projeto',
    storageBucket: 'seu-projeto.appspot.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'SUA_CHAVE_API',
    appId: '1:000000000000:linux:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'seu-projeto',
    storageBucket: 'seu-projeto.appspot.com',
  );
}
