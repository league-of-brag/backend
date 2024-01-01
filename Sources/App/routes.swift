import Vapor

// MARK: Routes

func routes(_ app: Application) throws {
    /// Example URL: https://domain-example.invalid/region/euw1/summoner/caps/champion-masteries
    app.get("region", ":serverRegion", "summoner", ":summonerName", "champion-masteries") { request -> [ChampionMastery] in
        guard
            let serverRegion = ServerRegion(rawValue: request.parameters.get("serverRegion", as: String.self) ?? ""),
            let summonerName: String = request.parameters.get("summonerName", as: String.self)
        else {
            throw Abort(.badRequest)
        }
        return try await summonerChampionMasteriesHandler(request: request,
                                                          serverRegion: serverRegion,
                                                          summonerName: summonerName)
    }
    
    /// Example URL: https://domain-example.invalid/region/compare-champion
    app.post("compare", "champion") { request -> ChampionCompareResponse in
        do {
            let requestBody = try request.content.decode(ChampionCompareRequest.self)
            return try await championCompareHandler(request: request,
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
            return try await championClassCompareHandler(request: request,
                                                         serverRegion: requestBody.serverRegion,
                                                         championClass: requestBody.championClass,
                                                         summonerNames: requestBody.summonerNames)
        } catch {
            throw Abort(.badRequest)
        }
    }
}

// MARK: Request handlers

func summonerChampionMasteriesHandler(request: Request,
                                      serverRegion: ServerRegion,
                                      summonerName: String) async throws -> [ChampionMastery] {
    let champions = try await fetchChampions(request: request)
    let summoner = try await fetchSummoner(serverRegion: serverRegion,
                                           summonerName: summonerName,
                                           request: request)
    let masteries = try await fetchChampionMasteries(serverRegion: serverRegion,
                                                     puuid: summoner.puuid,
                                                     request: request)
    
    let championMasteries: [ChampionMastery] = try masteries.map { mastery in
        guard let champion: ChampionDTO = champions.data[mastery.championId] else {
            throw Abort(.internalServerError)
        }
        return ChampionMastery(champion: champion, championMastery: mastery)
    }
    return championMasteries
}

func championCompareHandler(request: Request,
                            serverRegion: ServerRegion,
                            championId: ChampionID,
                            summonerNames: [String]) async throws -> ChampionCompareResponse {
    let champions = try await fetchChampions(request: request)
    guard let targetChampion = champions.data[championId] else {
        throw Abort(.internalServerError)
    }
    
    var results: [SummonerMastery] = []
#warning("This should be run in parallel")
    for summonerName in summonerNames {
        let summoner = try await fetchSummoner(serverRegion: serverRegion,
                                               summonerName: summonerName,
                                               request: request)
        let mastery = try await fetchChampionMastery(serverRegion: serverRegion,
                                                     puuid: summoner.puuid,
                                                     championId: championId,
                                                     request: request)
        let result = SummonerMastery(summoner: summoner, mastery: mastery)
        results.append(result)
    }
    let championInfo = ChampionInfo(champion: targetChampion)
    let response = ChampionCompareResponse(championInfo: championInfo, results: results)
    return response
}

func championClassCompareHandler(request: Request,
                                 serverRegion: ServerRegion,
                                 championClass: ChampionClass,
                                 summonerNames: [String]) async throws -> ChampionClassCompareResponse {
    let champions = try await fetchChampions(request: request)
    let filteredChampions: [ChampionDTO] = Array(champions.data.values).filter { $0.tags.contains(championClass) }
    
    guard filteredChampions.count > 0 else {
        throw Abort(.internalServerError)
    }
    
    var results: [SummonerMasteries] = []
#warning("This should be run in parallel")
    for summonerName in summonerNames {
        let summoner = try await fetchSummoner(serverRegion: serverRegion,
                                               summonerName: summonerName,
                                               request: request)
        let masteries = try await fetchChampionMasteries(serverRegion: serverRegion,
                                                         puuid: summoner.puuid,
                                                         request: request)
        let filteredMasteries = masteries.filter { masteryChampion in
            return filteredChampions.contains { $0.key == masteryChampion.championId }
        }
        let result = SummonerMasteries(summoner: summoner, masteries: filteredMasteries)
        results.append(result)
    }
    let response = ChampionClassCompareResponse(championClass: championClass, results: results)
    return response
}

// MARK: Riot APIs

/// See: https://developer.riotgames.com/apis#summoner-v4/GET_getBySummonerName
func fetchSummoner(serverRegion: ServerRegion,
                   summonerName: String,
                   request: Request) async throws -> SummonerDTO {
    guard let riotToken = Environment.get("X-Riot-Token") else {
        throw Abort(.internalServerError)
    }
    let baseURL = baseURL(for: serverRegion)
    let requestURI: URI = "\(baseURL)/lol/summoner/v4/summoners/by-name/\(summonerName)"
    let response = try await request.client.get(requestURI) { req in
        req.headers.add(name: "X-Riot-Token", value: riotToken)
        req.headers.add(name: "Accept-Language", value: "en-US,en;q=0.7")
        req.headers.replaceOrAdd(name: "Accept", value: "application/json;charset=utf-8")
        req.headers.replaceOrAdd(name: "Content-Type", value: "application/json;charset=utf-8")
    }
    guard response.status.isValid() else {
        throw Abort(response.status)
    }
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .millisecondsSince1970
    let json = try response.content.decode(SummonerDTO.self, using: decoder)
    return json
}

/// See: https://developer.riotgames.com/apis#champion-mastery-v4/GET_getAllChampionMasteriesByPUUID
func fetchChampionMasteries(serverRegion: ServerRegion,
                            puuid: String,
                            request: Request) async throws -> [ChampionMasteryDTO] {
    guard let riotToken = Environment.get("X-Riot-Token") else {
        throw Abort(.internalServerError)
    }
    let baseURL = baseURL(for: serverRegion)
    let requestURI: URI = "\(baseURL)/lol/champion-mastery/v4/champion-masteries/by-puuid/\(puuid)"
    let response = try await request.client.get(requestURI) { req in
        req.headers.add(name: "X-Riot-Token", value: riotToken)
        req.headers.add(name: "Accept-Language", value: "en-US,en;q=0.7")
        req.headers.replaceOrAdd(name: "Accept", value: "application/json;charset=utf-8")
        req.headers.replaceOrAdd(name: "Content-Type", value: "application/json;charset=utf-8")
    }
    guard response.status.isValid() else {
        throw Abort(response.status)
    }
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .millisecondsSince1970
    let json = try response.content.decode([ChampionMasteryDTO].self, using: decoder)
    return json
}

/// See: https://developer.riotgames.com/apis#champion-mastery-v4/GET_getChampionMasteryByPUUID
func fetchChampionMastery(serverRegion: ServerRegion,
                          puuid: String,
                          championId: ChampionID,
                          request: Request) async throws -> ChampionMasteryDTO {
    guard let riotToken = Environment.get("X-Riot-Token") else {
        throw Abort(.internalServerError)
    }
    let baseURL = baseURL(for: serverRegion)
    let requestURI: URI = "\(baseURL)/lol/champion-mastery/v4/champion-masteries/by-puuid/\(puuid)/by-champion/\(championId)"
    let response = try await request.client.get(requestURI) { req in
        req.headers.add(name: "X-Riot-Token", value: riotToken)
        req.headers.add(name: "Accept-Language", value: "en-US,en;q=0.7")
        req.headers.replaceOrAdd(name: "Accept", value: "application/json;charset=utf-8")
        req.headers.replaceOrAdd(name: "Content-Type", value: "application/json;charset=utf-8")
    }
    guard response.status.isValid() else {
        throw Abort(response.status)
    }
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .millisecondsSince1970
    let json = try response.content.decode(ChampionMasteryDTO.self, using: decoder)
    return json
}

func baseURL(for serverRegion: ServerRegion) -> String {
    return "https://\(serverRegion.rawValue.lowercased()).api.riotgames.com"
}

func fetchChampions(request: Request) async throws -> ChampionsResponse {
    let requestURI: URI = "https://ddragon.leagueoflegends.com/cdn/13.24.1/data/en_US/champion.json"
    let response = try await request.client.get(requestURI)
    guard response.status.isValid() else {
        throw Abort(response.status)
    }
    let json = try response.content.decode(ChampionsResponse.self)
    return json
}
