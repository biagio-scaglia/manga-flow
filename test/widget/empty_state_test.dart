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

    expect(find.text('Libreria vuota'), findsOneWidget);
    expect(find.text('Aggiungi il tuo primo manga.'), findsOneWidget);
    expect(find.text('Cerca Manga'), findsOneWidget);

    await tester.tap(find.text('Cerca Manga'));
    await tester.pump();

    expect(actionTriggered, isTrue);
  });
}
