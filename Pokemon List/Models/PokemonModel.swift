//
//  PokemonModel.swift
//  Pokemon List
//
//  Created by Sajjad Zafar on 08/02/2022.
//

import Foundation

// MARK: - PokemonModel
struct PokemonModel: Codable {
    let count: Int?
    var next: String?
    var previous: String?
    var results: [Pokemon]?
}

// MARK: - Pokemon
struct Pokemon: Codable, Equatable, Hashable {
    let name: String?
    let url: String?
    var identifier: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case url
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        identifier = "\(String(describing: name))\(String(describing: url))"
    }
}
