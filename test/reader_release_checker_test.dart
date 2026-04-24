import 'package:cheatreader/src/reader_release_checker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ReaderReleaseChecker', () {
    test('normalizes GitHub release tags to semantic versions', () {
      expect(ReaderReleaseChecker.normalizeVersion('v0.1.14'), '0.1.14');
      expect(ReaderReleaseChecker.normalizeVersion('0.1.14+1'), '0.1.14');
      expect(ReaderReleaseChecker.normalizeVersion('v0.1.14-beta.1'), '0.1.14');
    });

    test('compares versions numerically', () {
      expect(
        ReaderReleaseChecker.compareVersions('0.1.15', '0.1.14'),
        greaterThan(0),
      );
      expect(ReaderReleaseChecker.compareVersions('0.1.14', '0.1.14+1'), 0);
      expect(ReaderReleaseChecker.compareVersions('1.0.0', '1.0'), 0);
      expect(
        ReaderReleaseChecker.compareVersions('0.9.9', '0.10.0'),
        lessThan(0),
      );
    });

    test('fetches the latest release from GitHub response data', () async {
      final checker = ReaderReleaseChecker(
        client: MockClient((request) async {
          expect(request.url, ReaderReleaseChecker.latestReleaseApiUri);
          return http.Response(
            '{"tag_name":"v0.1.15","html_url":"https://github.com/yaoyao2mm/cheatreader/releases/tag/v0.1.15"}',
            200,
          );
        }),
      );

      final latestRelease = await checker.fetchLatestRelease();

      expect(latestRelease, isNotNull);
      expect(latestRelease?.version, '0.1.15');
      expect(
        latestRelease?.url.toString(),
        'https://github.com/yaoyao2mm/cheatreader/releases/tag/v0.1.15',
      );
    });

    test('returns null for malformed release response data', () async {
      final checker = ReaderReleaseChecker(
        client: MockClient((_) async => http.Response('{bad-json', 200)),
      );

      final latestRelease = await checker.fetchLatestRelease();

      expect(latestRelease, isNull);
    });
  });
}
