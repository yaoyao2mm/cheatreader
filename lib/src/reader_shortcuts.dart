enum ReaderShortcutAction {
  nextLine,
  previousLine,
  nextPage,
  previousPage,
  toggleMode,
  bossKey,
}

enum ReaderShortcutKey {
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
}

class ReaderShortcutBindings {
  const ReaderShortcutBindings({
    required this.nextLine,
    required this.previousLine,
    required this.nextPage,
    required this.previousPage,
    required this.toggleMode,
    required this.bossKey,
  });

  static const ReaderShortcutBindings defaults = ReaderShortcutBindings(
    nextLine: ReaderShortcutKey.arrowDown,
    previousLine: ReaderShortcutKey.arrowUp,
    nextPage: ReaderShortcutKey.pageDown,
    previousPage: ReaderShortcutKey.pageUp,
    toggleMode: ReaderShortcutKey.keyM,
    bossKey: ReaderShortcutKey.keyB,
  );

  final ReaderShortcutKey nextLine;
  final ReaderShortcutKey previousLine;
  final ReaderShortcutKey nextPage;
  final ReaderShortcutKey previousPage;
  final ReaderShortcutKey toggleMode;
  final ReaderShortcutKey bossKey;

  ReaderShortcutKey keyForAction(ReaderShortcutAction action) {
    return switch (action) {
      ReaderShortcutAction.nextLine => nextLine,
      ReaderShortcutAction.previousLine => previousLine,
      ReaderShortcutAction.nextPage => nextPage,
      ReaderShortcutAction.previousPage => previousPage,
      ReaderShortcutAction.toggleMode => toggleMode,
      ReaderShortcutAction.bossKey => bossKey,
    };
  }

  ReaderShortcutBindings copyWith({
    ReaderShortcutKey? nextLine,
    ReaderShortcutKey? previousLine,
    ReaderShortcutKey? nextPage,
    ReaderShortcutKey? previousPage,
    ReaderShortcutKey? toggleMode,
    ReaderShortcutKey? bossKey,
  }) {
    return ReaderShortcutBindings(
      nextLine: nextLine ?? this.nextLine,
      previousLine: previousLine ?? this.previousLine,
      nextPage: nextPage ?? this.nextPage,
      previousPage: previousPage ?? this.previousPage,
      toggleMode: toggleMode ?? this.toggleMode,
      bossKey: bossKey ?? this.bossKey,
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
      'nextLine': nextLine.name,
      'previousLine': previousLine.name,
      'nextPage': nextPage.name,
      'previousPage': previousPage.name,
      'toggleMode': toggleMode.name,
      'bossKey': bossKey.name,
    };
  }

  factory ReaderShortcutBindings.fromJson(Map<String, dynamic> json) {
    ReaderShortcutKey decode(String key, ReaderShortcutKey fallback) {
      final rawValue = json[key];
      if (rawValue is! String) {
        return fallback;
      }
      return ReaderShortcutKey.values.byName(rawValue);
    }

    return ReaderShortcutBindings(
      nextLine: decode('nextLine', defaults.nextLine),
      previousLine: decode('previousLine', defaults.previousLine),
      nextPage: decode('nextPage', defaults.nextPage),
      previousPage: decode('previousPage', defaults.previousPage),
      toggleMode: decode('toggleMode', defaults.toggleMode),
      bossKey: decode('bossKey', defaults.bossKey),
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
        other.bossKey == bossKey;
  }

  @override
  int get hashCode => Object.hash(
    nextLine,
    previousLine,
    nextPage,
    previousPage,
    toggleMode,
    bossKey,
  );
}
