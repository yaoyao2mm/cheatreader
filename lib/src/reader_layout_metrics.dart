import 'dart:math' as math;

const double readerBaseFontSize = 20;
const double readerTextLineHeight = 1.5;
const int readerDefaultMultiLineVisibleLines = 5;
const double readerHorizontalPadding = 6;
const double readerMultiLineVerticalPadding = 0;
const double readerOneLineVerticalPadding = 6;
const double readerOneLineHeightSafetyInset = 6;
const double readerMinimumWidth = 320;
const double readerMinimumMultiLineHeight = 84;
const double readerPreferredSingleLineWidth = 560;
const double readerMaximumAutomaticSingleLineWidth = 680;

double readerTextHeightForFontScale(
  double fontScale, {
  double lineSpacing = readerTextLineHeight,
}) {
  return readerBaseFontSize * fontScale * lineSpacing;
}

double readerOneLineWindowHeightForFontScale({
  required double fontScale,
  required double absoluteMinimumHeight,
  double lineSpacing = readerTextLineHeight,
}) {
  final targetHeight =
      readerTextHeightForFontScale(fontScale, lineSpacing: lineSpacing) +
      (readerOneLineVerticalPadding * 2) +
      readerOneLineHeightSafetyInset;
  return math.max(absoluteMinimumHeight, targetHeight);
}

double readerDefaultMultiLineWindowHeightForFontScale(
  double fontScale, {
  double lineSpacing = readerTextLineHeight,
}) {
  final targetHeight =
      (readerTextHeightForFontScale(fontScale, lineSpacing: lineSpacing) *
          readerDefaultMultiLineVisibleLines) +
      8;
  return math.max(readerMinimumMultiLineHeight, targetHeight);
}

double readerAutomaticSingleLineWidth({
  required double currentWidth,
  required double fontScale,
}) {
  final normalizedCurrentWidth = math.max(currentWidth, readerMinimumWidth);
  final scaledPreferredWidth =
      readerPreferredSingleLineWidth * fontScale.clamp(1.0, 1.35);
  final boundedAutomaticWidth = math.min(
    normalizedCurrentWidth,
    readerMaximumAutomaticSingleLineWidth,
  );

  return math.max(
    readerMinimumWidth,
    math.min(boundedAutomaticWidth, scaledPreferredWidth),
  );
}
