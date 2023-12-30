//
//  ChampionMastery.swift
//
//
//  Created by Andreas Hård on 2023-12-30.
//

import Foundation
import Vapor

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
    let tags: [String]
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
        self.imageURL = Self.imageURL(for: champion.imageURLFormattedName)
        self.splashImageURL = Self.splashImageURL(for: champion.imageURLFormattedName)
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
    
    private static func imageURL(for name: String) -> URL {
        return URL(string: "https://ddragon.leagueoflegends.com/cdn/13.24.1/img/champion/\(name).png")!
    }
    
    private static func splashImageURL(for name: String) -> URL {
        return URL(string: "https://ddragon.leagueoflegends.com/cdn/img/champion/loading/\(name)_0.jpg")!
    }
}
