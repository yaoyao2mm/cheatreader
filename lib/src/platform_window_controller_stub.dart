import 'platform_window_controller_base.dart';
import 'reader_settings.dart';
import 'package:flutter/material.dart';

class UnsupportedPlatformWindowController implements PlatformWindowController {
  @override
  bool get supportsFloatingControls => false;

  @override
  bool get supportsFramelessWindow => false;

  @override
  bool get supportsManualResize => false;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> prepareForControlPanel({required Size screenSize}) async {}

  @override
  Future<void> restoreAfterControlPanel(ReaderSettings settings) async {}

  @override
  Future<void> startDragging() async {}

  @override
  Future<void> resizeWindow(WindowResizeEdge edge, Offset delta) async {}

  @override
  Future<void> syncPresentation(ReaderSettings settings) async {}
}

PlatformWindowController createPlatformWindowControllerImpl() {
  return UnsupportedPlatformWindowController();
}
