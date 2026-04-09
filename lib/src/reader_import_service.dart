import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:enough_convert/gbk.dart';
import 'package:file_selector/file_selector.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:path/path.dart' as path;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:xml/xml.dart';

class ImportedTextFile {
  const ImportedTextFile({
    required this.path,
    required this.displayName,
    required this.content,
  });

  final String path;
  final String displayName;
  final String content;
}

abstract class ReaderImportService {
  Future<ImportedTextFile?> pickTxtFile();

  Future<ImportedTextFile> openTxtFile(String filePath);

  bool isSupportedTextFilePath(String filePath);
}

class FileSelectorReaderImportService implements ReaderImportService {
  static const _supportedExtensions = <String>{
    '.txt',
    '.md',
    '.markdown',
    '.html',
    '.htm',
    '.xhtml',
    '.fb2',
    '.epub',
    '.docx',
    '.pdf',
  };

  static const XTypeGroup _bookTypeGroup = XTypeGroup(
    label: 'ebook',
    extensions: <String>[
      'txt',
      'md',
      'markdown',
      'html',
      'htm',
      'xhtml',
      'fb2',
      'epub',
      'docx',
      'pdf',
    ],
    uniformTypeIdentifiers: <String>[
      'public.plain-text',
      'public.html',
      'public.pdf',
      'org.idpf.epub-container',
      'org.fictionbook.fb2+xml',
      'org.openxmlformats.wordprocessingml.document',
    ],
  );

  @override
  bool isSupportedTextFilePath(String filePath) {
    return _supportedExtensions.contains(
      path.extension(filePath).toLowerCase(),
    );
  }

  @override
  Future<ImportedTextFile?> pickTxtFile() async {
    final file = await openFile(
      acceptedTypeGroups: const <XTypeGroup>[_bookTypeGroup],
    );
    if (file == null) {
      return null;
    }
    return openTxtFile(file.path);
  }

  @override
  Future<ImportedTextFile> openTxtFile(String filePath) async {
    final file = XFile(filePath);
    final bytes = await file.readAsBytes();
    return ImportedTextFile(
      path: filePath,
      displayName: path.basename(filePath),
      content: _extractContent(filePath: filePath, bytes: bytes),
    );
  }

  String _extractContent({required String filePath, required List<int> bytes}) {
    final extension = path.extension(filePath).toLowerCase();
    return switch (extension) {
      '.txt' => _cleanExtractedText(_decodeTextBytes(bytes)),
      '.md' || '.markdown' => _extractMarkdownText(_decodeTextBytes(bytes)),
      '.html' ||
      '.htm' ||
      '.xhtml' => _extractHtmlText(_decodeTextBytes(bytes)),
      '.fb2' => _extractFb2Text(_decodeTextBytes(bytes)),
      '.epub' => _extractEpubText(bytes),
      '.docx' => _extractDocxText(bytes),
      '.pdf' => _extractPdfText(bytes),
      _ => throw UnsupportedError('Unsupported ebook format: $extension'),
    };
  }

