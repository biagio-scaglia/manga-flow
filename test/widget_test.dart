import 'package:flutter_test/flutter_test.dart';
import 'package:manga_library/domain/entities/reading_status.dart';

void main() {
  test('Smoke test inizializzazione entità applicative', () {
    expect(ReadingStatus.reading.label, equals('In lettura'));
    expect(ReadingStatus.planToRead.label, equals('Da leggere'));
    expect(ReadingStatus.completed.label, equals('Completato'));
  });
}
