import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_library/domain/entities/reading_status.dart';
import 'package:manga_library/presentation/widgets/status_badge.dart';

void main() {
  testWidgets('StatusBadge mostra etichetta corretta in italiano', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatusBadge(status: ReadingStatus.reading),
        ),
      ),
    );

    expect(find.text('IN LETTURA'), findsOneWidget);
  });

  testWidgets('StatusBadge modalità compatta per card', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatusBadge(status: ReadingStatus.completed, isCompact: true),
        ),
      ),
    );

    expect(find.text('COMPLETATO'), findsOneWidget);
  });
}
