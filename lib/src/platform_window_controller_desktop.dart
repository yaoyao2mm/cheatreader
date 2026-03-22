import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'platform_window_controller_base.dart';
import 'reader_layout_metrics.dart';
import 'reader_settings.dart';

class DesktopPlatformWindowController implements PlatformWindowController {
  static const double _minimumWidth = readerMinimumWidth;
  static const double _minimumMultiLineHeight = readerMinimumMultiLineHeight;
  static const Size _minimumSize = Size(_minimumWidth, _minimumMultiLineHeight);
  static const Size _normalSize = Size(760, 308);
  static const Size _controlPanelSize = Size(760, 760);

  Offset? _controlPanelRestorePosition;
  Size? _controlPanelRestoreSize;
  bool? _lastOneLineMode;
  Size? _rememberedMultiLineSize;
  double? _rememberedOneLineWidth;
  bool _bossKeyHidden = false;

  bool get _isSupportedDesktop {
    if (kIsWeb) {
      return false;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.macOS ||
      TargetPlatform.windows ||
      TargetPlatform.linux => true,
      _ => false,
    };
  }

  bool get _useNativeLinuxFrameless =>
      _isSupportedDesktop && defaultTargetPlatform == TargetPlatform.linux;

  bool get _useFramelessWindow {
    if (!_isSupportedDesktop) {
      return false;
    }

    // Linux uses a native undecorated window from the GTK runner instead of
    // toggling frameless mode after launch through window_manager.
    return defaultTargetPlatform != TargetPlatform.linux;
  }

