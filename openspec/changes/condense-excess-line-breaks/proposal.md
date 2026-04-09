## Why

部分用户导入的文档包含大量连续换行，导致阅读器中出现大面积空白、阅读节奏被打断。需要在导入阶段自动压缩多余换行，让文本更连续可读。

## What Changes

- 在文本导入归一化流程中增加“连续换行压缩”规则，将连续空行压缩为单行分隔。
- 将该规则统一应用到已支持的导入格式（`txt`、`md`、`html`、`fb2`、`epub`、`docx`、`pdf`）的最终纯文本输出。
- 保持现有导入入口（拖拽、文件选择、控制面板导入）不变，仅优化导入后文本质量。
- 保持导入失败与不支持格式的行为不变。

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `txt-reading-library`: 导入 txt 及同类文本文件后，增加连续换行压缩，减少大段空白。
- `document-text-import`: docx/pdf 提取后的归一化文本增加连续换行压缩，保证导入文本更连贯。

## Impact

- 主要影响文本导入与归一化实现：`lib/src/reader_import_service.dart`。
- 需要补充导入相关自动化测试，覆盖“多连续换行被压缩”与“已有导入能力不回退”。
- 无外部 API 与平台依赖变更。
