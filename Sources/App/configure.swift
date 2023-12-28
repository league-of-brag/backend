import Vapor
import VaporRouting

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // register routes
    app.router = router
      .baseURL("http://127.0.0.1:8080")
      .eraseToAnyParserPrinter()

    app.mount(app.router, use: siteHandler)
}

enum SiteRouterKey: StorageKey {
  typealias Value = AnyParserPrinter<URLRequestData, SiteRoute>
}

extension Application {
  var router: SiteRouterKey.Value {
    get {
      self.storage[SiteRouterKey.self]!
    }
    set {
      self.storage[SiteRouterKey.self] = newValue
    }
  }
}
