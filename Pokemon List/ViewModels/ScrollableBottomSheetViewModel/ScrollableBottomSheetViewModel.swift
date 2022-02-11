//
//  ScrollableBottomSheetViewModel.swift
//  Pokemon List
//
//  Created by Sajjad Zafar on 08/02/2022.
//

import UIKit

struct ScrollableBottomSheetViewModel {
    
    var dataSource: [Pokemon] = []
    var isSearching: Bool = false
    let fullView: CGFloat = 100
    var partialView: CGFloat {
        return UIScreen.main.bounds.height - 450
    }

    
    func getNumberOfRows() -> Int {
        return self.dataSource.count
    }
    
    func pokemon(at indexPath:IndexPath) -> Pokemon {
        return self.dataSource[indexPath.row]
    }
    
    mutating func getAllFavouritePokemons() {
        self.dataSource = PokemonCacheManager.shared.getAllFavourites()
    }
}
