//
//  ChampionMastery.swift
//
//
//  Created by Andreas Hård on 2023-12-30.
//

import Foundation
import Vapor
import LOLAPIClient

struct ChampionMastery: Content {
    let id: String
    let name: String
    let championLevel: Int
    let points: Int
    let pointsSinceLastLevel: Int64
    let pointsUntilNextLevel: Int64
    let tokensEarned: Int
    let tokensEarnedOutOfMax: String
    let lastTimePlayed: Date
    let tags: [ChampionClass]
    let imageURL: URL
    let splashImageURL: URL
    
    init(champion: ChampionDTO, championMastery: ChampionMasteryDTO) {
        self.id = champion.id
        self.name = champion.name
        self.championLevel = championMastery.championLevel
        self.points = championMastery.championPoints
        self.pointsSinceLastLevel = championMastery.championPointsSinceLastLevel
        self.pointsUntilNextLevel = championMastery.championPointsUntilNextLevel
        self.tokensEarned = championMastery.tokensEarned
        self.tokensEarnedOutOfMax = Self.calculateTokensEarnedOutOfMax(tokensEarned: championMastery.tokensEarned,
                                                                       championLevel: championMastery.championLevel)
        self.lastTimePlayed = championMastery.lastPlayTime
        self.tags = champion.tags
        self.imageURL = champion.imageURL
        self.splashImageURL = champion.splashImageURL
    }
    
    private static func calculateTokensEarnedOutOfMax(tokensEarned: Int,
                                                      championLevel: Int) -> String {
        if championLevel == 6 {
            return "\(tokensEarned)/3"
        }
        else if championLevel == 5 {
            return "\(tokensEarned)/2"
        }
        else {
            return "N/A"
        }
    }
}
