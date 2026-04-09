// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'CheatReader';

  @override
  String get demoTitle => '演示文本';

  @override
  String get emptyText => '（空文本）';

  @override
  String get untitledText => '未命名文本';

  @override
  String get demoContent =>
      '工作消息刷完以后，阅读器应该还停留在刚才那一行。\n它不需要占据桌面中央，也不需要像传统应用一样提醒存在感。\n只要在余光里保留一小块可阅读的区域，就足够继续向下读。\n一行模式适合把句子藏进屏幕边缘，多行模式适合短暂进入状态。\n滚轮向下时往后读一行，滚轮向上时退回一行。\n按下方向键时也应该得到完全一致的结果。\n按下 PageDown 时，内容整体向前翻过当前可见范围。\n按下 PageUp 时，则回到前一页的顶部附近。\n右键菜单承担所有即时设置，不出现工具栏，也不需要状态栏。\n字体可以略微放大，透明度可以稍微降低，窗口是否置顶也能立刻切换。\n如果平台支持无边框窗口，就让它像一张漂浮的纸条。\n如果平台不支持，也至少保持简洁和稳定。\n这个项目的第一步，不解决书库，不解决同步，也不解决复杂格式。\n它只是一个足够轻、足够快、足够不显眼的阅读器。\n当你暂停阅读时，当前位置应该始终被保留下来。\n当你重新开始时，只需要再次向下滚动，就能顺着刚才的节奏继续。';

  @override
  String get importNoFiles => '没有可导入的电子书文件';

  @override
  String get importOpenFailure => '无法打开该电子书文件';

  @override
  String get importFailure => '无法导入该电子书文件';

  @override
  String get importUnsupportedFormat =>
      '仅支持导入 txt / epub / html / md / fb2 / docx / pdf';

  @override
  String get dropPrompt => '拖入 txt / epub / html / md / fb2 / docx / pdf 开始阅读';

  @override
  String get controlPanelTitle => 'CheatReader 控制面板';

  @override
  String get importEbook => '导入电子书';

  @override
  String get quitReader => '退出阅读器';

  @override
  String get bookshelfTitle => '简单书架';

  @override
  String get bookshelfEmpty => '还没有导入过电子书。可以直接拖入窗口，或点上面的导入按钮。';

  @override
  String get settingsTitle => '阅读设置';

  @override
  String get modeToggleMethod => '显示模式切换方式';

  @override
  String get triggerDoubleClick => '双击';

  @override
  String get triggerMiddleClick => '中键';

  @override
  String get triggerKeyboard => '快捷键';

  @override
  String get triggerDoubleClickLong => '双击阅读区';

  @override
  String get triggerMiddleClickLong => '鼠标中键点击阅读区';

  @override
  String triggerKeyboardLong(Object shortcut) {
    return '按 $shortcut';
  }

  @override
  String get modeSingleLine => '单行';

  @override
  String get modeMultiLine => '多行';

  @override
  String currentModeSummary(Object mode, Object trigger) {
    return '当前$mode。切换方式：$trigger';
  }

  @override
  String get languageTitle => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageZhHans => '简体中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get alwaysOnTopTitle => '始终置顶';

  @override
  String get alwaysOnTopSupported => '窗口保持浮在最前';

  @override
  String get alwaysOnTopUnsupported => '当前平台暂不支持';

  @override
  String get transparentModeTitle => '透明模式';

  @override
  String get transparentModeSubtitle => '彻底去掉任何底色，只保留文字';

  @override
  String get transparentTextShadowTitle => '透明模式文字描边';

  @override
  String get transparentTextShadowSubtitle => '阅读器没有底色时，为文字补一层可读性光晕';

  @override
  String get readingAnimationTitle => '阅读过渡动画';

  @override
  String get readingAnimationSubtitle => '滑动动效';

  @override
  String get fontTitle => '字体';

  @override
  String get fontDefault => '默认';

  @override
  String get fontSerif => '衬线';

  @override
  String get fontMonospace => '等宽';

  @override
  String get fontCustom => '自定义';

  @override
  String get customFontChooseAction => '选择字体';

  @override
  String get customFontReplaceAction => '替换字体';

  @override
  String get customFontRemoveAction => '移除字体';

  @override
  String get customFontPickFailure => '无法打开字体选择器';

  @override
  String get customFontLoadFailure => '无法加载这个字体文件';

  @override
  String get fontColorTitle => '字体颜色';

  @override
  String get fontColorAuto => '自动';

  @override
  String get fontColorCustom => '自定义';

  @override
  String get fontColorAutoHint => '自动模式会根据当前阅读背景选择更稳妥的字色；透明模式下会额外加阴影增强可读性。';

  @override
  String get fontColorCustomHint => '自定义颜色会覆盖自动配色；透明模式下仍会保留阴影辅助阅读。';

  @override
  String get fontColorPreviewLabel => '字色预览';

  @override
  String get fontColorPreviewSample => '阅读预览';

  @override
  String get fontColorPresetsLabel => '快捷颜色';

  @override
  String get fontColorHueLabel => '色相';

  @override
  String get fontColorSaturationLabel => '饱和度';

  @override
  String get fontColorLightnessLabel => '亮度';

  @override
  String get fontScaleLabel => '字号';

  @override
  String get lineSpacingLabel => '行距';

  @override
  String get readingWidthLabel => '阅读宽度';

  @override
  String get windowOpacityLabel => '背景透明度';

  @override
  String get transparentModeOverridesOpacity => '透明模式已接管';

  @override
  String get shortcutConflictMessage => '这个快捷键已经分配给其他操作';

  @override
  String positionLabel(Object line) {
    return '位置 $line';
  }

  @override
  String get fileMayBeInvalid => '文件可能已失效';

  @override
  String get removeTooltip => '移除';

  @override
  String get sectionSimpleBookshelf => '简单书架';

  @override
  String get sectionReadingPosition => '阅读定位';

  @override
  String get readingPositionLineStat => '行号';

  @override
  String get readingPositionPageStat => '页号';

  @override
  String get readingPositionProgressStat => '进度';

  @override
  String get sectionReadingSettings => '阅读设置';

  @override
  String get sectionKeyboardControls => '键盘控制';

  @override
  String get sectionAboutApp => '关于应用';

  @override
  String currentLineSummary(Object current, Object total) {
    return '当前第 $current 行，共 $total 行';
  }

  @override
  String currentPageSummary(Object current, Object total) {
    return '当前第 $current 页，共 $total 页';
  }

  @override
  String currentProgressSummary(Object percent) {
    return '当前进度 $percent%';
  }

  @override
  String get jumpToLineLabel => '跳到行号';

  @override
  String jumpToLineHint(Object max) {
    return '输入 1 到 $max';
  }

  @override
  String get jumpToPageLabel => '跳到页号';

  @override
  String jumpToPageHint(Object max) {
    return '输入 1 到 $max';
  }

  @override
  String get jumpToPercentLabel => '跳到百分比';

  @override
  String get jumpToPercentHint => '输入 0 到 100';

  @override
  String get jumpAction => '跳转';

  @override
  String get jumpInputInvalid => '请输入整数';

  @override
  String get searchLabel => '搜索';

  @override
  String get searchHint => '搜索文本';

  @override
  String get searchPreviousAction => '上一个';

  @override
  String get searchNextAction => '下一个';

  @override
  String get searchEmptyQuery => '请输入要搜索的文本';

  @override
  String get searchNotFound => '没有找到匹配文本';

  @override
  String jumpLineOutOfRange(Object max) {
    return '行号范围应为 1 到 $max';
  }

  @override
  String jumpPageOutOfRange(Object max) {
    return '页号范围应为 1 到 $max';
  }

  @override
  String get jumpPercentOutOfRange => '百分比范围应为 0 到 100';

  @override
  String get appVersionLabel => '版本号';

  @override
  String get appVersionLoading => '读取中…';

  @override
  String get appVersionUnavailable => '无法读取';

  @override
  String get checkLatestVersionLabel => '检测最新版本';

  @override
  String get alreadyLatestVersionMessage => '已经是最新版本';

  @override
  String get latestVersionOpenedFallback => '暂时无法自动检测，已为你打开 Release 页面';

  @override
  String get latestVersionReadCurrentFailed => '当前版本读取失败，已为你打开 Release 页面';

  @override
  String get latestVersionCheckFailed => '暂时无法检测最新版本';

  @override
  String get latestVersionOpenFailure => '检测到新版本，但无法打开 Release 页面';

  @override
  String get reportBugTitle => '反馈问题';

  @override
  String get reportBugSubtitle => '打开 GitHub Issues，提交 bug 或改进建议';

  @override
  String get reportBugAction => '打开反馈页';

  @override
  String get feedbackOpenFailure => '无法打开反馈页面';

  @override
  String get panelCurrentBookFallback => '未打开书籍';

  @override
  String get exitMessage => '退出阅读器';

  @override
  String get modeToggleKeyLabel => '按 M 键';

  @override
  String get bossKeyHideNow => '立即隐藏';

  @override
  String get shortcutNextLine => '下一行';

  @override
  String get shortcutPreviousLine => '上一行';

  @override
  String get shortcutNextPage => '下一页';

  @override
  String get shortcutPreviousPage => '上一页';

  @override
  String get shortcutToggleMode => '切换模式';

  @override
  String get shortcutBossKey => '老板键';

  @override
  String get shortcutKeyArrowDown => '下方向键';

  @override
  String get shortcutKeyArrowUp => '上方向键';

  @override
  String get shortcutKeyPageDown => 'PageDown';

  @override
  String get shortcutKeyPageUp => 'PageUp';

  @override
  String get shortcutKeySpace => '空格';

  @override
  String get shortcutKeyShiftSpace => 'Shift + 空格';

  @override
  String sliderPercent(Object value) {
    return '$value%';
  }

  @override
  String sliderMultiplier(Object value) {
    return '${value}x';
  }

  @override
  String sliderDegrees(Object value) {
    return '$value°';
  }
}
