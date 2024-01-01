//
//  ChampionClass.swift
//
//
//  Created by Andreas Hård on 2024-01-01.
//

import Foundation

enum ChampionClass: String, Codable, CaseIterable {
    case assassin = "Assassin"
    case support = "Support"
    case fighter = "Fighter"
    case mage = "Mage"
    case marksman = "Marksman"
    case tank = "Tank"
}
