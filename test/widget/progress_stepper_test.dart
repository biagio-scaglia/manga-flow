import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_library/presentation/widgets/progress_stepper.dart';

void main() {
  testWidgets('ProgressStepper incrementa e decrementa correttamente', (
    tester,
  ) async {
    int current = 10;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return ProgressStepper(
                currentChapter: current,
                totalChapters: 20,
                onProgressChanged: (val) => setState(() => current = val),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('CAPITOLO 10'), findsOneWidget);
    expect(find.text('su 20 totali'), findsOneWidget);

    // Tap sul pulsante +
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();

    expect(current, equals(11));

    // Tap sul pulsante -
    await tester.tap(find.byIcon(Icons.remove_rounded));
    await tester.pump();

    expect(current, equals(10));
  });

  testWidgets(
    'ProgressStepper mostra suggerimento completamento al capitolo finale',
    (tester) async {
      bool completedPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProgressStepper(
              currentChapter: 50,
              totalChapters: 50,
              onProgressChanged: (_) {},
              onMarkCompleted: () => completedPressed = true,
            ),
          ),
        ),
      );

      expect(
        find.text('OPERA CONCLUSA: SEGNA COME COMPLETATO'),
        findsOneWidget,
      );

      await tester.tap(find.text('OPERA CONCLUSA: SEGNA COME COMPLETATO'));
      await tester.pump();

      expect(completedPressed, isTrue);
    },
  );
}
