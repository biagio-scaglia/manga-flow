import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_library/presentation/widgets/empty_state.dart';

void main() {
  testWidgets('EmptyState mostra titolo, messaggio e trigger azione', (tester) async {
    bool actionTriggered = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyState(
            icon: Icons.menu_book_rounded,
            title: 'Libreria vuota',
            message: 'Aggiungi il tuo primo manga.',
            actionLabel: 'Cerca Manga',
            onAction: () => actionTriggered = true,
          ),
        ),
      ),
    );

    expect(find.text('LIBRERIA VUOTA'), findsOneWidget);
    expect(find.text('Aggiungi il tuo primo manga.'), findsOneWidget);
    expect(find.text('CERCA MANGA'), findsOneWidget);

    await tester.tap(find.text('CERCA MANGA'));
    await tester.pump();

    expect(actionTriggered, isTrue);
  });
}
