import 'dart:async';
import 'dart:math' as math;

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

import '../l10n/generated/app_localizations.dart';
import 'platform_window_controller_base.dart';
import 'reader_book.dart';
import 'reader_controller.dart';
import 'reader_custom_font.dart';
import 'reader_layout_metrics.dart';
import 'reader_localization.dart';
import 'reader_release_checker.dart';
import 'reader_settings.dart';
import 'reader_shortcuts.dart';

const _readerDarkTextColor = Color(0xFF111111);
const _readerLightTextColor = Color(ReaderSettings.defaultCustomTextColorValue);
const _readerTransparentShadowOffsets = <Offset>[
  Offset(-1, 0),
  Offset(1, 0),
  Offset(0, -1),
  Offset(0, 1),
];

const _readerTextColorPresets = <Color>[
  Color(0xFFF4F4F0),
  Color(0xFFFFFFFF),
  Color(0xFF111111),
  Color(0xFFD97706),
  Color(0xFFB91C1C),
  Color(0xFF047857),
  Color(0xFF0F766E),
  Color(0xFF1D4ED8),
];

const XTypeGroup _fontFileTypeGroup = XTypeGroup(
  label: 'font',
  extensions: <String>['ttf', 'otf'],
  uniformTypeIdentifiers: <String>[
    'public.truetype-font',
    'public.opentype-font',
  ],
);

enum _ReaderTransitionDirection { idle, forward, backward }

({Color background, Color text, Color dragIndicator, List<Shadow> textShadows})
_resolveReaderPresentation(ReaderSettings settings) {
  final customTextColor = Color(settings.customTextColorValue);

  if (settings.transparentModeEnabled) {
    final textColor = settings.textColorMode == ReaderTextColorMode.custom
        ? customTextColor
        : _readerLightTextColor;
    final haloIsDark = textColor.computeLuminance() > 0.45;
    final haloColor = haloIsDark ? Colors.black : Colors.white;
    final textShadows = settings.transparentTextShadowEnabled
        ? [
            for (final offset in _readerTransparentShadowOffsets)
              Shadow(
                color: haloColor.withValues(alpha: haloIsDark ? 0.72 : 0.62),
                offset: offset,
                blurRadius: 1.2,
              ),
            Shadow(
              color: haloColor.withValues(alpha: haloIsDark ? 0.42 : 0.34),
              offset: const Offset(0, 2),
              blurRadius: 12,
            ),
          ]
        : const <Shadow>[];

    return (
      background: Colors.transparent,
      text: textColor,
      dragIndicator: haloColor.withValues(alpha: haloIsDark ? 0.78 : 0.68),
      textShadows: textShadows,
    );
  }

  final useLightReaderBackground = settings.windowOpacity < 0.78;
  final automaticTextColor = useLightReaderBackground
      ? _readerDarkTextColor
      : _readerLightTextColor;
  final readerBackgroundColor = useLightReaderBackground
      ? const Color(0xFFF2F0E8).withValues(alpha: settings.windowOpacity)
      : Colors.black.withValues(alpha: settings.windowOpacity);
  final dragIndicatorColor = useLightReaderBackground
      ? Colors.black.withValues(alpha: 0.55)
      : Colors.white.withValues(alpha: 0.6);

  return (
    background: readerBackgroundColor,
    text: settings.textColorMode == ReaderTextColorMode.custom
        ? customTextColor
        : automaticTextColor,
    dragIndicator: dragIndicatorColor,
    textShadows: const <Shadow>[],
  );
}

class CheatReaderApp extends StatelessWidget {
  const CheatReaderApp({
    super.key,
    required this.controller,
    required this.windowController,
  });

  final ReaderController controller;
  final PlatformWindowController windowController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final locale = materialLocaleForLanguageMode(
          controller.settings.languageMode,
        );
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.transparent,
            canvasColor: Colors.transparent,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF7F8A99),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          builder: (context, child) {
            return ColoredBox(
              color: Colors.transparent,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: ReaderSurface(
            controller: controller,
            windowController: windowController,
          ),
        );
      },
    );
  }
}

class ReaderSurface extends StatefulWidget {
  const ReaderSurface({
    super.key,
    required this.controller,
    required this.windowController,
  });

  final ReaderController controller;
  final PlatformWindowController windowController;

  @override
  State<ReaderSurface> createState() => _ReaderSurfaceState();
}

class _ReaderSurfaceState extends State<ReaderSurface> with WindowListener {
  static const Duration _readerLineTransitionDuration = Duration(
    milliseconds: 90,
  );
  OverlayEntry? _messageOverlayEntry;
  Timer? _messageTimer;
  bool _windowListenerRegistered = false;
  int? _lastOneLineSourceIndex;
  int _oneLineSegmentIndex = 0;
  bool _jumpToTailOnNextOneLineSource = false;
  int? _lastMultiLineSourceIndex;
  int _multiLineSegmentIndex = 0;
  bool _jumpToTailOnNextMultiLineSource = false;
  int _visibleVisualLineCapacity = readerDefaultMultiLineVisibleLines;
  List<String> _cachedMultiLineSourceSegments = const <String>[];
  int _readerTransitionToken = 0;
  _ReaderTransitionDirection _readerTransitionDirection =
      _ReaderTransitionDirection.idle;

  @override
  void initState() {
    super.initState();
    if (widget.windowController.supportsFloatingControls) {
      windowManager.addListener(this);
      _windowListenerRegistered = true;
    }
  }

  Size _screenSizeForCurrentDisplay(BuildContext context) {
    final view = View.maybeOf(context);
    final display = view?.display;
    if (display == null) {
      return MediaQuery.sizeOf(context);
    }

    return Size(
      display.size.width / display.devicePixelRatio,
      display.size.height / display.devicePixelRatio,
    );
  }

