import Vapor
import VaporRouting

enum SiteRoute {
    case region(RegionRoute)
}

enum RegionRoute {
    case user(UserRoute)
}

enum UserRoute {
    case championMastery
//    case top100
//    case levelUp
}

let userRouter = OneOf {
    Route(.case(UserRoute.championMastery)) {
        Path { "champion-mastery" }
    }
}

let regionRouter = OneOf {
    Route(.case(RegionRoute.user)) {
        Path { "user" }
        userRouter
    }
}

let router = OneOf {
    Route(.case(SiteRoute.region)) {
        Path { "region" }
        regionRouter
    }
}

func siteHandler(request: Request,
                 route: SiteRoute) async throws -> AsyncResponseEncodable {
    switch route {
    case .region(let regionRoute):
        return try await regionHandler(request: request, route: regionRoute)
    }
}

func regionHandler(request: Request,
                 route: RegionRoute) async throws -> AsyncResponseEncodable {
    switch route {
    case .user(let userRoute):
        return try await userHandler(request: request, route: userRoute)
    }
}

func userHandler(request: Request,
                 route: UserRoute) async throws -> AsyncResponseEncodable {
    switch route {
    case .championMastery:
        let champions = try await fetchChampions(request: request)
        let serverRegion: ServerRegion = .europeWest
        let summoner = try await fetchSummoner(serverRegion: serverRegion, 
                                               summonerName: "andygägä",
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
