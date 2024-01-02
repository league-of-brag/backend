//
//  ChampionController.swift
//
//
//  Created by Andreas Hård on 2024-02-03.
//

import Foundation
import Vapor
import LOLAPIClient

class APIHandler {
    let lolAPICient: LOLAPIClient
    
    init(lolAPICient: LOLAPIClient) {
        self.lolAPICient = lolAPICient
    }
    
    // MARK: Request handlers
    
    func summonerChampionMasteriesHandler(request: Request,
                                          serverRegion: ServerRegion,
                                          summonerName: String) async throws -> [ChampionMastery] {
        let champions = try await lolAPICient.fetchChampions(request: request)
        let summoner = try await lolAPICient.fetchSummoner(serverRegion: serverRegion,
                                                           summonerName: summonerName,
                                                           request: request)
        let masteries = try await lolAPICient.fetchChampionMasteries(serverRegion: serverRegion,
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
        let champions = try await lolAPICient.fetchChampions(request: request)
        guard let targetChampion = champions.data[championId] else {
            throw Abort(.internalServerError)
        }
        let results = try await withThrowingTaskGroup(of: SummonerMastery.self) { taskGroup in
            for summonerName in summonerNames {
                taskGroup.addTask {
                    return try await self.fetchSummonerChampionMastery(request: request,
                                                                       serverRegion: serverRegion,
                                                                       summonerName: summonerName,
                                                                       championId: championId)
                }
            }
            var results: [SummonerMastery] = []
            for try await result in taskGroup {
                results.append(result)
            }
            return results
        }
        let championInfo = ChampionInfo(champion: targetChampion)
        let response = ChampionCompareResponse(championInfo: championInfo, results: results)
        return response
    }
    
    func championClassCompareHandler(request: Request,
                                     serverRegion: ServerRegion,
                                     championClass: ChampionClass,
                                     summonerNames: [String]) async throws -> ChampionClassCompareResponse {
        let champions = try await lolAPICient.fetchChampions(request: request)
        let filteredChampions: [ChampionDTO] = Array(champions.data.values).filter { $0.tags.contains(championClass) }
        
        guard filteredChampions.count > 0 else {
            throw Abort(.internalServerError)
        }
        
        let results = try await withThrowingTaskGroup(of: SummonerMasteries.self) { taskGroup in
            for summonerName in summonerNames {
                taskGroup.addTask {
                    return try await self.fetchSummonerChampionMasteries(request: request,
                                                                         serverRegion: serverRegion,
                                                                         filteredChampions: filteredChampions,
                                                                         summonerName: summonerName)
                }
            }
            var results: [SummonerMasteries] = []
            for try await result in taskGroup {
                results.append(result)
            }
            return results
        }
        
        let response = ChampionClassCompareResponse(championClass: championClass, results: results)
        return response
    }
    
    // MARK: Middleware Riot APIs
    
    func fetchSummonerChampionMastery(request: Request,
                                      serverRegion: ServerRegion,
                                      summonerName: String,
                                      championId: ChampionID) async throws -> SummonerMastery {
        let summoner = try await lolAPICient.fetchSummoner(serverRegion: serverRegion,
                                                           summonerName: summonerName,
                                                           request: request)
        let mastery = try await lolAPICient.fetchChampionMastery(serverRegion: serverRegion,
                                                                 puuid: summoner.puuid,
                                                                 championId: championId,
                                                                 request: request)
        return SummonerMastery(summoner: summoner, mastery: mastery)
    }
    
    func fetchSummonerChampionMasteries(request: Request,
                                        serverRegion: ServerRegion,
                                        filteredChampions: [ChampionDTO],
                                        summonerName: String) async throws -> SummonerMasteries {
        let summoner = try await lolAPICient.fetchSummoner(serverRegion: serverRegion,
                                                           summonerName: summonerName,
                                                           request: request)
        let masteries = try await lolAPICient.fetchChampionMasteries(serverRegion: serverRegion,
                                                                     puuid: summoner.puuid,
                                                                     request: request)
        let filteredMasteries = masteries.filter { masteryChampion in
            return filteredChampions.contains { $0.key == masteryChampion.championId }
        }
        return SummonerMasteries(summoner: summoner, masteries: filteredMasteries)
    }
    
}
