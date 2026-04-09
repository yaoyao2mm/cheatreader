import 'dart:ui';

import 'reader_settings.dart';

enum WindowResizeEdge {
  left,
  top,
  right,
  bottom,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

abstract class PlatformWindowController {
  bool get supportsFloatingControls;

  bool get supportsFramelessWindow;

  bool get supportsManualResize;

  bool get supportsBossKey;

  Future<void> initialize();

  Future<void> prepareForControlPanel({required Size screenSize});

  Future<void> restoreAfterControlPanel(ReaderSettings settings);

  Future<void> syncPresentation(ReaderSettings settings);

  Future<void> bringToForegroundFromSystemActivation();

  Future<void> startDragging();

  Future<void> resizeWindow(WindowResizeEdge edge, Offset delta);

  Future<void> hideForBossKey(ReaderSettings settings);

  Future<void> restoreFromBossKey(ReaderSettings settings);

  Future<void> closeWindow();
}
