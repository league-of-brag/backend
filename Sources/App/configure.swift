import Vapor
import LOLAPIClient

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // register routes
    app.http.server.configuration.hostname = "0.0.0.0"
    guard let riotAPIToken = Environment.get("X-Riot-Token") else {
        // .env is not being read
        fatalError("Missing Environment variable X-Riot-Token")
    }
    let lolAPIClient: LOLAPIClient = LOLAPIClient(riotAPIToken: riotAPIToken)
    let apiHandler: APIHandler = .init(lolAPICient: lolAPIClient)
    try routes(app, apiHandler: apiHandler)
}