  double get _absoluteMinimumOneLineHeight {
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      // Native title bars on macOS consume part of the total window height.
      return 72;
    }
    return 28;
  }

  @override
  bool get supportsFloatingControls => _isSupportedDesktop;

  @override
  bool get supportsFramelessWindow =>
      _useFramelessWindow || _useNativeLinuxFrameless;

  @override
  bool get supportsManualResize =>
      _isSupportedDesktop && defaultTargetPlatform != TargetPlatform.macOS;

  @override
  bool get supportsBossKey => _isSupportedDesktop;

  @override
  Future<void> initialize() async {
    if (!_isSupportedDesktop) {
      return;
    }

    await windowManager.ensureInitialized();
    final titleBarStyle = _useNativeLinuxFrameless
        ? null
        : (_useFramelessWindow ? TitleBarStyle.hidden : TitleBarStyle.normal);
    final windowOptions = WindowOptions(
      size: _normalSize,
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: titleBarStyle,
      windowButtonVisibility: !_useFramelessWindow,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setTitle('CheatReader');
      await windowManager.setResizable(true);
      await windowManager.setMinimumSize(_minimumSize);
      if (_useFramelessWindow) {
        await windowManager.setAsFrameless();
      }
      await windowManager.setOpacity(1.0);
      if (_useFramelessWindow) {
        await windowManager.setHasShadow(false);
      }
      await windowManager.show();
      await windowManager.focus();
    });
  }

  @override
  Future<void> prepareForControlPanel({required Size screenSize}) async {
    if (!_isSupportedDesktop) {
      return;
    }

    _controlPanelRestorePosition ??= await windowManager.getPosition();
    final currentSize = await windowManager.getSize();
    if (_lastOneLineMode == true) {
      _rememberedOneLineWidth = _normalizeOneLineWidth(currentSize.width);
    } else {
      _rememberedMultiLineSize = _normalizeMultiLineSize(currentSize);
    }
    _controlPanelRestoreSize ??= currentSize;
    final maxX = math.max(0.0, screenSize.width - _controlPanelSize.width);
    final maxY = math.max(0.0, screenSize.height - _controlPanelSize.height);
    final restorePosition = _controlPanelRestorePosition!;
    final availableBelow =
        screenSize.height - (restorePosition.dy + currentSize.height);
    final expandsDown =
        availableBelow >= (_controlPanelSize.height - currentSize.height) ||
        restorePosition.dy < screenSize.height / 2;
    final targetPosition = Offset(
      restorePosition.dx.clamp(0.0, maxX),
      expandsDown
          ? restorePosition.dy.clamp(0.0, maxY)
          : (restorePosition.dy + currentSize.height - _controlPanelSize.height)
                .clamp(0.0, maxY),
    );

    await windowManager.setMinimumSize(_minimumSize);
    await windowManager.setBounds(
      null,
      position: targetPosition,
      size: _controlPanelSize,
      animate: true,
    );
    await windowManager.focus();
  }

  @override
  Future<void> startDragging() async {
    if (!_isSupportedDesktop) {
      return;
    }

    await windowManager.startDragging();
  }

  @override
  Future<void> resizeWindow(WindowResizeEdge edge, Offset delta) async {
    if (!_isSupportedDesktop || _controlPanelRestorePosition != null) {
      return;
    }

    final position = await windowManager.getPosition();
    final size = await windowManager.getSize();
    var left = position.dx;
    var top = position.dy;
    var width = size.width;
    var height = size.height;

    switch (edge) {
      case WindowResizeEdge.left:
        left += delta.dx;
        width -= delta.dx;
      case WindowResizeEdge.top:
        top += delta.dy;
        height -= delta.dy;
      case WindowResizeEdge.right:
        width += delta.dx;
      case WindowResizeEdge.bottom:
        height += delta.dy;
      case WindowResizeEdge.topLeft:
        left += delta.dx;
        width -= delta.dx;
        top += delta.dy;
        height -= delta.dy;
      case WindowResizeEdge.topRight:
        width += delta.dx;
        top += delta.dy;
        height -= delta.dy;
      case WindowResizeEdge.bottomLeft:
        left += delta.dx;
        width -= delta.dx;
        height += delta.dy;
      case WindowResizeEdge.bottomRight:
        width += delta.dx;
        height += delta.dy;
    }

    if (width < _minimumSize.width) {
      if (edge == WindowResizeEdge.left ||
          edge == WindowResizeEdge.topLeft ||
          edge == WindowResizeEdge.bottomLeft) {
        left -= _minimumSize.width - width;
      }
      width = _minimumSize.width;
    }

    final minHeight = _lastOneLineMode == true
        ? _absoluteMinimumOneLineHeight
        : _minimumMultiLineHeight;
    if (height < minHeight) {
      if (edge == WindowResizeEdge.top ||
          edge == WindowResizeEdge.topLeft ||
          edge == WindowResizeEdge.topRight) {
        top -= minHeight - height;
      }
      height = minHeight;
    }

    if (_lastOneLineMode == true) {
      _rememberedOneLineWidth = _normalizeOneLineWidth(width);
    } else {
      _rememberedMultiLineSize = _normalizeMultiLineSize(Size(width, height));
    }

    await windowManager.setBounds(
      null,
      position: Offset(left, top),
      size: Size(width, height),
      animate: false,
    );
  }

  @override
  Future<void> closeWindow() async {
    if (!_isSupportedDesktop) {
      return;
    }

    await windowManager.close();
  }

  @override
  Future<void> hideForBossKey(ReaderSettings settings) async {
    if (!_isSupportedDesktop || _bossKeyHidden) {
      return;
    }

    _bossKeyHidden = true;
    await windowManager.setAlwaysOnTop(false);
    await windowManager.setIgnoreMouseEvents(true);
    await windowManager.setOpacity(0.0);
  }

  @override
  Future<void> restoreFromBossKey(ReaderSettings settings) async {
    if (!_isSupportedDesktop || !_bossKeyHidden) {
      return;
    }

    _bossKeyHidden = false;
    await windowManager.setIgnoreMouseEvents(false);
    await windowManager.setOpacity(1.0);
    await syncPresentation(settings);
    await windowManager.show();
    await windowManager.focus();
  }

  @override
  Future<void> syncPresentation(ReaderSettings settings) async {
    if (!_isSupportedDesktop) {
      return;
    }

    if (_bossKeyHidden) {
      return;
    }

    if (_useFramelessWindow) {
      await windowManager.setAsFrameless();
      await windowManager.setHasShadow(false);
    }
    await windowManager.setAlwaysOnTop(settings.alwaysOnTop);
    await windowManager.setOpacity(1.0);

    if (_controlPanelRestorePosition != null) {
      return;
    }

    final currentSize = await windowManager.getSize();
    if (_lastOneLineMode == true) {
      _rememberedOneLineWidth = _normalizeOneLineWidth(currentSize.width);
    } else {
      _rememberedMultiLineSize = _normalizeMultiLineSize(currentSize);
    }
    final targetSize = _targetReaderSize(
      currentSize: currentSize,
      settings: settings,
    );
    _lastOneLineMode = settings.oneLineMode;

    await windowManager.setMinimumSize(_minimumWindowSizeFor(settings));
    await windowManager.setBounds(null, size: targetSize, animate: true);
  }

  @override
  Future<void> restoreAfterControlPanel(ReaderSettings settings) async {
    if (!_isSupportedDesktop) {
      return;
    }

    final restorePosition = _controlPanelRestorePosition;
    final restoreSize = _controlPanelRestoreSize;
    _controlPanelRestorePosition = null;
    _controlPanelRestoreSize = null;

    if (_useFramelessWindow) {
      await windowManager.setAsFrameless();
      await windowManager.setHasShadow(false);
    }
    await windowManager.setAlwaysOnTop(settings.alwaysOnTop);
    await windowManager.setOpacity(1.0);
    final currentSize = restoreSize ?? await windowManager.getSize();
    if (_lastOneLineMode == true) {
      _rememberedOneLineWidth = _normalizeOneLineWidth(currentSize.width);
    } else {
      _rememberedMultiLineSize = _normalizeMultiLineSize(currentSize);
    }
    final targetSize = _targetReaderSize(
      currentSize: currentSize,
      settings: settings,
    );
    _lastOneLineMode = settings.oneLineMode;
    await windowManager.setMinimumSize(_minimumWindowSizeFor(settings));
    await windowManager.setBounds(
      null,
      position: restorePosition,
      size: targetSize,
      animate: true,
    );
  }

  Size _targetReaderSize({
    required Size currentSize,
    required ReaderSettings settings,
  }) {
    final oneLineMode = settings.oneLineMode;
    final oneLineHeight = _oneLineHeightForSettings(settings: settings);
    final multiLineHeight = _defaultMultiLineHeightForSettings(
      settings: settings,
    );
    final width = math.max(currentSize.width, _minimumWidth);
    if (_lastOneLineMode == null) {
      return oneLineMode
          ? Size(
              _targetOneLineWidth(currentWidth: width, settings: settings),
              oneLineHeight,
            )
          : (_rememberedMultiLineSize ?? Size(width, multiLineHeight));
    }

    if (_lastOneLineMode == oneLineMode) {
      final minimumHeight = oneLineMode
          ? oneLineHeight
          : _minimumMultiLineHeight;
      final targetWidth = oneLineMode
          ? _normalizeOneLineWidth(currentSize.width)
          : width;
      return Size(targetWidth, math.max(currentSize.height, minimumHeight));
    }

    if (oneLineMode) {
      _rememberedMultiLineSize = _normalizeMultiLineSize(currentSize);
      return Size(
        _targetOneLineWidth(currentWidth: width, settings: settings),
        oneLineHeight,
      );
    }

    _rememberedOneLineWidth = _normalizeOneLineWidth(currentSize.width);
    return _rememberedMultiLineSize ?? Size(width, multiLineHeight);
  }

  Size _minimumWindowSizeFor(ReaderSettings settings) {
    return Size(
      _minimumWidth,
      settings.oneLineMode
          ? _oneLineHeightForSettings(settings: settings)
          : _minimumMultiLineHeight,
    );
  }

  double _oneLineHeightForSettings({ReaderSettings? settings}) {
    final effectiveSettings = settings ?? ReaderSettings.defaults;
    return readerOneLineWindowHeightForFontScale(
      fontScale: effectiveSettings.fontScale,
      absoluteMinimumHeight: _absoluteMinimumOneLineHeight,
      lineSpacing: effectiveSettings.lineSpacing,
    );
  }

  double _defaultMultiLineHeightForSettings({
    required ReaderSettings settings,
  }) {
    return readerDefaultMultiLineWindowHeightForFontScale(
      settings.fontScale,
      lineSpacing: settings.lineSpacing,
    );
  }

  Size _normalizeMultiLineSize(Size size) {
    return Size(
      math.max(size.width, _minimumWidth),
      math.max(size.height, _minimumMultiLineHeight),
    );
  }

  double _normalizeOneLineWidth(double width) {
    return math.max(width, _minimumWidth);
  }

  double _targetOneLineWidth({
    required double currentWidth,
    required ReaderSettings settings,
  }) {
    final rememberedWidth = _rememberedOneLineWidth;
    if (rememberedWidth != null) {
      return _normalizeOneLineWidth(rememberedWidth);
    }

    return readerAutomaticSingleLineWidth(
      currentWidth: currentWidth,
      fontScale: settings.fontScale,
    );
  }
}

PlatformWindowController createPlatformWindowControllerImpl() {
  return DesktopPlatformWindowController();
}
