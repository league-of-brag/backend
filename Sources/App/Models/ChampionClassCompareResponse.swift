//
//  ChampionClassCompareResponse.swift
//
//
//  Created by Andreas Hård on 2024-01-01.
//

import Foundation
import Vapor

struct ChampionClassCompareResponse: Content {
    let championClass: ChampionClass
    let winner: String
    let results: [SummonerMasteries]
    
    init(championClass: ChampionClass, results: [SummonerMasteries]) {
        self.championClass = championClass
        self.results = results
        self.winner = results
            .sorted(by: { $0.summary.totalPoints > $1.summary.totalPoints })
            .first?.summoner.name ?? "N/A"
    }
}

struct SummonerMasteries: Content {
    let summoner: SummonerInfo
    let summary: SummonerMasteriesSummary
    let masteries: [MasteryInfo]
    
    init(summoner: SummonerDTO, masteries: [ChampionMasteryDTO]) {
        self.summoner = SummonerInfo(summoner: summoner)
        self.summary = SummonerMasteriesSummary(masteries: masteries)
        self.masteries = masteries.map { MasteryInfo(mastery: $0) }
    }
}

struct SummonerMasteriesSummary: Content {
    let totalPoints: Int
    let numberOfChampionsAtLevel7: Int
    let numberOfChampionsAtLevel6: Int
    let numberOfChampionsAtLevel5: Int
    
    init(masteries: [ChampionMasteryDTO]) {
        self.totalPoints = masteries.map({ $0.championPoints }).reduce(0, +)
        self.numberOfChampionsAtLevel7 = masteries.filter { $0.championLevel == 7 }.count
        self.numberOfChampionsAtLevel6 = masteries.filter { $0.championLevel == 6 }.count
        self.numberOfChampionsAtLevel5 = masteries.filter { $0.championLevel == 5 }.count
    }
}
