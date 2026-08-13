import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import 'reader_shortcuts.dart';

abstract class BossKeyHotkeyRegistrar {
  Future<bool> register(ReaderShortcutKey key, Future<void> Function() handler);

  Future<void> unregister();
}

bool isSystemWideBossKeyEligible(ReaderShortcutKey key) {
  if (key.control || key.alt || key.shift || key.meta) {
    return true;
  }

  final logicalKey = key.logicalKey;
  return logicalKey.keyId >= LogicalKeyboardKey.f1.keyId &&
      logicalKey.keyId <= LogicalKeyboardKey.f24.keyId;
}

class DesktopBossKeyHotkeyRegistrar implements BossKeyHotkeyRegistrar {
  HotKey? _registeredHotKey;

  bool get _supportsSystemHotkeys {
    if (kIsWeb) {
      return false;
    }

    if (defaultTargetPlatform == TargetPlatform.linux) {
      return Platform.environment['XDG_SESSION_TYPE']?.toLowerCase() !=
          'wayland';
    }

    return defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows;
  }

  @override
  Future<bool> register(
    ReaderShortcutKey key,
    Future<void> Function() handler,
  ) async {
    await unregister();
    if (!_supportsSystemHotkeys || !isSystemWideBossKeyEligible(key)) {
      return false;
    }

    final modifiers = <HotKeyModifier>[
      if (key.control) HotKeyModifier.control,
      if (key.alt) HotKeyModifier.alt,
      if (key.shift) HotKeyModifier.shift,
      if (key.meta) HotKeyModifier.meta,
    ];
    final hotKey = HotKey(
      identifier: 'cheatreader.boss-key',
      key: key.logicalKey,
      modifiers: modifiers,
      scope: HotKeyScope.system,
    );

    try {
      await hotKeyManager.register(
        hotKey,
        keyDownHandler: (_) {
          unawaited(handler());
        },
      );
      _registeredHotKey = hotKey;
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> unregister() async {
    final hotKey = _registeredHotKey;
    _registeredHotKey = null;
    if (hotKey == null) {
      return;
    }

    try {
      await hotKeyManager.unregister(hotKey);
    } catch (_) {
      // Keep window-local shortcuts and tray recovery available when a desktop
      // rejects registration or disappears during shutdown.
    }
  }
}