  String _extractMarkdownText(String source) {
    var text = source
        .replaceAll(RegExp(r'```[\s\S]*?```'), '\n')
        .replaceAll(RegExp(r'`([^`]*)`'), r'$1')
        .replaceAll(RegExp(r'!\[[^\]]*\]\([^)]+\)'), '')
        .replaceAll(RegExp(r'^\s{0,3}#{1,6}\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^\s{0,3}>\s?', multiLine: true), '')
        .replaceAll(RegExp(r'^\s*([-*+]|\d+\.)\s+', multiLine: true), '')
        .replaceAll(RegExp(r'(\*\*|__|\*|_|~~)'), '');
    text = text.replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\([^)]+\)'),
      (match) => match.group(1) ?? '',
    );
    return _cleanExtractedText(text);
  }

  String _extractHtmlText(String source) {
    final document = html_parser.parse(source);
    for (final selector in const ['script', 'style', 'noscript']) {
      document.querySelectorAll(selector).forEach((node) => node.remove());
    }

    final buffer = StringBuffer();
    void appendNodeText(dynamic node) {
      final localName = node.localName?.toLowerCase();
      if (localName != null &&
          const {
            'p',
            'div',
            'section',
            'article',
            'li',
            'tr',
            'h1',
            'h2',
            'h3',
            'h4',
            'h5',
            'h6',
            'br',
          }.contains(localName)) {
        buffer.writeln();
      }

      for (final child in node.nodes) {
        if (child.nodeType == 3) {
          buffer.write(child.text);
        } else {
          appendNodeText(child);
        }
      }

      if (localName != null &&
          const {
            'p',
            'div',
            'section',
            'article',
            'li',
            'tr',
            'h1',
            'h2',
            'h3',
            'h4',
            'h5',
            'h6',
          }.contains(localName)) {
        buffer.writeln();
      }
    }

    appendNodeText(document.body ?? document.documentElement ?? document);
    return _cleanExtractedText(buffer.toString());
  }

  String _extractFb2Text(String source) {
    final document = XmlDocument.parse(source);
    final bodies = document.findAllElements('body');
    final buffer = StringBuffer();
    for (final body in bodies) {
      for (final node in body.descendants) {
        if (node is XmlText) {
          buffer.write(node.value);
        } else if (node is XmlElement &&
            const {
              'section',
              'title',
              'p',
              'subtitle',
              'poem',
              'stanza',
              'v',
            }.contains(node.name.local.toLowerCase())) {
          buffer.writeln();
        }
      }
      buffer.writeln();
    }
    return _cleanExtractedText(buffer.toString());
  }

  String _extractEpubText(List<int> bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final files = <String, ArchiveFile>{};
    for (final file in archive) {
      files[file.name] = file;
    }

    final containerXml = _archiveFileString(
      files,
      'META-INF/container.xml',
      preferUtf8: true,
    );
    final containerDoc = XmlDocument.parse(containerXml);
    final rootfile = containerDoc
        .findAllElements('rootfile')
        .map((node) => node.getAttribute('full-path'))
        .whereType<String>()
        .first;

    final opfXml = _archiveFileString(files, rootfile, preferUtf8: true);
    final opfDoc = XmlDocument.parse(opfXml);
    final opfDirectory = path.dirname(rootfile) == '.'
        ? ''
        : path.dirname(rootfile);

    final manifestById = <String, String>{};
    for (final item in opfDoc.findAllElements('item')) {
      final id = item.getAttribute('id');
      final href = item.getAttribute('href');
      if (id != null && href != null) {
        manifestById[id] = _joinArchivePath(opfDirectory, href);
      }
    }

    final contentParts = <String>[];
    for (final itemref in opfDoc.findAllElements('itemref')) {
      final idRef = itemref.getAttribute('idref');
      if (idRef == null) {
        continue;
      }
      final chapterPath = manifestById[idRef];
      if (chapterPath == null) {
        continue;
      }
      final chapterSource = _archiveFileString(
        files,
        chapterPath,
        preferUtf8: true,
      );
      final chapterText = _extractHtmlText(chapterSource);
      if (chapterText.isNotEmpty) {
        contentParts.add(chapterText);
      }
    }

    return _cleanExtractedText(contentParts.join('\n\n'));
  }

  String _extractDocxText(List<int> bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final files = <String, ArchiveFile>{};
    for (final file in archive) {
      files[file.name] = file;
    }

    final documentXml = _archiveFileString(
      files,
      'word/document.xml',
      preferUtf8: true,
    );
    final document = XmlDocument.parse(documentXml);
    final body = document.descendants.whereType<XmlElement>().firstWhere(
      (element) => element.name.local.toLowerCase() == 'body',
      orElse: () =>
          throw const FormatException('Missing document body in docx'),
    );

    final paragraphs = <String>[];
    for (final paragraph in body.descendants.whereType<XmlElement>().where(
      (element) => element.name.local.toLowerCase() == 'p',
    )) {
      final paragraphText = _cleanExtractedText(
        _extractDocxParagraphText(paragraph),
      );
      if (paragraphText.isNotEmpty) {
        paragraphs.add(paragraphText);
      }
    }

    final content = _cleanExtractedText(paragraphs.join('\n\n'));
    if (content.isEmpty) {
      throw const FormatException('No readable text found in docx');
    }
    return content;
  }

  String _extractDocxParagraphText(XmlNode node) {
    final buffer = StringBuffer();

    void appendNode(XmlNode current) {
      if (current is XmlText) {
        buffer.write(current.value);
        return;
      }

      if (current is! XmlElement) {
        return;
      }

      switch (current.name.local.toLowerCase()) {
        case 'tab':
          buffer.write(' ');
          break;
        case 'br':
        case 'cr':
          buffer.writeln();
          break;
        case 'noBreakHyphen':
          buffer.write('-');
          break;
        default:
          break;
      }

      for (final child in current.children) {
        appendNode(child);
      }
    }

    appendNode(node);
    return buffer.toString();
  }

  String _extractPdfText(List<int> bytes) {
    final document = PdfDocument(inputBytes: bytes);
    try {
      final extracted = PdfTextExtractor(document).extractText();
      final content = _cleanExtractedText(
        extracted.replaceAll('\r\n', '\n').replaceAll('\r', '\n'),
      );
      if (content.isEmpty) {
        throw const FormatException('No readable text found in pdf');
      }
      return content;
    } finally {
      document.dispose();
    }
  }

  String _archiveFileString(
    Map<String, ArchiveFile> files,
    String filePath, {
    bool preferUtf8 = false,
  }) {
    final normalizedPath = filePath.replaceAll('\\', '/');
    final archiveFile = files[normalizedPath];
    if (archiveFile == null) {
      throw FormatException('Missing archive entry: $normalizedPath');
    }
    final bytes = archiveFile.readBytes();
    if (bytes == null) {
      throw FormatException('Unreadable archive entry: $normalizedPath');
    }
    if (preferUtf8) {
      try {
        return utf8.decode(bytes);
      } on FormatException {
        // Fall through to the generic decoder.
      }
    }
    return _decodeTextBytes(bytes);
  }

  String _joinArchivePath(String baseDirectory, String relativePath) {
    final joined = baseDirectory.isEmpty
        ? relativePath
        : path.posix.join(baseDirectory, relativePath);
    return path.posix.normalize(joined);
  }

  String _cleanExtractedText(String text) {
    return text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll('\u00A0', ' ')
        .replaceAll('\t', ' ')
        .replaceAll(RegExp(r'[ \t]+\n'), '\n')
        .replaceAll(RegExp(r'\n[ \t]+'), '\n')
        .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
        .replaceAll(RegExp(r'\n{2,}'), '\n')
        .trim();
  }

  String _decodeTextBytes(List<int> bytes) {
    if (bytes.isEmpty) {
      return '';
    }

    if (_hasUtf8Bom(bytes)) {
      return utf8.decode(bytes.sublist(3));
    }

    if (_hasUtf16LeBom(bytes)) {
      return _decodeUtf16(bytes.sublist(2), littleEndian: true);
    }

    if (_hasUtf16BeBom(bytes)) {
      return _decodeUtf16(bytes.sublist(2), littleEndian: false);
    }

    final candidates = <String>[];

    try {
      candidates.add(utf8.decode(bytes));
    } on FormatException {
      // Fall through to other decoders.
    }

    try {
      candidates.add(gbk.decode(bytes));
    } on FormatException {
      // Fall through to UTF-16 heuristics.
    }

    if (bytes.length >= 2) {
      candidates
        ..add(_decodeUtf16(bytes, littleEndian: true))
        ..add(_decodeUtf16(bytes, littleEndian: false));
    }

    return candidates.reduce((best, current) {
      return _scoreDecodedText(current) > _scoreDecodedText(best)
          ? current
          : best;
    });
  }

  bool _hasUtf8Bom(List<int> bytes) {
    return bytes.length >= 3 &&
        bytes[0] == 0xEF &&
        bytes[1] == 0xBB &&
        bytes[2] == 0xBF;
  }

  bool _hasUtf16LeBom(List<int> bytes) {
    return bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE;
  }

  bool _hasUtf16BeBom(List<int> bytes) {
    return bytes.length >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF;
  }

  String _decodeUtf16(List<int> bytes, {required bool littleEndian}) {
    final codeUnits = <int>[];
    for (var index = 0; index + 1 < bytes.length; index += 2) {
      final codeUnit = littleEndian
          ? bytes[index] | (bytes[index + 1] << 8)
          : (bytes[index] << 8) | bytes[index + 1];
      codeUnits.add(codeUnit);
    }
    return String.fromCharCodes(codeUnits);
  }

  double _scoreDecodedText(String text) {
    if (text.isEmpty) {
      return 0;
    }

    var score = 0.0;
    final sample = text.runes.take(4096);
    for (final rune in sample) {
      if (rune == 0x0000 || rune == 0xFFFD) {
        score -= 8;
        continue;
      }

      if (rune == 0x0009 || rune == 0x000A || rune == 0x000D) {
        score += 0.5;
        continue;
      }

      if (rune < 0x0020 || (rune >= 0x007F && rune <= 0x009F)) {
        score -= 6;
        continue;
      }

      if ((rune >= 0x0020 && rune <= 0x007E) ||
          (rune >= 0x4E00 && rune <= 0x9FFF) ||
          (rune >= 0x3400 && rune <= 0x4DBF) ||
          (rune >= 0x3000 && rune <= 0x303F) ||
          (rune >= 0xFF00 && rune <= 0xFFEF)) {
        score += 1.2;
        continue;
      }

      score += 0.4;
    }

    return score;
  }
}
