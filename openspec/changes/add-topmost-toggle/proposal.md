## Why

当前阅读器默认“始终置顶”，会干扰用户切换到其他工作窗口。用户希望阅读器默认可被遮挡，只在需要时手动开启置顶，同时保留快速把阅读器拉回前台的能力。

## What Changes

- 将阅读器“始终置顶”默认状态调整为关闭（仅在用户未设置过该项时生效）。
- 保留并明确菜单中的“始终置顶”开关，需用户手动开启后才保持最前。
- 当阅读器被其他窗口遮挡时，点击任务栏/Dock 图标可将阅读器恢复到前台并聚焦。
- 继续在不支持浮窗控制的平台上隐藏或禁用对应控制项，避免异常行为。

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `floating-reader-window`: 调整默认窗口层级行为，并补充从任务栏/Dock 激活后回到前台的要求。
- `reader-control-panel`: 明确“始终置顶”为手动开启项，并要求切换后立即生效。

## Impact

- 受影响代码主要在窗口控制与设置默认值：`lib/src/reader_settings.dart`、`lib/src/reader_preferences.dart`、`lib/src/platform_window_controller_desktop.dart`、`lib/src/reader_app.dart`。
- 无外部 API 变更；属于桌面端交互行为与默认配置调整。
- 需要补充窗口激活相关手动测试（macOS/Windows/Linux）。
