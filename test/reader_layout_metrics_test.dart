import 'package:cheatreader/src/reader_layout_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('readerAutomaticSingleLineWidth', () {
    test('uses a compact automatic width on first entry to one-line mode', () {
      expect(
        readerAutomaticSingleLineWidth(currentWidth: 760, fontScale: 1),
        560,
      );
    });

    test('keeps narrower windows instead of forcing a wider one', () {
      expect(
        readerAutomaticSingleLineWidth(currentWidth: 420, fontScale: 1),
        420,
      );
    });

    test('widens moderately for larger fonts while staying bounded', () {
      expect(
        readerAutomaticSingleLineWidth(currentWidth: 760, fontScale: 1.3),
        680,
      );
    });
  });
}
