import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum ReaderShortcutAction {
  nextLine,
  previousLine,
  nextPage,
  previousPage,
  toggleMode,
  bossKey,
  locateReader,
}

class ReaderShortcutKey {
  const ReaderShortcutKey({
    required this.logicalKeyId,
    this.shift = false,
    this.control = false,
    this.alt = false,
    this.meta = false,
    this.legacyName,
  });

  static const arrowDown = ReaderShortcutKey(
    logicalKeyId: 0x0010000301,
    legacyName: 'arrowDown',
  );
  static const arrowUp = ReaderShortcutKey(
    logicalKeyId: 0x0010000300,
    legacyName: 'arrowUp',
  );
  static const pageDown = ReaderShortcutKey(
    logicalKeyId: 0x0010000306,
    legacyName: 'pageDown',
  );
  static const pageUp = ReaderShortcutKey(
    logicalKeyId: 0x0010000305,
    legacyName: 'pageUp',
  );
  static const space = ReaderShortcutKey(
    logicalKeyId: 0x0000000020,
    legacyName: 'space',
  );
  static const shiftSpace = ReaderShortcutKey(
    logicalKeyId: 0x0000000020,
    shift: true,
    legacyName: 'shiftSpace',
  );
  static const keyJ = ReaderShortcutKey(
    logicalKeyId: 0x000000006a,
    legacyName: 'keyJ',
  );
  static const keyK = ReaderShortcutKey(
    logicalKeyId: 0x000000006b,
    legacyName: 'keyK',
  );
  static const keyN = ReaderShortcutKey(
    logicalKeyId: 0x000000006e,
    legacyName: 'keyN',
  );
  static const keyP = ReaderShortcutKey(
    logicalKeyId: 0x0000000070,
    legacyName: 'keyP',
  );
  static const keyM = ReaderShortcutKey(
    logicalKeyId: 0x000000006d,
    legacyName: 'keyM',
  );
  static const keyB = ReaderShortcutKey(
    logicalKeyId: 0x0000000062,
    legacyName: 'keyB',
  );
  static const controlShiftF = ReaderShortcutKey(
    logicalKeyId: 0x0000000066,
    shift: true,
    control: true,
    legacyName: 'controlShiftF',
  );

  static const legacyValues = <ReaderShortcutKey>[
    arrowDown,
    arrowUp,
    pageDown,
    pageUp,
    space,
    shiftSpace,
    keyJ,
    keyK,
    keyN,
    keyP,
    keyM,
    keyB,
    controlShiftF,
  ];

  final int logicalKeyId;
  final bool shift;
  final bool control;
  final bool alt;
  final bool meta;
  final String? legacyName;

  LogicalKeyboardKey get logicalKey => LogicalKeyboardKey(logicalKeyId);

  String get storageValue {
    for (final key in legacyValues) {
      if (key == this && key.legacyName != null) {
        return key.legacyName!;
      }
    }
    return [
      logicalKeyId.toRadixString(16),
      shift ? '1' : '0',
      control ? '1' : '0',
      alt ? '1' : '0',
      meta ? '1' : '0',
    ].join(':');
  }

  bool get isModifierOnly {
    return logicalKey == LogicalKeyboardKey.shift ||
        logicalKey == LogicalKeyboardKey.shiftLeft ||
        logicalKey == LogicalKeyboardKey.shiftRight ||
        logicalKey == LogicalKeyboardKey.control ||
        logicalKey == LogicalKeyboardKey.controlLeft ||
        logicalKey == LogicalKeyboardKey.controlRight ||
        logicalKey == LogicalKeyboardKey.alt ||
        logicalKey == LogicalKeyboardKey.altLeft ||
        logicalKey == LogicalKeyboardKey.altRight ||
        logicalKey == LogicalKeyboardKey.meta ||
        logicalKey == LogicalKeyboardKey.metaLeft ||
        logicalKey == LogicalKeyboardKey.metaRight;
  }

  SingleActivator toActivator() {
    return SingleActivator(
      logicalKey,
      shift: shift,
      control: control,
      alt: alt,
      meta: meta,
    );
  }

  factory ReaderShortcutKey.fromKeyEvent(KeyEvent event) {
    final pressed = HardwareKeyboard.instance.logicalKeysPressed;
    return ReaderShortcutKey(
      logicalKeyId: event.logicalKey.keyId,
      shift:
          pressed.contains(LogicalKeyboardKey.shiftLeft) ||
          pressed.contains(LogicalKeyboardKey.shiftRight) ||
          pressed.contains(LogicalKeyboardKey.shift),
      control:
          pressed.contains(LogicalKeyboardKey.controlLeft) ||
          pressed.contains(LogicalKeyboardKey.controlRight) ||
          pressed.contains(LogicalKeyboardKey.control),
      alt:
          pressed.contains(LogicalKeyboardKey.altLeft) ||
          pressed.contains(LogicalKeyboardKey.altRight) ||
          pressed.contains(LogicalKeyboardKey.alt),
      meta:
          pressed.contains(LogicalKeyboardKey.metaLeft) ||
          pressed.contains(LogicalKeyboardKey.metaRight) ||
          pressed.contains(LogicalKeyboardKey.meta),
    );
  }

