import 'dart:convert';

import 'package:http/http.dart' as http;

class ReaderLatestReleaseInfo {
  const ReaderLatestReleaseInfo({required this.version, required this.url});

  final String version;
  final Uri url;
}

class ReaderReleaseChecker {
  static const _requestTimeout = Duration(seconds: 6);

  ReaderReleaseChecker({http.Client? client})
    : _client = client ?? http.Client();

  static final Uri latestReleaseApiUri = Uri.parse(
    'https://api.github.com/repos/yaoyao2mm/cheatreader/releases/latest',
  );

  final http.Client _client;

  Future<ReaderLatestReleaseInfo?> fetchLatestRelease() async {
    final response = await _client
        .get(
          latestReleaseApiUri,
          headers: const <String, String>{
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28',
            'User-Agent': 'CheatReader-Version-Checker',
          },
        )
        .timeout(_requestTimeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    final tagName = decoded['tag_name'];
    final htmlUrl = decoded['html_url'];
    if (tagName is! String || htmlUrl is! String) {
      return null;
    }

    final normalizedVersion = normalizeVersion(tagName);
    final releaseUrl = Uri.tryParse(htmlUrl);
    if (normalizedVersion == null || releaseUrl == null) {
      return null;
    }

    return ReaderLatestReleaseInfo(version: normalizedVersion, url: releaseUrl);
  }

  void dispose() {
    _client.close();
  }

  static String? normalizeVersion(String rawVersion) {
    final trimmed = rawVersion.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final withoutPrefix = trimmed.startsWith('v') || trimmed.startsWith('V')
        ? trimmed.substring(1)
        : trimmed;
    final baseVersion = withoutPrefix.split('+').first.split('-').first.trim();
    if (baseVersion.isEmpty) {
      return null;
    }

    final segments = baseVersion.split('.');
    if (segments.any((segment) => segment.isEmpty)) {
      return null;
    }
    if (segments.any((segment) => int.tryParse(segment) == null)) {
      return null;
    }

    return segments.join('.');
  }

  static int compareVersions(String left, String right) {
    final normalizedLeft = normalizeVersion(left);
    final normalizedRight = normalizeVersion(right);
    if (normalizedLeft == null || normalizedRight == null) {
      throw ArgumentError('Invalid version string.');
    }

    final leftParts = normalizedLeft
        .split('.')
        .map(int.parse)
        .toList(growable: false);
    final rightParts = normalizedRight
        .split('.')
        .map(int.parse)
        .toList(growable: false);
    final maxLength = leftParts.length > rightParts.length
        ? leftParts.length
        : rightParts.length;

    for (var index = 0; index < maxLength; index += 1) {
      final leftValue = index < leftParts.length ? leftParts[index] : 0;
      final rightValue = index < rightParts.length ? rightParts[index] : 0;
      if (leftValue != rightValue) {
        return leftValue.compareTo(rightValue);
      }
    }

    return 0;
  }
}