  Future<void> _showControlPanel() async {
    final windowController = widget.windowController;
    final controller = widget.controller;
    final screenSize = _screenSizeForCurrentDisplay(context);

    await windowController.prepareForControlPanel(screenSize: screenSize);
    if (!mounted) {
      return;
    }

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return _ReaderControlPanel(
            controller: controller,
            windowController: windowController,
            onMessage: _showMessage,
          );
        },
      );
    } finally {
      await windowController.restoreAfterControlPanel(controller.settings);
    }
  }

  void _showMessage(String message) {
    _messageTimer?.cancel();
    _messageOverlayEntry?.remove();

    final overlay = Overlay.of(context, rootOverlay: true);
    _messageOverlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: 0,
          right: 0,
          bottom: 24,
          child: IgnorePointer(
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111).withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(_messageOverlayEntry!);
    _messageTimer = Timer(const Duration(seconds: 2), () {
      _messageOverlayEntry?.remove();
      _messageOverlayEntry = null;
      _messageTimer = null;
    });
  }

  void _handleExit() {
    if (widget.windowController.supportsFloatingControls) {
      unawaited(widget.windowController.closeWindow());
      return;
    }

    SystemNavigator.pop();
  }

  Future<void> _handleDroppedFiles(List<XFile> files) async {
    for (final file in files) {
      final path = file.path;
      if (path.isEmpty) {
        continue;
      }

      final message = await widget.controller.importFromPath(path);
      if (!mounted) {
        return;
      }

      if (message != null) {
        _showMessage(message);
      }
      return;
    }

    _showMessage(AppLocalizations.of(context)!.importNoFiles);
  }

  void _handlePointerSignal(PointerSignalEvent signal) {
    if (signal is! PointerScrollEvent) {
      return;
    }

    final delta = signal.scrollDelta.dy;
    if (delta == 0) {
      return;
    }

    final steps = math.max(1, (delta.abs() / 56).round());
    if (delta > 0) {
      for (var index = 0; index < steps; index += 1) {
        _advanceReading();
      }
      return;
    }

    for (var index = 0; index < steps; index += 1) {
      _rewindReading();
    }
  }

  void _advanceReading() {
    _advanceReadingInternal(animate: true);
  }

  bool _advanceReadingInternal({required bool animate}) {
    final controller = widget.controller;
    if (!controller.settings.oneLineMode) {
      return _advanceMultiLineReading(animate: animate);
    }

    final segmentCount = _visibleOneLineSegmentCount;
    if (_oneLineSegmentIndex < segmentCount - 1) {
      _prepareReaderTransition(
        _ReaderTransitionDirection.forward,
        animate: animate,
      );
      setState(() {
        _oneLineSegmentIndex += 1;
      });
      return true;
    }

    if (controller.currentLineIndex >= controller.totalLineCount - 1) {
      return false;
    }

    _prepareReaderTransition(
      _ReaderTransitionDirection.forward,
      animate: animate,
    );
    _oneLineSegmentIndex = 0;
    controller.nextLine();
    return true;
  }

  void _rewindReading() {
    _rewindReadingInternal(animate: true);
  }

  bool _rewindReadingInternal({required bool animate}) {
    final controller = widget.controller;
    if (!controller.settings.oneLineMode) {
      return _rewindMultiLineReading(animate: animate);
    }

    if (_oneLineSegmentIndex > 0) {
      _prepareReaderTransition(
        _ReaderTransitionDirection.backward,
        animate: animate,
      );
      setState(() {
        _oneLineSegmentIndex -= 1;
      });
      return true;
    }

    if (controller.currentLineIndex == 0) {
      return false;
    }

    _prepareReaderTransition(
      _ReaderTransitionDirection.backward,
      animate: animate,
    );
    _jumpToTailOnNextOneLineSource = true;
    controller.previousLine();
    return true;
  }

  bool _advanceMultiLineReading({required bool animate}) {
    final controller = widget.controller;
    final segmentCount = _cachedMultiLineSourceSegments.isEmpty
        ? 1
        : _cachedMultiLineSourceSegments.length;
    if (_multiLineSegmentIndex < segmentCount - 1) {
      _prepareReaderTransition(
        _ReaderTransitionDirection.forward,
        animate: animate,
      );
      setState(() {
        _multiLineSegmentIndex += 1;
      });
      return true;
    }

    if (controller.currentLineIndex >= controller.totalLineCount - 1) {
      return false;
    }

    _prepareReaderTransition(
      _ReaderTransitionDirection.forward,
      animate: animate,
    );
    _multiLineSegmentIndex = 0;
    controller.nextLine();
    return true;
  }

  bool _rewindMultiLineReading({required bool animate}) {
    final controller = widget.controller;
    if (_multiLineSegmentIndex > 0) {
      _prepareReaderTransition(
        _ReaderTransitionDirection.backward,
        animate: animate,
      );
      setState(() {
        _multiLineSegmentIndex -= 1;
      });
      return true;
    }

    if (controller.currentLineIndex == 0) {
      return false;
    }

    _prepareReaderTransition(
      _ReaderTransitionDirection.backward,
      animate: animate,
    );
    _jumpToTailOnNextMultiLineSource = true;
    controller.previousLine();
    return true;
  }

  void _advanceReadingPage() {
    final stepCount = math.max(1, _visibleVisualLineCapacity);
    var animated = false;
    for (var index = 0; index < stepCount; index += 1) {
      final moved = _advanceReadingInternal(animate: !animated);
      if (!moved) {
        break;
      }
      animated = true;
    }
  }

  void _rewindReadingPage() {
    final stepCount = math.max(1, _visibleVisualLineCapacity);
    var animated = false;
    for (var index = 0; index < stepCount; index += 1) {
      final moved = _rewindReadingInternal(animate: !animated);
      if (!moved) {
        break;
      }
      animated = true;
    }
  }

  void _prepareReaderTransition(
    _ReaderTransitionDirection direction, {
    required bool animate,
  }) {
    if (!animate) {
      return;
    }

    _readerTransitionDirection = direction;
    _readerTransitionToken += 1;
  }

  int get _visibleOneLineSegmentCount {
    final segments = _cachedOneLineSegments;
    return segments.isEmpty ? 1 : segments.length;
  }

  List<String> _cachedOneLineSegments = const <String>[];

  @override
  void onWindowMove() {}

  @override
  void onWindowMoved() {}

  @override
  void dispose() {
    _messageTimer?.cancel();
    _messageOverlayEntry?.remove();
    if (_windowListenerRegistered) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final settings = controller.settings;
    final l10n = AppLocalizations.of(context)!;
    final fontSize = readerBaseFontSize * settings.fontScale;
    final lineSpacing = settings.lineSpacing;
    final verticalPadding = settings.oneLineMode
        ? readerOneLineVerticalPadding
        : readerMultiLineVerticalPadding;
    final readerColors = _resolveReaderPresentation(settings);
    final readerTextColor = readerColors.text;
    final readerBackgroundColor = readerColors.background;
    final dragIndicatorColor = readerColors.dragIndicator;
    final customFontFamily =
        settings.customFontPath == null || settings.customFontPath!.isEmpty
        ? null
        : readerCustomFontFamilyForPath(settings.customFontPath!);
    final fontFamily = switch (settings.fontFamilyPreset) {
      ReaderFontFamilyPreset.custom => customFontFamily,
      _ => null,
    };
    final fontFamilyFallback = switch (settings.fontFamilyPreset) {
      ReaderFontFamilyPreset.system ||
      ReaderFontFamilyPreset.custom => const <String>[],
      ReaderFontFamilyPreset.serif => const <String>[
        'Songti SC',
        'STSong',
        'Times New Roman',
        'Noto Serif CJK SC',
        'serif',
      ],
      ReaderFontFamilyPreset.monospace => const <String>[
        'SF Mono',
        'Menlo',
        'Consolas',
        'Courier New',
        'monospace',
      ],
    };
    final textStyle = TextStyle(
      color: readerTextColor,
      fontSize: fontSize,
      height: lineSpacing,
      letterSpacing: 0.2,
      shadows: readerColors.textShadows,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
    );

    return CallbackShortcuts(
      bindings: _buildShortcutBindings(settings),
      child: Focus(
        autofocus: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final estimatedLineHeight = readerTextHeightForFontScale(
              settings.fontScale,
              lineSpacing: lineSpacing,
            );
            final availableHeight = math.max(
              estimatedLineHeight,
              constraints.maxHeight - (verticalPadding * 2),
            );
            final visibleLineCapacity = settings.oneLineMode
                ? 1
                : math.max(1, (availableHeight / estimatedLineHeight).floor());
            _visibleVisualLineCapacity = visibleLineCapacity;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                controller.updateVisibleLineCapacity(visibleLineCapacity);
              }
            });

            final content = Material(
              type: MaterialType.transparency,
              child: SizedBox.expand(
                child: DropTarget(
                  onDragEntered: (_) => controller.setDragTargetActive(true),
                  onDragExited: (_) => controller.setDragTargetActive(false),
                  onDragDone: (details) async {
                    controller.setDragTargetActive(false);
                    await _handleDroppedFiles(details.files);
                  },
                  child: Listener(
                    onPointerSignal: _handlePointerSignal,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onDoubleTap:
                          settings.modeToggleTrigger ==
                              ReaderModeToggleTrigger.doubleClick
                          ? controller.toggleOneLineMode
                          : null,
                      onTertiaryTapDown:
                          settings.modeToggleTrigger ==
                              ReaderModeToggleTrigger.middleClick
                          ? (_) => controller.toggleOneLineMode()
                          : null,
                      onPanStart: (_) {
                        if (!widget.windowController.supportsFloatingControls) {
                          return;
                        }
                        unawaited(widget.windowController.startDragging());
                      },
                      onSecondaryTapDown: (_) {
                        unawaited(_showControlPanel());
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: readerBackgroundColor,
                              border: controller.dragTargetActive
                                  ? Border.all(
                                      color: dragIndicatorColor,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: readerHorizontalPadding,
                              vertical: verticalPadding,
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final textColumnWidth = _resolveTextColumnWidth(
                                  constraints.maxWidth,
                                  settings,
                                );
                                final displayedLines = _resolveDisplayedLines(
                                  context: context,
                                  maxWidth: textColumnWidth,
                                  settings: settings,
                                  style: textStyle,
                                  visibleLineCapacity: visibleLineCapacity,
                                );
                                return ClipRect(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      width: textColumnWidth,
                                      child: _buildAnimatedReaderText(
                                        text: displayedLines.join('\n'),
                                        style: textStyle,
                                        maxLines: settings.oneLineMode
                                            ? 1
                                            : visibleLineCapacity,
                                        lineHeight: estimatedLineHeight,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (controller.dragTargetActive)
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.74),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  l10n.dropPrompt,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );

            if (widget.windowController.supportsManualResize) {
              return DragToResizeArea(
                resizeEdgeSize: 10,
                resizeEdgeColor: Colors.transparent,
                enableResizeEdges: settings.oneLineMode
                    ? const <ResizeEdge>[ResizeEdge.left, ResizeEdge.right]
                    : null,
                child: content,
              );
            }

            return content;
          },
        ),
      ),
    );
  }

  void _handleModeToggleShortcut() {
    if (widget.controller.settings.modeToggleTrigger !=
        ReaderModeToggleTrigger.keyboardShortcut) {
      return;
    }
    widget.controller.toggleOneLineMode();
  }

  Future<void> _handleBossKeyShortcut() async {
    await widget.controller.toggleBossKey();
  }

  Map<ShortcutActivator, VoidCallback> _buildShortcutBindings(
    ReaderSettings settings,
  ) {
    final bindings = <ShortcutActivator, VoidCallback>{
      const SingleActivator(LogicalKeyboardKey.arrowDown): _advanceReading,
      const SingleActivator(LogicalKeyboardKey.arrowUp): _rewindReading,
      const SingleActivator(LogicalKeyboardKey.pageDown): _advanceReadingPage,
      const SingleActivator(LogicalKeyboardKey.pageUp): _rewindReadingPage,
      const SingleActivator(LogicalKeyboardKey.space): _advanceReading,
      const SingleActivator(LogicalKeyboardKey.space, shift: true):
          _rewindReading,
      const SingleActivator(LogicalKeyboardKey.keyQ, control: true):
          _handleExit,
      const SingleActivator(LogicalKeyboardKey.keyQ, meta: true): _handleExit,
    };

    void addBinding(ReaderShortcutKey key, VoidCallback callback) {
      final activator = _activatorForShortcutKey(key);
      if (activator != null) {
        bindings[activator] = callback;
      }
    }

    final shortcuts = settings.shortcutBindings;
    addBinding(shortcuts.nextLine, _advanceReading);
    addBinding(shortcuts.previousLine, _rewindReading);
    addBinding(shortcuts.nextPage, _advanceReadingPage);
    addBinding(shortcuts.previousPage, _rewindReadingPage);
    addBinding(shortcuts.toggleMode, _handleModeToggleShortcut);
    addBinding(shortcuts.bossKey, () {
      unawaited(_handleBossKeyShortcut());
    });

    return bindings;
  }

  ShortcutActivator? _activatorForShortcutKey(ReaderShortcutKey key) {
    return switch (key) {
      ReaderShortcutKey.arrowDown => const SingleActivator(
        LogicalKeyboardKey.arrowDown,
      ),
      ReaderShortcutKey.arrowUp => const SingleActivator(
        LogicalKeyboardKey.arrowUp,
      ),
      ReaderShortcutKey.pageDown => const SingleActivator(
        LogicalKeyboardKey.pageDown,
      ),
      ReaderShortcutKey.pageUp => const SingleActivator(
        LogicalKeyboardKey.pageUp,
      ),
      ReaderShortcutKey.space => const SingleActivator(
        LogicalKeyboardKey.space,
      ),
      ReaderShortcutKey.shiftSpace => const SingleActivator(
        LogicalKeyboardKey.space,
        shift: true,
      ),
      ReaderShortcutKey.keyJ => const SingleActivator(LogicalKeyboardKey.keyJ),
      ReaderShortcutKey.keyK => const SingleActivator(LogicalKeyboardKey.keyK),
      ReaderShortcutKey.keyN => const SingleActivator(LogicalKeyboardKey.keyN),
      ReaderShortcutKey.keyP => const SingleActivator(LogicalKeyboardKey.keyP),
      ReaderShortcutKey.keyM => const SingleActivator(LogicalKeyboardKey.keyM),
      ReaderShortcutKey.keyB => const SingleActivator(LogicalKeyboardKey.keyB),
    };
  }

  List<String> _resolveDisplayedLines({
    required BuildContext context,
    required double maxWidth,
    required ReaderSettings settings,
    required TextStyle style,
    required int visibleLineCapacity,
  }) {
    if (settings.oneLineMode) {
      _cachedMultiLineSourceSegments = const <String>[];
      _lastMultiLineSourceIndex = null;
      _multiLineSegmentIndex = 0;
      _jumpToTailOnNextMultiLineSource = false;
      return <String>[
        _resolveDisplayedOneLine(
          context: context,
          maxWidth: maxWidth,
          style: style,
        ),
      ];
    }

    _cachedOneLineSegments = const <String>[];
    _lastOneLineSourceIndex = null;
    _oneLineSegmentIndex = 0;
    _jumpToTailOnNextOneLineSource = false;

    return _resolveDisplayedMultiLine(
      context: context,
      maxWidth: maxWidth,
      style: style,
      visibleLineCapacity: visibleLineCapacity,
    );
  }

  String _resolveDisplayedOneLine({
    required BuildContext context,
    required double maxWidth,
    required TextStyle style,
  }) {
    final controller = widget.controller;

    final visibleLines = controller.visibleLines;
    final sourceLine = visibleLines.isEmpty ? '' : visibleLines.first;
    final segments = _wrapIntoSingleVisualLines(
      text: sourceLine,
      maxWidth: maxWidth,
      style: style,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    );
    _cachedOneLineSegments = segments;

    final sourceIndex = controller.currentLineIndex;
    var targetIndex = _oneLineSegmentIndex;
    if (_lastOneLineSourceIndex != sourceIndex) {
      targetIndex = _jumpToTailOnNextOneLineSource ? segments.length - 1 : 0;
      _jumpToTailOnNextOneLineSource = false;
      _lastOneLineSourceIndex = sourceIndex;
    }

    final clampedIndex = math.min(
      math.max(0, targetIndex),
      math.max(0, segments.length - 1),
    );
    if (clampedIndex != _oneLineSegmentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _oneLineSegmentIndex = clampedIndex;
        });
      });
    }

    return segments[clampedIndex];
  }

  List<String> _resolveDisplayedMultiLine({
    required BuildContext context,
    required double maxWidth,
    required TextStyle style,
    required int visibleLineCapacity,
  }) {
    final controller = widget.controller;
    final sourceIndex = controller.currentLineIndex;
    final currentSourceSegments = _wrapIntoSingleVisualLines(
      text: controller.lineAt(sourceIndex),
      maxWidth: maxWidth,
      style: style,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    );
    _cachedMultiLineSourceSegments = currentSourceSegments;

    var targetIndex = _multiLineSegmentIndex;
    if (_lastMultiLineSourceIndex != sourceIndex) {
      targetIndex = _jumpToTailOnNextMultiLineSource
          ? currentSourceSegments.length - 1
          : 0;
      _jumpToTailOnNextMultiLineSource = false;
      _lastMultiLineSourceIndex = sourceIndex;
    }

    final clampedIndex = math.min(
      math.max(0, targetIndex),
      math.max(0, currentSourceSegments.length - 1),
    );
    if (clampedIndex != _multiLineSegmentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _multiLineSegmentIndex = clampedIndex;
        });
      });
    }

    final displayedLines = <String>[];
    var lineIndex = sourceIndex;
    var segmentIndex = clampedIndex;
    while (displayedLines.length < visibleLineCapacity &&
        lineIndex < controller.totalLineCount) {
      final segments = lineIndex == sourceIndex
          ? currentSourceSegments
          : _wrapIntoSingleVisualLines(
              text: controller.lineAt(lineIndex),
              maxWidth: maxWidth,
              style: style,
              textDirection: Directionality.of(context),
              textScaler: MediaQuery.textScalerOf(context),
            );
      for (
        var index = segmentIndex;
        index < segments.length && displayedLines.length < visibleLineCapacity;
        index += 1
      ) {
        displayedLines.add(segments[index]);
      }
      lineIndex += 1;
      segmentIndex = 0;
    }

    return displayedLines.isEmpty ? const <String>[''] : displayedLines;
  }

  Widget _buildAnimatedReaderText({
    required String text,
    required TextStyle style,
    required int maxLines,
    required double lineHeight,
  }) {
    final textWidget = Text(
      text,
      key: ValueKey<String>('reader-text-$text-$_readerTransitionToken'),
      softWrap: false,
      maxLines: maxLines,
      overflow: TextOverflow.clip,
      style: style,
    );

    if (!widget.controller.settings.readingAnimationEnabled) {
      return textWidget;
    }

    final directionalDistance = switch (_readerTransitionDirection) {
      _ReaderTransitionDirection.forward => lineHeight * 0.22,
      _ReaderTransitionDirection.backward => -lineHeight * 0.22,
      _ReaderTransitionDirection.idle => 0.0,
    };

    return TweenAnimationBuilder<double>(
      key: ValueKey<int>(_readerTransitionToken),
      duration: _readerLineTransitionDuration,
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: directionalDistance, end: 0),
      child: textWidget,
      builder: (context, offsetY, child) {
        return Transform.translate(offset: Offset(0, offsetY), child: child);
      },
      onEnd: () {
        if (!mounted ||
            _readerTransitionDirection == _ReaderTransitionDirection.idle) {
          return;
        }
        setState(() {
          _readerTransitionDirection = _ReaderTransitionDirection.idle;
        });
      },
    );
  }

  double _resolveTextColumnWidth(
    double availableWidth,
    ReaderSettings settings,
  ) {
    final widthFactor = settings.readingWidthFactor.clamp(0.55, 1.0);
    return (availableWidth * widthFactor).clamp(120.0, availableWidth);
  }

  List<String> _wrapIntoSingleVisualLines({
    required String text,
    required double maxWidth,
    required TextStyle style,
    required TextDirection textDirection,
    required TextScaler textScaler,
  }) {
    if (text.isEmpty || maxWidth <= 0) {
      return text.isEmpty ? const <String>[''] : <String>[text];
    }

    final segments = <String>[];
    var start = 0;
    while (start < text.length) {
      var low = start + 1;
      var high = text.length;
      var best = start + 1;
      while (low <= high) {
        final middle = (low + high) ~/ 2;
        final candidate = text.substring(start, middle);
        if (_fitsSingleVisualLine(
          text: candidate,
          maxWidth: maxWidth,
          style: style,
          textDirection: textDirection,
          textScaler: textScaler,
        )) {
          best = middle;
          low = middle + 1;
        } else {
          high = middle - 1;
        }
      }

      final wrapEnd = _preferWrapBoundary(text, start, best);
      segments.add(text.substring(start, wrapEnd));
      start = wrapEnd;
    }

    return segments.isEmpty ? const <String>[''] : segments;
  }

  bool _fitsSingleVisualLine({
    required String text,
    required double maxWidth,
    required TextStyle style,
    required TextDirection textDirection,
    required TextScaler textScaler,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: 1,
    )..layout(maxWidth: maxWidth);
    return !painter.didExceedMaxLines;
  }

  int _preferWrapBoundary(String text, int start, int fallbackEnd) {
    const preferredBoundaryRunes = <int>{
      0x20,
      0x09,
      0x3000,
      0x3001,
      0x3002,
      0xFF0C,
      0xFF01,
      0xFF1F,
      0xFF1A,
      0xFF1B,
      0x2014,
      0x2026,
      0xFF09,
      0x002C,
      0x002E,
      0x003A,
      0x003B,
      0x003F,
      0x0021,
      0x0029,
    };

    final minimumEnd = math.min(start + 1, fallbackEnd);
    for (var index = fallbackEnd - 1; index >= minimumEnd; index -= 1) {
      if (fallbackEnd - index > 16) {
        break;
      }
      if (preferredBoundaryRunes.contains(text.codeUnitAt(index))) {
        return index + 1;
      }
    }
    return fallbackEnd;
  }
}

