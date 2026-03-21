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
  String get importUnsupportedFormat => '仅支持导入 txt / epub / html / md / fb2';

  @override
  String get dropPrompt => '拖入 txt / epub / html / md / fb2 开始阅读';

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
  String get triggerKeyboardLong => '按 M 键';

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
  String get fontTitle => '字体';

  @override
  String get fontDefault => '默认';

  @override
  String get fontSerif => '衬线';

  @override
  String get fontMonospace => '等宽';

  @override
  String get fontScaleLabel => '字号';

  @override
  String get windowOpacityLabel => '背景透明度';

  @override
  String get transparentModeOverridesOpacity => '透明模式已接管';

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
  String get sectionReadingSettings => '阅读设置';

  @override
  String get sectionAboutApp => '关于应用';

  @override
  String get appVersionLabel => '版本号';

  @override
  String get appVersionLoading => '读取中…';

  @override
  String get appVersionUnavailable => '无法读取';

  @override
  String get copyVersionLabel => '复制版本号';

  @override
  String get versionCopiedMessage => '版本号已复制';

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
  String sliderPercent(Object value) {
    return '$value%';
  }
}
