import 'dart:io';

import 'package:flutter/services.dart';

class ResolvedReaderFileBookmark {
  const ResolvedReaderFileBookmark({
    required this.path,
    this.refreshedBookmark,
  });

  final String path;
  final String? refreshedBookmark;
}

abstract class ReaderFileBookmarkService {
  Future<String?> createBookmark(String filePath);

  Future<ResolvedReaderFileBookmark?> resolveBookmark(String bookmark);
}

class PlatformReaderFileBookmarkService implements ReaderFileBookmarkService {
  static const MethodChannel _channel = MethodChannel(
    'cheatreader/file_bookmarks',
  );

  @override
  Future<String?> createBookmark(String filePath) async {
    if (!Platform.isMacOS) {
      return null;
    }

    try {
      return await _channel.invokeMethod<String>(
        'createBookmark',
        <String, Object?>{'path': filePath},
      );
    } on PlatformException {
      return null;
    }
  }

  @override
  Future<ResolvedReaderFileBookmark?> resolveBookmark(String bookmark) async {
    if (!Platform.isMacOS) {
      return null;
    }

    try {
      final result = await _channel.invokeMapMethod<String, Object?>(
        'resolveBookmark',
        <String, Object?>{'bookmark': bookmark},
      );
      if (result == null) {
        return null;
      }

      final path = result['path'] as String?;
      if (path == null || path.isEmpty) {
        return null;
      }

      return ResolvedReaderFileBookmark(
        path: path,
        refreshedBookmark: result['bookmark'] as String?,
      );
    } on PlatformException {
      return null;
    }
  }
}
