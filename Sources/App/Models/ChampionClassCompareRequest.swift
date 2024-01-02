//
//  ChampionClassCompareRequest.swift
//
//
//  Created by Andreas Hård on 2024-01-01.
//

import Foundation
import LOLAPIClient

struct ChampionClassCompareRequest: Codable {
    let serverRegion: ServerRegion
    let championClass: ChampionClass
    let summonerNames: [String]
}