class _ReaderControlPanel extends StatefulWidget {
  const _ReaderControlPanel({
    required this.controller,
    required this.windowController,
    required this.onMessage,
  });

  final ReaderController controller;
  final PlatformWindowController windowController;
  final ValueChanged<String> onMessage;

  @override
  State<_ReaderControlPanel> createState() => _ReaderControlPanelState();
}

class _ReaderControlPanelState extends State<_ReaderControlPanel> {
  static final Uri _feedbackUri = Uri.parse(
    'https://github.com/yaoyao2mm/cheatreader/issues/new',
  );
  static final Uri _releasesUri = Uri.parse(
    'https://github.com/yaoyao2mm/cheatreader/releases',
  );

  late final ScrollController _scrollController = ScrollController();
  late final ReaderReleaseChecker _releaseChecker = ReaderReleaseChecker();
  late final TextEditingController _lineJumpController =
      TextEditingController();
  late final TextEditingController _pageJumpController =
      TextEditingController();
  late final TextEditingController _percentJumpController =
      TextEditingController();
  late final TextEditingController _searchController = TextEditingController();
  String? _appVersion;
  bool _isCheckingLatestVersion = false;
  String? _lastSearchQuery;
  int? _lastSearchMatchIndex;

  @override
  void initState() {
    super.initState();
    unawaited(_loadAppVersion());
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (!mounted) {
        return;
      }

      setState(() {
        _appVersion = _formatAppVersion(packageInfo);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _appVersion = '';
      });
    }
  }

  String _formatAppVersion(PackageInfo packageInfo) {
    final version = packageInfo.version.trim();
    final buildNumber = packageInfo.buildNumber.trim();

    if (version.isEmpty) {
      return buildNumber;
    }
    if (buildNumber.isEmpty) {
      return version;
    }
    return '$version+$buildNumber';
  }

  void _handleExit() {
    if (widget.windowController.supportsFloatingControls) {
      unawaited(widget.windowController.closeWindow());
      return;
    }

    SystemNavigator.pop();
  }

  Future<void> _importFromPicker(BuildContext context) async {
    final message = await widget.controller.importFromPicker();
    if (message != null && context.mounted) {
      widget.onMessage(message);
    }
  }

  Future<void> _pickCustomFont(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final file = await openFile(
        acceptedTypeGroups: const <XTypeGroup>[_fontFileTypeGroup],
      );
      if (file == null) {
        return;
      }

      final didLoad = await ensureReaderCustomFontLoaded(file.path);
      if (!didLoad) {
        widget.onMessage(l10n.customFontLoadFailure);
        return;
      }

      widget.controller.setCustomFont(path: file.path, displayName: file.name);
    } catch (_) {
      widget.onMessage(l10n.customFontPickFailure);
    }
  }

  Future<void> _openBookshelfEntry(BuildContext context, String path) async {
    final message = await widget.controller.openBookshelfEntry(path);
    if (message != null && context.mounted) {
      widget.onMessage(message);
    }
  }

  Future<void> _checkLatestVersion(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (_isCheckingLatestVersion) {
      return;
    }

    if (_appVersion == null) {
      await _loadAppVersion();
      if (!mounted) {
        return;
      }
    }

    final currentVersion = ReaderReleaseChecker.normalizeVersion(
      _appVersion ?? '',
    );
    if (currentVersion == null) {
      await _openReleasesFallback(
        fallbackMessage: l10n.latestVersionReadCurrentFailed,
        failureMessage: l10n.latestVersionCheckFailed,
      );
      return;
    }

    setState(() {
      _isCheckingLatestVersion = true;
    });

    try {
      final latestRelease = await _releaseChecker.fetchLatestRelease();
      if (!mounted) {
        return;
      }
      if (latestRelease == null) {
        await _openReleasesFallback(
          fallbackMessage: l10n.latestVersionOpenedFallback,
          failureMessage: l10n.latestVersionCheckFailed,
        );
        return;
      }

      final hasNewerVersion =
          ReaderReleaseChecker.compareVersions(
            latestRelease.version,
            currentVersion,
          ) >
          0;
      if (!hasNewerVersion) {
        widget.onMessage(l10n.alreadyLatestVersionMessage);
        return;
      }

      final didLaunch = await launchUrl(
        latestRelease.url,
        mode: LaunchMode.externalApplication,
      );
      if (!didLaunch) {
        final didLaunchFallback = await launchUrl(
          _releasesUri,
          mode: LaunchMode.externalApplication,
        );
        if (!didLaunchFallback && mounted) {
          widget.onMessage(l10n.latestVersionOpenFailure);
        }
        return;
      }
    } catch (_) {
      await _openReleasesFallback(
        fallbackMessage: l10n.latestVersionOpenedFallback,
        failureMessage: l10n.latestVersionCheckFailed,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingLatestVersion = false;
        });
      }
    }
  }

  Future<void> _openReleasesFallback({
    required String fallbackMessage,
    required String failureMessage,
  }) async {
    try {
      final didLaunch = await launchUrl(
        _releasesUri,
        mode: LaunchMode.externalApplication,
      );
      if (didLaunch) {
        if (mounted) {
          widget.onMessage(fallbackMessage);
        }
        return;
      }
    } catch (_) {
      // Fall through to the shared failure message below.
    }

    if (mounted) {
      widget.onMessage(failureMessage);
    }
  }

  Future<void> _openBugReport(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final didLaunch = await launchUrl(
        _feedbackUri,
        mode: LaunchMode.externalApplication,
      );
      if (!didLaunch && context.mounted) {
        widget.onMessage(l10n.feedbackOpenFailure);
      }
    } catch (_) {
      if (context.mounted) {
        widget.onMessage(l10n.feedbackOpenFailure);
      }
    }
  }

  String _resolvedAppVersion(AppLocalizations l10n) {
    if (_appVersion == null) {
      return l10n.appVersionLoading;
    }
    if (_appVersion!.isEmpty) {
      return l10n.appVersionUnavailable;
    }
    return _appVersion!;
  }

  void _updateCustomTextColor(HSLColor Function(HSLColor current) updateColor) {
    final currentColor = HSLColor.fromColor(
      Color(widget.controller.settings.customTextColorValue),
    );
    widget.controller.setCustomTextColorValue(
      updateColor(currentColor).toColor().toARGB32(),
    );
  }

  String _textColorModeHint(AppLocalizations l10n, ReaderSettings settings) {
    return settings.textColorMode == ReaderTextColorMode.adaptive
        ? l10n.fontColorAutoHint
        : l10n.fontColorCustomHint;
  }

  String _formatHexColor(int argbValue) {
    final rgbValue = argbValue & 0x00FFFFFF;
    return '#${rgbValue.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  @override
  void dispose() {
    _releaseChecker.dispose();
    _scrollController.dispose();
    _lineJumpController.dispose();
    _pageJumpController.dispose();
    _percentJumpController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _submitLineJump(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lineNumber = int.tryParse(_lineJumpController.text.trim());
    if (lineNumber == null) {
      widget.onMessage(l10n.jumpInputInvalid);
      return;
    }
    if (lineNumber < 1 || lineNumber > widget.controller.totalLineCount) {
      widget.onMessage(
        l10n.jumpLineOutOfRange(widget.controller.totalLineCount),
      );
      return;
    }

    widget.controller.jumpToLineNumber(lineNumber);
    _lineJumpController.clear();
    FocusScope.of(context).unfocus();
  }

  void _submitPageJump(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pageNumber = int.tryParse(_pageJumpController.text.trim());
    if (pageNumber == null) {
      widget.onMessage(l10n.jumpInputInvalid);
      return;
    }
    if (pageNumber < 1 || pageNumber > widget.controller.totalPageCount) {
      widget.onMessage(
        l10n.jumpPageOutOfRange(widget.controller.totalPageCount),
      );
      return;
    }

    widget.controller.jumpToPageNumber(pageNumber);
    _pageJumpController.clear();
    FocusScope.of(context).unfocus();
  }

  void _submitPercentJump(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final percent = int.tryParse(_percentJumpController.text.trim());
    if (percent == null) {
      widget.onMessage(l10n.jumpInputInvalid);
      return;
    }
    if (percent < 0 || percent > 100) {
      widget.onMessage(l10n.jumpPercentOutOfRange);
      return;
    }

    widget.controller.jumpToProgressPercent(percent);
    _percentJumpController.clear();
    FocusScope.of(context).unfocus();
  }

  void _searchMatch(BuildContext context, {required bool forward}) {
    final l10n = AppLocalizations.of(context)!;
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      widget.onMessage(l10n.searchEmptyQuery);
      return;
    }

    final isRepeatedQuery =
        _lastSearchQuery == query && _lastSearchMatchIndex != null;
    final matchedIndex = widget.controller.jumpToSearchMatch(
      query,
      forward: forward,
      anchorLineIndex: isRepeatedQuery
          ? _lastSearchMatchIndex
          : widget.controller.currentLineIndex,
      includeAnchor: !isRepeatedQuery,
    );

    if (matchedIndex == null) {
      _lastSearchQuery = null;
      _lastSearchMatchIndex = null;
      widget.onMessage(l10n.searchNotFound);
      return;
    }

    _lastSearchQuery = query;
    _lastSearchMatchIndex = matchedIndex;
    FocusScope.of(context).unfocus();
  }

  List<Widget> _buildPanelSections(BuildContext context) {
    final controller = widget.controller;
    final windowController = widget.windowController;
    final l10n = AppLocalizations.of(context)!;
    final settings = controller.settings;
    final readerPresentation = _resolveReaderPresentation(settings);
    final customTextColor = Color(settings.customTextColorValue);
    final customTextColorHsl = HSLColor.fromColor(customTextColor);

    return [
      _SectionTitle(title: l10n.sectionSimpleBookshelf),
      const SizedBox(height: 8),
      if (controller.bookshelf.isEmpty)
        Text(l10n.bookshelfEmpty, style: TextStyle(color: Colors.white60))
      else
        ...controller.bookshelf.map(
          (book) => _BookshelfTile(
            book: book,
            isCurrent: controller.currentBook?.path == book.path,
            isStale: controller.isBookStale(book.path),
            onOpen: () => _openBookshelfEntry(context, book.path),
            onRemove: () => controller.removeBookshelfEntry(book.path),
          ),
        ),
      const SizedBox(height: 20),
      _SectionTitle(title: l10n.sectionReadingPosition),
      const SizedBox(height: 8),
      DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF22262C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x22FFFFFF)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.currentProgressSummary(controller.currentProgressPercent),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.currentLineSummary(
                  controller.currentLineNumber,
                  controller.totalLineCount,
                ),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              _ReadingProgressBar(progress: controller.currentProgressPercent),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ReadingPositionStatCard(
                      icon: Icons.format_list_numbered_rounded,
                      label: l10n.readingPositionLineStat,
                      value:
                          '${controller.currentLineNumber}/${controller.totalLineCount}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ReadingPositionStatCard(
                      icon: Icons.menu_book_rounded,
                      label: l10n.readingPositionPageStat,
                      value:
                          '${controller.currentPageNumber}/${controller.totalPageCount}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ReadingPositionStatCard(
                      icon: Icons.track_changes_rounded,
                      label: l10n.readingPositionProgressStat,
                      value: '${controller.currentProgressPercent}%',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _JumpInputRow(
                controller: _lineJumpController,
                label: l10n.jumpToLineLabel,
                hintText: l10n.jumpToLineHint(controller.totalLineCount),
                buttonLabel: l10n.jumpAction,
                icon: Icons.format_list_numbered_rounded,
                accentColor: const Color(0xFF7F8A99),
                onSubmitted: () => _submitLineJump(context),
              ),
              const SizedBox(height: 12),
              _JumpInputRow(
                controller: _pageJumpController,
                label: l10n.jumpToPageLabel,
                hintText: l10n.jumpToPageHint(controller.totalPageCount),
                buttonLabel: l10n.jumpAction,
                icon: Icons.menu_book_rounded,
                accentColor: const Color(0xFF7F8A99),
                onSubmitted: () => _submitPageJump(context),
              ),
              const SizedBox(height: 12),
              _JumpInputRow(
                controller: _percentJumpController,
                label: l10n.jumpToPercentLabel,
                hintText: l10n.jumpToPercentHint,
                buttonLabel: l10n.jumpAction,
                icon: Icons.track_changes_rounded,
                accentColor: const Color(0xFF7F8A99),
                onSubmitted: () => _submitPercentJump(context),
              ),
              const SizedBox(height: 12),
              _SearchInputRow(
                controller: _searchController,
                label: l10n.searchLabel,
                hintText: l10n.searchHint,
                previousLabel: l10n.searchPreviousAction,
                nextLabel: l10n.searchNextAction,
                icon: Icons.search_rounded,
                onPrevious: () => _searchMatch(context, forward: false),
                onNext: () => _searchMatch(context, forward: true),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      _SectionTitle(title: l10n.sectionReadingSettings),
      const SizedBox(height: 8),
      Text(l10n.modeToggleMethod),
      const SizedBox(height: 8),
      SegmentedButton<ReaderModeToggleTrigger>(
        segments: [
          ButtonSegment(
            value: ReaderModeToggleTrigger.doubleClick,
            label: Text(l10n.triggerDoubleClick),
          ),
          ButtonSegment(
            value: ReaderModeToggleTrigger.middleClick,
            label: Text(l10n.triggerMiddleClick),
          ),
          ButtonSegment(
            value: ReaderModeToggleTrigger.keyboardShortcut,
            label: Text(l10n.triggerKeyboard),
          ),
        ],
        selected: <ReaderModeToggleTrigger>{
          controller.settings.modeToggleTrigger,
        },
        onSelectionChanged: (selection) {
          controller.setModeToggleTrigger(selection.first);
        },
      ),
      const SizedBox(height: 8),
      Text(
        l10n.currentModeSummary(
          controller.settings.oneLineMode
              ? l10n.modeSingleLine
              : l10n.modeMultiLine,
          _modeToggleTriggerLabel(l10n, controller.settings.modeToggleTrigger),
        ),
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.white70),
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: controller.settings.alwaysOnTop,
        onChanged: windowController.supportsFloatingControls
            ? controller.setAlwaysOnTop
            : null,
        title: Text(l10n.alwaysOnTopTitle),
        subtitle: Text(
          windowController.supportsFloatingControls
              ? l10n.alwaysOnTopSupported
              : l10n.alwaysOnTopUnsupported,
        ),
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: controller.settings.transparentModeEnabled,
        onChanged: controller.setTransparentModeEnabled,
        title: Text(l10n.transparentModeTitle),
        subtitle: Text(l10n.transparentModeSubtitle),
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: controller.settings.transparentTextShadowEnabled,
        onChanged: controller.setTransparentTextShadowEnabled,
        title: Text(l10n.transparentTextShadowTitle),
        subtitle: Text(l10n.transparentTextShadowSubtitle),
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: controller.settings.readingAnimationEnabled,
        onChanged: controller.setReadingAnimationEnabled,
        title: Text(l10n.readingAnimationTitle),
        subtitle: Text(l10n.readingAnimationSubtitle),
      ),
      const SizedBox(height: 12),
      Text(l10n.languageTitle),
      const SizedBox(height: 8),
      SegmentedButton<ReaderLanguageMode>(
        segments: [
          ButtonSegment(
            value: ReaderLanguageMode.system,
            label: Text(l10n.languageSystem),
          ),
          ButtonSegment(
            value: ReaderLanguageMode.simplifiedChinese,
            label: Text(l10n.languageZhHans),
          ),
          ButtonSegment(
            value: ReaderLanguageMode.english,
            label: Text(l10n.languageEnglish),
          ),
        ],
        selected: <ReaderLanguageMode>{controller.settings.languageMode},
        onSelectionChanged: (selection) {
          controller.setLanguageMode(selection.first);
        },
      ),
      const SizedBox(height: 12),
      Text(l10n.fontTitle),
      const SizedBox(height: 8),
      SegmentedButton<ReaderFontFamilyPreset>(
        segments: [
          ButtonSegment(
            value: ReaderFontFamilyPreset.system,
            label: Text(l10n.fontDefault),
          ),
          ButtonSegment(
            value: ReaderFontFamilyPreset.serif,
            label: Text(l10n.fontSerif),
          ),
          ButtonSegment(
            value: ReaderFontFamilyPreset.monospace,
            label: Text(l10n.fontMonospace),
          ),
          ButtonSegment(
            value: ReaderFontFamilyPreset.custom,
            label: Text(l10n.fontCustom),
          ),
        ],
        selected: <ReaderFontFamilyPreset>{
          controller.settings.fontFamilyPreset,
        },
        onSelectionChanged: (selection) {
          final nextPreset = selection.first;
          if (nextPreset == ReaderFontFamilyPreset.custom) {
            unawaited(_pickCustomFont(context));
            return;
          }
          controller.setFontFamilyPreset(nextPreset);
        },
      ),
      const SizedBox(height: 12),
      Text(l10n.fontColorTitle),
      const SizedBox(height: 8),
      SegmentedButton<ReaderTextColorMode>(
        segments: [
          ButtonSegment(
            value: ReaderTextColorMode.adaptive,
            label: Text(l10n.fontColorAuto),
          ),
          ButtonSegment(
            value: ReaderTextColorMode.custom,
            label: Text(l10n.fontColorCustom),
          ),
        ],
        selected: <ReaderTextColorMode>{settings.textColorMode},
        onSelectionChanged: (selection) {
          controller.setTextColorMode(selection.first);
        },
      ),
      const SizedBox(height: 8),
      Text(
        _textColorModeHint(l10n, settings),
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.white70),
      ),
      const SizedBox(height: 12),
      _TextColorPreviewCard(
        label: l10n.fontColorPreviewLabel,
        sampleText: l10n.fontColorPreviewSample,
        hexValue: _formatHexColor(readerPresentation.text.toARGB32()),
        textColor: readerPresentation.text,
        textShadows: readerPresentation.textShadows,
      ),
      if (settings.textColorMode == ReaderTextColorMode.custom) ...[
        const SizedBox(height: 12),
        Text(l10n.fontColorPresetsLabel),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _readerTextColorPresets
              .map(
                (color) => _TextColorPresetButton(
                  color: color,
                  isSelected: color.toARGB32() == customTextColor.toARGB32(),
                  onTap: () =>
                      controller.setCustomTextColorValue(color.toARGB32()),
                ),
              )
              .toList(growable: false),
        ),
        const SizedBox(height: 12),
        _SliderRow(
          label: l10n.fontColorHueLabel,
          value: customTextColorHsl.hue,
          min: 0,
          max: 360,
          divisions: 72,
          displayValue: l10n.sliderDegrees(customTextColorHsl.hue.round()),
          onChanged: (value) {
            _updateCustomTextColor((current) => current.withHue(value));
          },
        ),
        _SliderRow(
          label: l10n.fontColorSaturationLabel,
          value: customTextColorHsl.saturation,
          min: 0,
          max: 1,
          divisions: 20,
          displayValue: l10n.sliderPercent(
            (customTextColorHsl.saturation * 100).round(),
          ),
          onChanged: (value) {
            _updateCustomTextColor((current) => current.withSaturation(value));
          },
        ),
        _SliderRow(
          label: l10n.fontColorLightnessLabel,
          value: customTextColorHsl.lightness,
          min: 0,
          max: 1,
          divisions: 20,
          displayValue: l10n.sliderPercent(
            (customTextColorHsl.lightness * 100).round(),
          ),
          onChanged: (value) {
            _updateCustomTextColor((current) => current.withLightness(value));
          },
        ),
      ],
      const SizedBox(height: 12),
      _SliderRow(
        label: l10n.fontScaleLabel,
        value: settings.fontScale,
        min: 0.85,
        max: 1.4,
        divisions: 11,
        displayValue: l10n.sliderPercent((settings.fontScale * 100).round()),
        onChanged: controller.setFontScale,
      ),
      _SliderRow(
        label: l10n.lineSpacingLabel,
        value: settings.lineSpacing,
        min: 1.2,
        max: 2.0,
        divisions: 8,
        displayValue: l10n.sliderMultiplier(
          settings.lineSpacing.toStringAsFixed(2),
        ),
        onChanged: controller.setLineSpacing,
      ),
      _SliderRow(
        label: l10n.readingWidthLabel,
        value: settings.readingWidthFactor,
        min: 0.55,
        max: 1.0,
        divisions: 9,
        displayValue: l10n.sliderPercent(
          (settings.readingWidthFactor * 100).round(),
        ),
        onChanged: controller.setReadingWidthFactor,
      ),
      _SliderRow(
        label: l10n.windowOpacityLabel,
        value: settings.windowOpacity,
        min: 0.0,
        max: 1.0,
        divisions: 20,
        displayValue: settings.transparentModeEnabled
            ? l10n.transparentModeOverridesOpacity
            : l10n.sliderPercent((settings.windowOpacity * 100).round()),
        onChanged: settings.transparentModeEnabled
            ? null
            : controller.setWindowOpacity,
      ),
      const SizedBox(height: 20),
      _SectionTitle(title: l10n.sectionKeyboardControls),
      const SizedBox(height: 8),
      ...ReaderShortcutAction.values.map(
        (action) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ShortcutDropdown(
            label: _shortcutActionLabel(l10n, action),
            value: controller.settings.shortcutBindings.keyForAction(action),
            keyLabelBuilder: (key) => _shortcutKeyLabel(l10n, key),
            onChanged: (value) {
              final message = controller.setShortcutBinding(action, value);
              if (message != null) {
                widget.onMessage(message);
              }
            },
          ),
        ),
      ),
      if (windowController.supportsBossKey)
        FilledButton.icon(
          onPressed: () {
            unawaited(controller.toggleBossKey());
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.visibility_off_outlined),
          label: Text(l10n.bossKeyHideNow),
        ),
      const SizedBox(height: 20),
      _SectionTitle(title: l10n.sectionAboutApp),
      const SizedBox(height: 8),
      Card(
        color: const Color(0xFF22262C),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.appVersionLabel,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 6),
              SelectableText(
                _resolvedAppVersion(l10n),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.reportBugTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.reportBugSubtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _isCheckingLatestVersion
                        ? null
                        : () => _checkLatestVersion(context),
                    icon: _isCheckingLatestVersion
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.system_update_alt_outlined),
                    label: Text(l10n.checkLatestVersionLabel),
                  ),
                  FilledButton.icon(
                    onPressed: () => _openBugReport(context),
                    icon: const Icon(Icons.bug_report_outlined),
                    label: Text(l10n.reportBugAction),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ];
  }

  String _modeToggleTriggerLabel(
    AppLocalizations l10n,
    ReaderModeToggleTrigger trigger,
  ) {
    return switch (trigger) {
      ReaderModeToggleTrigger.doubleClick => l10n.triggerDoubleClickLong,
      ReaderModeToggleTrigger.middleClick => l10n.triggerMiddleClickLong,
      ReaderModeToggleTrigger.keyboardShortcut => l10n.triggerKeyboardLong(
        _shortcutKeyLabel(
          l10n,
          widget.controller.settings.shortcutBindings.toggleMode,
        ),
      ),
    };
  }

  String _shortcutActionLabel(
    AppLocalizations l10n,
    ReaderShortcutAction action,
  ) {
    return switch (action) {
      ReaderShortcutAction.nextLine => l10n.shortcutNextLine,
      ReaderShortcutAction.previousLine => l10n.shortcutPreviousLine,
      ReaderShortcutAction.nextPage => l10n.shortcutNextPage,
      ReaderShortcutAction.previousPage => l10n.shortcutPreviousPage,
      ReaderShortcutAction.toggleMode => l10n.shortcutToggleMode,
      ReaderShortcutAction.bossKey => l10n.shortcutBossKey,
    };
  }

  String _shortcutKeyLabel(AppLocalizations l10n, ReaderShortcutKey key) {
    return switch (key) {
      ReaderShortcutKey.arrowDown => l10n.shortcutKeyArrowDown,
      ReaderShortcutKey.arrowUp => l10n.shortcutKeyArrowUp,
      ReaderShortcutKey.pageDown => l10n.shortcutKeyPageDown,
      ReaderShortcutKey.pageUp => l10n.shortcutKeyPageUp,
      ReaderShortcutKey.space => l10n.shortcutKeySpace,
      ReaderShortcutKey.shiftSpace => l10n.shortcutKeyShiftSpace,
      ReaderShortcutKey.keyJ => 'J',
      ReaderShortcutKey.keyK => 'K',
      ReaderShortcutKey.keyN => 'N',
      ReaderShortcutKey.keyP => 'P',
      ReaderShortcutKey.keyM => 'M',
      ReaderShortcutKey.keyB => 'B',
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;
        final viewportSize = MediaQuery.sizeOf(context);
        final panelWidth = math.max(
          280.0,
          math.min(420.0, viewportSize.width - 64),
        );
        final panelHeight = math.max(
          220.0,
          math.min(640.0, viewportSize.height - 64),
        );
        final sectionChildren = _buildPanelSections(context);

        return Dialog(
          insetPadding: const EdgeInsets.all(32),
          backgroundColor: const Color(0xFF1B1D21),
          child: SizedBox(
            width: panelWidth,
            height: panelHeight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final useCompactLayout = constraints.maxHeight < 360;

                if (useCompactLayout) {
                  return SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.controlPanelTitle,
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.controller.currentDisplayName.isEmpty
                              ? l10n.panelCurrentBookFallback
                              : widget.controller.currentDisplayName,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => _importFromPicker(context),
                          icon: const Icon(Icons.upload_file),
                          label: Text(l10n.importEbook),
                        ),
                        const SizedBox(height: 16),
                        ...sectionChildren,
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _handleExit,
                            icon: const Icon(Icons.close),
                            label: Text(l10n.quitReader),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.controlPanelTitle,
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.controller.currentDisplayName.isEmpty
                            ? l10n.panelCurrentBookFallback
                            : widget.controller.currentDisplayName,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => _importFromPicker(context),
                        icon: const Icon(Icons.upload_file),
                        label: Text(l10n.importEbook),
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: Color(0x33FFFFFF)),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          child: ListView(
                            controller: _scrollController,
                            padding: EdgeInsets.zero,
                            children: sectionChildren,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: Color(0x33FFFFFF)),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _handleExit,
                          icon: const Icon(Icons.close),
                          label: Text(l10n.quitReader),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(color: Colors.white),
    );
  }
}

