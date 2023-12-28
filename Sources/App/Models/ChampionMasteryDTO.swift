//
//  ChampionMasteryDto.swift
//
//
//  Created by Andreas Hård on 2023-12-27.
//

import Foundation
import Vapor

struct ChampionMasteryDTO: Content {
    /// Player Universal Unique Identifier. Exact length of 78 characters. (Encrypted)
    let puuid: String
    /// Number of points needed to achieve next level. Zero if player reached maximum champion level for this champion.
    let championPointsUntilNextLevel: Int64
    /// Is chest granted for this champion or not in current season.
    let chestGranted: Bool
    /// Champion ID for this entry.
    let championId: Int64
    /// Last time this champion was played by this player - in Unix milliseconds time format.
    let lastPlayTime: Int64
    /// Champion level for specified player and champion combination.
    let championLevel: Int
    /// Summoner ID for this entry. (Encrypted)
    let summonerId: String
    /// Total number of champion points for this player and champion combination - they are used to determine championLevel.
    let championPoints: Int
    /// Number of points earned since current level has been achieved.
    let championPointsSinceLastLevel: Int64
    /// The token earned for this champion at the current championLevel. When the championLevel is advanced the tokensEarned resets to 0.
    let tokensEarned: Int
}
