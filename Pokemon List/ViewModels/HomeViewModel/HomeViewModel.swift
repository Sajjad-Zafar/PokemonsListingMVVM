//
//  HomeViewModel.swift
//  Pokemon List
//
//  Created by Sajjad Zafar on 08/02/2022.
//

import Foundation

class HomeViewModel: NSObject {
    
    var dataSource: [Pokemon]!
    
    func getAllFavouritePokemons() {
        self.dataSource = PokemonCacheManager.shared.getAllFavourites()
    }
}
