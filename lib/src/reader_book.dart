class ReaderBookRecord {
  const ReaderBookRecord({
    required this.path,
    required this.displayName,
    required this.lastOpenedAt,
    required this.lastReadLineIndex,
    required this.burnedLineCount,
    required this.burnModeEnabled,
    this.storedFilePath,
    this.fileBookmark,
  });

  final String path;
  final String displayName;
  final DateTime lastOpenedAt;
  final int lastReadLineIndex;
  final int burnedLineCount;
  final bool burnModeEnabled;
  final String? storedFilePath;
  final String? fileBookmark;

  ReaderBookRecord copyWith({
    String? path,
    String? displayName,
    DateTime? lastOpenedAt,
    int? lastReadLineIndex,
    int? burnedLineCount,
    bool? burnModeEnabled,
    String? storedFilePath,
    String? fileBookmark,
  }) {
    return ReaderBookRecord(
      path: path ?? this.path,
      displayName: displayName ?? this.displayName,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      lastReadLineIndex: lastReadLineIndex ?? this.lastReadLineIndex,
      burnedLineCount: burnedLineCount ?? this.burnedLineCount,
      burnModeEnabled: burnModeEnabled ?? this.burnModeEnabled,
      storedFilePath: storedFilePath ?? this.storedFilePath,
      fileBookmark: fileBookmark ?? this.fileBookmark,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'path': path,
      'displayName': displayName,
      'lastOpenedAt': lastOpenedAt.toIso8601String(),
      'lastReadLineIndex': lastReadLineIndex,
      'burnedLineCount': burnedLineCount,
      'burnModeEnabled': burnModeEnabled,
      'storedFilePath': storedFilePath,
      'fileBookmark': fileBookmark,
    };
  }

  factory ReaderBookRecord.fromJson(Map<String, dynamic> json) {
    return ReaderBookRecord(
      path: json['path'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '未命名文本',
      lastOpenedAt:
          DateTime.tryParse(json['lastOpenedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      lastReadLineIndex: (json['lastReadLineIndex'] as num?)?.toInt() ?? 0,
      burnedLineCount: (json['burnedLineCount'] as num?)?.toInt() ?? 0,
      burnModeEnabled: json['burnModeEnabled'] as bool? ?? false,
      storedFilePath: json['storedFilePath'] as String?,
      fileBookmark: json['fileBookmark'] as String?,
    );
  }
}
