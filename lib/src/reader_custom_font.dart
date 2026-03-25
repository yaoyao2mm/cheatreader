import 'dart:io';

import 'package:flutter/services.dart';

String readerCustomFontFamilyForPath(String path) {
  final hash = _stableHash(path);
  return 'CheatReaderCustomFont_$hash';
}

Future<bool> ensureReaderCustomFontLoaded(String path) async {
  final normalizedPath = path.trim();
  if (normalizedPath.isEmpty) {
    return false;
  }

  final family = readerCustomFontFamilyForPath(normalizedPath);
  if (_loadedFamilies.contains(family)) {
    return true;
  }

  try {
    final bytes = await File(normalizedPath).readAsBytes();
    if (bytes.isEmpty) {
      return false;
    }

    final loader = FontLoader(family);
    loader.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
    await loader.load();
    _loadedFamilies.add(family);
    return true;
  } catch (_) {
    return false;
  }
}

final Set<String> _loadedFamilies = <String>{};

String _stableHash(String value) {
  var hash = 0x811C9DC5;
  for (final codeUnit in value.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash.toRadixString(16);
}
