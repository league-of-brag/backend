//
//  ServerRegion.swift
//
//
//  Created by Andreas Hård on 2023-12-27.
//

import Foundation

enum ServerRegion: String, Codable, CaseIterable {
    case brazil = "br1"
    case europeNorthEast = "eun1"
    case europeWest = "euw1"
    case japan = "jp1"
    case korea = "kr"
    case latinAmericaNorth = "la1"
    case latinAmericaSouth = "la2"
    case northAmerica = "na1"
    case oceania = "oc1"
    case philippines = "ph2"
    case russia = "ru"
    case singapore = "sg2"
    case thailand = "th2"
    case turkey = "tr1"
    case taiwan = "tw2"
    case vietnam = "vn2"
    
    var title: String {
        switch self {
        case .brazil:
            return "Brazil"
        case .europeNorthEast:
            return "Europe North East"
        case .europeWest:
            return "Europe West"
        case .japan:
            return "Japan"
        case .korea:
            return "Korea"
        case .latinAmericaNorth:
            return "Latin America North"
        case .latinAmericaSouth:
            return "Latin America South"
        case .northAmerica:
            return "North America"
        case .oceania:
            return "Oceania"
        case .philippines:
            return "Philippines"
        case .russia:
            return "Russia"
        case .singapore:
            return "Singapore"
        case .thailand:
            return "Thailand"
        case .turkey:
            return "Turkey"
        case .taiwan:
            return "Taiwan"
        case .vietnam:
            return "Vietnam"
        }
    }
}