class _BookshelfTile extends StatelessWidget {
  const _BookshelfTile({
    required this.book,
    required this.isCurrent,
    required this.isStale,
    required this.onOpen,
    required this.onRemove,
  });

  final ReaderBookRecord book;
  final bool isCurrent;
  final bool isStale;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final subtitleParts = <String>[
      l10n.positionLabel(book.lastReadLineIndex + 1),
    ];

    if (isStale) {
      subtitleParts.add(l10n.fileMayBeInvalid);
    }

    return Card(
      color: isCurrent ? const Color(0xFF2B3038) : const Color(0xFF22262C),
      child: ListTile(
        onTap: onOpen,
        title: Text(
          book.displayName.isEmpty ? l10n.untitledText : book.displayName,
        ),
        subtitle: Text(subtitleParts.join(' · ')),
        trailing: IconButton(
          tooltip: l10n.removeTooltip,
          onPressed: onRemove,
          icon: Icon(isStale ? Icons.delete_forever : Icons.delete_outline),
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayValue,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayValue;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text(displayValue)],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _JumpInputRow extends StatelessWidget {
  const _JumpInputRow({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.buttonLabel,
    required this.icon,
    required this.accentColor,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final String buttonLabel;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF1D2026),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x18FFFFFF)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white54),
            const SizedBox(width: 8),
            SizedBox(
              width: 72,
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onSubmitted: (_) => onSubmitted(),
                decoration: InputDecoration(
                  hintText: hintText,
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFF17191F),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accentColor, width: 1.0),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2A2E36),
                foregroundColor: Colors.white,
                minimumSize: const Size(64, 44),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onSubmitted,
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchInputRow extends StatelessWidget {
  const _SearchInputRow({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.previousLabel,
    required this.nextLabel,
    required this.icon,
    required this.onPrevious,
    required this.onNext,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final String previousLabel;
  final String nextLabel;
  final IconData icon;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF1D2026),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x18FFFFFF)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: Colors.white54),
                const SizedBox(width: 8),
                SizedBox(
                  width: compact ? 48 : 72,
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => onNext(),
                    decoration: InputDecoration(
                      hintText: hintText,
                      isDense: true,
                      filled: true,
                      fillColor: const Color(0xFF17191F),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: const Color(0xFF7F8A99),
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (compact) ...[
                  Tooltip(
                    message: previousLabel,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        minimumSize: const Size(44, 44),
                        padding: EdgeInsets.zero,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: onPrevious,
                      child: const Icon(Icons.keyboard_arrow_up_rounded),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: nextLabel,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2A2E36),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(44, 44),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: onNext,
                      child: const Icon(Icons.keyboard_arrow_down_rounded),
                    ),
                  ),
                ] else ...[
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      minimumSize: const Size(64, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onPrevious,
                    child: Text(previousLabel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2A2E36),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(64, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onNext,
                    child: Text(nextLabel),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReadingProgressBar extends StatelessWidget {
  const _ReadingProgressBar({required this.progress});

  final int progress;

  @override
  Widget build(BuildContext context) {
    final progressValue = (progress.clamp(0, 100) / 100).toDouble();

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: Colors.white.withValues(alpha: 0.08)),
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progressValue,
                child: const DecoratedBox(
                  decoration: BoxDecoration(color: Color(0xFF7F8A99)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadingPositionStatCard extends StatelessWidget {
  const _ReadingPositionStatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF1D2026),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: Colors.white54),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: Colors.white60),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextColorPreviewCard extends StatelessWidget {
  const _TextColorPreviewCard({
    required this.label,
    required this.sampleText,
    required this.hexValue,
    required this.textColor,
    required this.textShadows,
  });

  final String label;
  final String sampleText;
  final String hexValue;
  final Color textColor;
  final List<Shadow> textShadows;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final previewStyle = textTheme.titleMedium?.copyWith(
      color: textColor,
      shadows: textShadows,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF22262C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: textTheme.labelMedium?.copyWith(color: Colors.white70),
                ),
                Text(
                  hexValue,
                  style: textTheme.labelMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 72,
                child: Row(
                  children: [
                    Expanded(
                      child: ColoredBox(
                        color: const Color(0xFFF4F1E8),
                        child: Center(
                          child: Text(
                            sampleText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: previewStyle,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ColoredBox(
                        color: const Color(0xFF111318),
                        child: Center(
                          child: Text(
                            sampleText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: previewStyle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextColorPresetButton extends StatelessWidget {
  const _TextColorPresetButton({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : const Color(0x33FFFFFF),
            width: isSelected ? 2.4 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ),
      ),
    );
  }
}

class _ShortcutDropdown extends StatelessWidget {
  const _ShortcutDropdown({
    required this.label,
    required this.value,
    required this.keyLabelBuilder,
    required this.onChanged,
  });

  final String label;
  final ReaderShortcutKey value;
  final String Function(ReaderShortcutKey key) keyLabelBuilder;
  final ValueChanged<ReaderShortcutKey> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF22262C),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            PopupMenuButton<ReaderShortcutKey>(
              tooltip: label,
              color: const Color(0xFF22262C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: onChanged,
              itemBuilder: (context) {
                return ReaderShortcutKey.values
                    .map(
                      (key) => PopupMenuItem<ReaderShortcutKey>(
                        value: key,
                        child: Text(keyLabelBuilder(key)),
                      ),
                    )
                    .toList(growable: false);
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1D21),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0x22FFFFFF)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        keyLabelBuilder(value),
                        style: textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
