//
//  ChampionCompareRequest.swift
//
//
//  Created by Andreas Hård on 2024-01-01.
//

import Foundation

struct ChampionCompareRequest: Codable {
    let serverRegion: ServerRegion
    let championId: ChampionID
    let summonerNames: [String]
}
