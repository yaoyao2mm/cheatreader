import 'package:cheatreader/src/boss_key_hotkey_registrar.dart';
import 'package:cheatreader/src/reader_shortcuts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('only non-text shortcuts are eligible for system-wide registration', () {
    expect(
      isSystemWideBossKeyEligible(ReaderShortcutKey.controlShiftB),
      isTrue,
    );
    expect(
      isSystemWideBossKeyEligible(
        ReaderShortcutKey(logicalKeyId: LogicalKeyboardKey.f5.keyId),
      ),
      isTrue,
    );
    expect(isSystemWideBossKeyEligible(ReaderShortcutKey.keyB), isFalse);
    expect(isSystemWideBossKeyEligible(ReaderShortcutKey.arrowDown), isFalse);
  });
}
