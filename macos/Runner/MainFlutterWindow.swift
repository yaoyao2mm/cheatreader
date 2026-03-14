import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame

    isOpaque = false
    backgroundColor = .clear
    hasShadow = false
    titlebarAppearsTransparent = true
    isMovableByWindowBackground = true

    flutterViewController.backgroundColor = .clear
    flutterViewController.view.wantsLayer = true
    flutterViewController.view.layer?.backgroundColor = NSColor.clear.cgColor

    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    self.contentView?.wantsLayer = true
    self.contentView?.layer?.backgroundColor = NSColor.clear.cgColor

    let bookmarkChannel = FlutterMethodChannel(
      name: "cheatreader/file_bookmarks",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    bookmarkChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "createBookmark":
        guard
          let arguments = call.arguments as? [String: Any],
          let path = arguments["path"] as? String
        else {
          result(
            FlutterError(
              code: "bad_args",
              message: "Missing file path",
              details: nil
            )
          )
          return
        }

        do {
          result(try SecurityScopedBookmarkManager.shared.createBookmark(for: path))
        } catch {
          result(
            FlutterError(
              code: "bookmark_create_failed",
              message: error.localizedDescription,
              details: nil
            )
          )
        }

      case "resolveBookmark":
        guard
          let arguments = call.arguments as? [String: Any],
          let bookmark = arguments["bookmark"] as? String
        else {
          result(
            FlutterError(
              code: "bad_args",
              message: "Missing bookmark",
              details: nil
            )
          )
          return
        }

        do {
          result(try SecurityScopedBookmarkManager.shared.resolveBookmark(bookmark))
        } catch {
          result(
            FlutterError(
              code: "bookmark_resolve_failed",
              message: error.localizedDescription,
              details: nil
            )
          )
        }

      default:
        result(FlutterMethodNotImplemented)
      }
    }

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}

private final class SecurityScopedBookmarkManager {
  static let shared = SecurityScopedBookmarkManager()

  private var activeURLs: [String: URL] = [:]

  private init() {}

  func createBookmark(for path: String) throws -> String {
    let url = URL(fileURLWithPath: path)
    let bookmarkData = try url.bookmarkData(
      options: [.withSecurityScope],
      includingResourceValuesForKeys: nil,
      relativeTo: nil
    )
    return bookmarkData.base64EncodedString()
  }

  func resolveBookmark(_ bookmark: String) throws -> [String: Any] {
    guard let bookmarkData = Data(base64Encoded: bookmark) else {
      throw NSError(domain: "cheatreader", code: 1, userInfo: [
        NSLocalizedDescriptionKey: "Invalid bookmark data"
      ])
    }

    var isStale = false
    let url = try URL(
      resolvingBookmarkData: bookmarkData,
      options: [.withSecurityScope, .withoutUI],
      relativeTo: nil,
      bookmarkDataIsStale: &isStale
    )

    guard url.startAccessingSecurityScopedResource() else {
      throw NSError(domain: "cheatreader", code: 2, userInfo: [
        NSLocalizedDescriptionKey: "Access denied for bookmarked file"
      ])
    }

    activeURLs[url.path] = url

    var response: [String: Any] = ["path": url.path]
    if isStale {
      let refreshedData = try url.bookmarkData(
        options: [.withSecurityScope],
        includingResourceValuesForKeys: nil,
        relativeTo: nil
      )
      response["bookmark"] = refreshedData.base64EncodedString()
    }
    return response
  }
}