  static ReaderShortcutKey fromStorageValue(
    String value,
    ReaderShortcutKey fallback,
  ) {
    for (final key in legacyValues) {
      if (key.legacyName == value) {
        return key;
      }
    }

    final parts = value.split(':');
    if (parts.length != 5) {
      return fallback;
    }

    final keyId = int.tryParse(parts[0], radix: 16);
    if (keyId == null) {
      return fallback;
    }

    bool parseFlag(String flag) => flag == '1';

    return ReaderShortcutKey(
      logicalKeyId: keyId,
      shift: parseFlag(parts[1]),
      control: parseFlag(parts[2]),
      alt: parseFlag(parts[3]),
      meta: parseFlag(parts[4]),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ReaderShortcutKey &&
        other.logicalKeyId == logicalKeyId &&
        other.shift == shift &&
        other.control == control &&
        other.alt == alt &&
        other.meta == meta;
  }

  @override
  int get hashCode => Object.hash(logicalKeyId, shift, control, alt, meta);
}

class ReaderShortcutBindings {
  const ReaderShortcutBindings({
    required this.nextLine,
    required this.previousLine,
    required this.nextPage,
    required this.previousPage,
    required this.toggleMode,
    required this.bossKey,
    required this.locateReader,
  });

  static const ReaderShortcutBindings defaults = ReaderShortcutBindings(
    nextLine: ReaderShortcutKey.arrowDown,
    previousLine: ReaderShortcutKey.arrowUp,
    nextPage: ReaderShortcutKey.pageDown,
    previousPage: ReaderShortcutKey.pageUp,
    toggleMode: ReaderShortcutKey.keyM,
    bossKey: ReaderShortcutKey.keyB,
    locateReader: ReaderShortcutKey.controlShiftF,
  );

  final ReaderShortcutKey nextLine;
  final ReaderShortcutKey previousLine;
  final ReaderShortcutKey nextPage;
  final ReaderShortcutKey previousPage;
  final ReaderShortcutKey toggleMode;
  final ReaderShortcutKey bossKey;
  final ReaderShortcutKey locateReader;

  ReaderShortcutKey keyForAction(ReaderShortcutAction action) {
    return switch (action) {
      ReaderShortcutAction.nextLine => nextLine,
      ReaderShortcutAction.previousLine => previousLine,
      ReaderShortcutAction.nextPage => nextPage,
      ReaderShortcutAction.previousPage => previousPage,
      ReaderShortcutAction.toggleMode => toggleMode,
      ReaderShortcutAction.bossKey => bossKey,
      ReaderShortcutAction.locateReader => locateReader,
    };
  }

  ReaderShortcutBindings copyWith({
    ReaderShortcutKey? nextLine,
    ReaderShortcutKey? previousLine,
    ReaderShortcutKey? nextPage,
    ReaderShortcutKey? previousPage,
    ReaderShortcutKey? toggleMode,
    ReaderShortcutKey? bossKey,
    ReaderShortcutKey? locateReader,
  }) {
    return ReaderShortcutBindings(
      nextLine: nextLine ?? this.nextLine,
      previousLine: previousLine ?? this.previousLine,
      nextPage: nextPage ?? this.nextPage,
      previousPage: previousPage ?? this.previousPage,
      toggleMode: toggleMode ?? this.toggleMode,
      bossKey: bossKey ?? this.bossKey,
      locateReader: locateReader ?? this.locateReader,
    );
  }

  ReaderShortcutBindings copyWithAction(
    ReaderShortcutAction action,
    ReaderShortcutKey key,
  ) {
    return switch (action) {
      ReaderShortcutAction.nextLine => copyWith(nextLine: key),
      ReaderShortcutAction.previousLine => copyWith(previousLine: key),
      ReaderShortcutAction.nextPage => copyWith(nextPage: key),
      ReaderShortcutAction.previousPage => copyWith(previousPage: key),
      ReaderShortcutAction.toggleMode => copyWith(toggleMode: key),
      ReaderShortcutAction.bossKey => copyWith(bossKey: key),
      ReaderShortcutAction.locateReader => copyWith(locateReader: key),
    };
  }

  ReaderShortcutAction? conflictingActionFor(
    ReaderShortcutKey key, {
    ReaderShortcutAction? excluding,
  }) {
    for (final action in ReaderShortcutAction.values) {
      if (action == excluding) {
        continue;
      }
      if (keyForAction(action) == key) {
        return action;
      }
    }
    return null;
  }

  Map<String, String> toJson() {
    return {
      'nextLine': nextLine.storageValue,
      'previousLine': previousLine.storageValue,
      'nextPage': nextPage.storageValue,
      'previousPage': previousPage.storageValue,
      'toggleMode': toggleMode.storageValue,
      'bossKey': bossKey.storageValue,
      'locateReader': locateReader.storageValue,
    };
  }

  factory ReaderShortcutBindings.fromJson(Map<String, dynamic> json) {
    ReaderShortcutKey decode(String key, ReaderShortcutKey fallback) {
      final rawValue = json[key];
      if (rawValue is! String) {
        return fallback;
      }
      return ReaderShortcutKey.fromStorageValue(rawValue, fallback);
    }

    return ReaderShortcutBindings(
      nextLine: decode('nextLine', defaults.nextLine),
      previousLine: decode('previousLine', defaults.previousLine),
      nextPage: decode('nextPage', defaults.nextPage),
      previousPage: decode('previousPage', defaults.previousPage),
      toggleMode: decode('toggleMode', defaults.toggleMode),
      bossKey: decode('bossKey', defaults.bossKey),
      locateReader: decode('locateReader', defaults.locateReader),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ReaderShortcutBindings &&
        other.nextLine == nextLine &&
        other.previousLine == previousLine &&
        other.nextPage == nextPage &&
        other.previousPage == previousPage &&
        other.toggleMode == toggleMode &&
        other.bossKey == bossKey &&
        other.locateReader == locateReader;
  }

  @override
  int get hashCode => Object.hash(
    nextLine,
    previousLine,
    nextPage,
    previousPage,
    toggleMode,
    bossKey,
    locateReader,
  );
}
