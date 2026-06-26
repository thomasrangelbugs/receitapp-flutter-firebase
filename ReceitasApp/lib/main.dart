import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'controllers/tema_controller.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/lista_service.dart';
import 'services/receita_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('pt_BR', null);

  final provedores = [
    ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
    ChangeNotifierProvider<TemaController>(create: (_) => TemaController()),
    Provider<ReceitaService>(create: (_) => ReceitaService()),
    Provider<ListaService>(create: (_) => ListaService()),
  ];

  runApp(
    MultiProvider(
      providers: provedores,
      child: const ReceitApp(),
    ),
  );
}
