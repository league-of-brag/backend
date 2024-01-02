//
//  ChampionCompareResponse.swift
//
//
//  Created by Andreas Hård on 2024-01-01.
//

import Foundation
import Vapor
import LOLAPIClient

struct ChampionCompareResponse: Content {
    let championInfo: ChampionInfo
    let results: [SummonerMastery]
}

struct SummonerMastery: Content {
    let summoner: SummonerInfo
    let mastery: MasteryInfo
    
    init(summoner: SummonerDTO, mastery: ChampionMasteryDTO) {
        self.summoner = SummonerInfo(summoner: summoner)
        self.mastery = MasteryInfo(mastery: mastery)
    }
}

struct SummonerInfo: Content {
    /// ID of the summoner icon associated with the summoner.
    let profileIconImageURL: URL
    /// Summoner name.
    let name: String
    /// Summoner level associated with the summoner.
    let summonerLevel: Int64
    
    init(summoner: SummonerDTO) {
        self.profileIconImageURL = summoner.profileIconImageURL
        self.name = summoner.name
        self.summonerLevel = summoner.summonerLevel
    }
}

struct MasteryInfo: Content {
    /// Number of points needed to achieve next level. Zero if player reached maximum champion level for this champion.
    let championPointsUntilNextLevel: Int64
    /// Is chest granted for this champion or not in current season.
    let chestGranted: Bool
    /// Last time this champion was played by this player - in Unix milliseconds time format.
    /// Champion ID for this entry.
    let championId: ChampionID
    /// Last time this champion was played by this player - in Unix milliseconds time format.
    let lastPlayTime: Date
    /// Champion level for specified player and champion combination.
    let championLevel: Int
    /// Total number of champion points for this player and champion combination - they are used to determine championLevel.
    let championPoints: Int
    /// Number of points earned since current level has been achieved.
    let championPointsSinceLastLevel: Int64
    /// The token earned for this champion at the current championLevel. When the championLevel is advanced the tokensEarned resets to 0.
    let tokensEarned: Int
    
    init(mastery: ChampionMasteryDTO) {
        self.championPointsUntilNextLevel = mastery.championPointsUntilNextLevel
        self.chestGranted = mastery.chestGranted
        self.championId = mastery.championId
        self.lastPlayTime = mastery.lastPlayTime
        self.championLevel = mastery.championLevel
        self.championPoints = mastery.championPoints
        self.championPointsSinceLastLevel = mastery.championPointsSinceLastLevel
        self.tokensEarned = mastery.tokensEarned
    }
}

struct ChampionInfo: Content {
    let id: ChampionID
    let name: String
    let tags: [ChampionClass]
    let imageURL: URL
    let splashImageURL: URL
    
    init(champion: ChampionDTO) {
        self.id = champion.key
        self.name = champion.name
        self.tags = champion.tags
        self.imageURL = champion.imageURL
        self.splashImageURL = champion.splashImageURL
    }
}
