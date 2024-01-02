import Vapor
import LOLAPIClient

// MARK: Routes

func routes(_ app: Application,
            apiHandler: APIHandler) throws {    
    /// Example URL: https://domain-example.invalid/region/euw1/summoner/caps/champion-masteries
    app.get("region", ":serverRegion", "summoner", ":summonerName", "champion-masteries") { request -> [ChampionMastery] in
        guard
            let serverRegion = ServerRegion(rawValue: request.parameters.get("serverRegion", as: String.self) ?? ""),
            let summonerName: String = request.parameters.get("summonerName", as: String.self)
        else {
            throw Abort(.badRequest)
        }
        return try await apiHandler.summonerChampionMasteriesHandler(request: request,
                                                                     serverRegion: serverRegion,
                                                                     summonerName: summonerName)
    }
    
    /// Example URL: https://domain-example.invalid/region/compare-champion
    app.post("compare", "champion") { request -> ChampionCompareResponse in
        do {
            let requestBody = try request.content.decode(ChampionCompareRequest.self)
            return try await apiHandler.championCompareHandler(request: request,
                                                               serverRegion: requestBody.serverRegion,
                                                               championId: requestBody.championId,
                                                               summonerNames: requestBody.summonerNames)
        } catch {
            throw Abort(.badRequest)
        }
    }
    
    app.post("compare", "champion-class") { request -> ChampionClassCompareResponse in
        do {
            let requestBody = try request.content.decode(ChampionClassCompareRequest.self)
            return try await apiHandler.championClassCompareHandler(request: request,
                                                                    serverRegion: requestBody.serverRegion,
                                                                    championClass: requestBody.championClass,
                                                                    summonerNames: requestBody.summonerNames)
        } catch {
            throw Abort(.badRequest)
        }
    }
}

