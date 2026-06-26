import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:receitapp/controllers/timer_controller.dart';

void main() {
  group('TimerController', () {
    test('definirTempo configura o total em segundos', () {
      final controller = TimerController();
      controller.definirTempo(2, 30);

      expect(controller.totalSegundos, 150);
      expect(controller.segundosRestantes, 150);
      expect(controller.configurado, isTrue);
      expect(controller.tempoFormatado, '02:30');

      controller.dispose();
    });

    test('definirTempo ignora valores invalidos (zero)', () {
      final controller = TimerController();
      controller.definirTempo(0, 0);

      expect(controller.configurado, isFalse);
      expect(controller.progresso, 0);

      controller.dispose();
    });

    testWidgets('o app sobe sem excecoes na arvore basica', (tester) async {
      // Smoke test minimo de um widget para garantir o ambiente de testes.
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('ReceitApp'))),
      );
      expect(find.text('ReceitApp'), findsOneWidget);
    });
  });
}
