import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:cheatreader/src/reader_import_service.dart';
import 'package:enough_convert/gbk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FileSelectorReaderImportService', () {
    test('decodes GBK encoded txt files', () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'cheatreader-import-test',
      );
      final file = File('${tempDirectory.path}/龙骨焚箱.txt');
      await file.writeAsBytes(gbk.encode('龙骨焚箱\n第一章'));

      final service = FileSelectorReaderImportService();
      final imported = await service.openTxtFile(file.path);

      expect(imported.displayName, '龙骨焚箱.txt');
      expect(imported.content, '龙骨焚箱\n第一章');

      await tempDirectory.delete(recursive: true);
    });

    test('decodes UTF-16LE txt files without BOM', () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'cheatreader-import-test',
      );
      final file = File('${tempDirectory.path}/无标记编码.txt');
      final codeUnits = '第一行\n第二行'.codeUnits;
      final bytes = BytesBuilder();
      for (final codeUnit in codeUnits) {
        bytes
          ..addByte(codeUnit & 0xFF)
          ..addByte(codeUnit >> 8);
      }
      await file.writeAsBytes(bytes.toBytes());

      final service = FileSelectorReaderImportService();
      final imported = await service.openTxtFile(file.path);

      expect(imported.displayName, '无标记编码.txt');
      expect(imported.content, '第一行\n第二行');

      await tempDirectory.delete(recursive: true);
    });

    test('extracts readable text from markdown files', () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'cheatreader-import-test',
      );
      final file = File('${tempDirectory.path}/目录.md');
      await file.writeAsString('# 标题\n\n- 第一项\n- [第二项](https://example.com)\n');

      final service = FileSelectorReaderImportService();
      final imported = await service.openTxtFile(file.path);

      expect(imported.content, '标题\n第一项\n第二项');

      await tempDirectory.delete(recursive: true);
    });

    test('extracts readable text from html files', () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'cheatreader-import-test',
      );
      final file = File('${tempDirectory.path}/chapter.html');
      await file.writeAsString(
        '<html><body><h1>标题</h1><p>第一段</p><p>第二段</p></body></html>',
      );

      final service = FileSelectorReaderImportService();
      final imported = await service.openTxtFile(file.path);

      expect(imported.content, '标题\n\n第一段\n\n第二段');

      await tempDirectory.delete(recursive: true);
    });

    test('extracts readable text from fb2 files', () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'cheatreader-import-test',
      );
      final file = File('${tempDirectory.path}/story.fb2');
      await file.writeAsString('''
<?xml version="1.0" encoding="utf-8"?>
<FictionBook>
  <body>
    <section>
      <title><p>标题</p></title>
      <p>第一段</p>
      <p>第二段</p>
    </section>
  </body>
</FictionBook>
''');

      final service = FileSelectorReaderImportService();
      final imported = await service.openTxtFile(file.path);

      expect(imported.content, '标题\n\n第一段\n\n第二段');

      await tempDirectory.delete(recursive: true);
    });

    test('extracts readable text from epub files', () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'cheatreader-import-test',
      );
      final file = File('${tempDirectory.path}/novel.epub');

      final containerXml = Uint8List.fromList(utf8.encode('''
<?xml version="1.0" encoding="UTF-8"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles>
    <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
  </rootfiles>
</container>
'''));
      final contentOpf = Uint8List.fromList(utf8.encode('''
<?xml version="1.0" encoding="utf-8"?>
<package version="2.0" xmlns="http://www.idpf.org/2007/opf">
  <manifest>
    <item id="chapter1" href="chapter1.xhtml" media-type="application/xhtml+xml"/>
    <item id="chapter2" href="chapter2.xhtml" media-type="application/xhtml+xml"/>
  </manifest>
  <spine>
    <itemref idref="chapter1"/>
    <itemref idref="chapter2"/>
  </spine>
</package>
'''));
      final chapter1 = Uint8List.fromList(
        utf8.encode('<html><body><h1>第一章</h1><p>第一段</p></body></html>'),
      );
      final chapter2 = Uint8List.fromList(
        utf8.encode('<html><body><h1>第二章</h1><p>第二段</p></body></html>'),
      );
      final archive = Archive()
        ..addFile(
          ArchiveFile('META-INF/container.xml', containerXml.length, containerXml),
        )
        ..addFile(
          ArchiveFile('OEBPS/content.opf', contentOpf.length, contentOpf),
        )
        ..addFile(
          ArchiveFile('OEBPS/chapter1.xhtml', chapter1.length, chapter1),
        )
        ..addFile(
          ArchiveFile('OEBPS/chapter2.xhtml', chapter2.length, chapter2),
        );

      await file.writeAsBytes(ZipEncoder().encode(archive));

      final service = FileSelectorReaderImportService();
      final imported = await service.openTxtFile(file.path);

      expect(imported.content, '第一章\n\n第一段\n\n第二章\n\n第二段');

      await tempDirectory.delete(recursive: true);
    });
  });
}
