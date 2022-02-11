//
//  PokemonCacheManager.swift
//  Pokemon List
//
//  Created by Sajjad Zafar on 09/02/2022.
//

import Foundation

class PokemonCacheManager : NSObject{
    static let shared = PokemonCacheManager()
    static let favuoriteKey = "favuoriteKey"
    
    func makeFavourites(products: Set<Pokemon>) {
//        var array = self.getAllFavourites()
        
//        if !array.contains(where: { $0.identifier == product.identifier }) {
//            array.append(product)
//        }
//
//        array.append(contentsOf: products)
        let jsonData = try? JSONEncoder().encode(products)
        UserDefaults.standard.setValue(jsonData, forKey: PokemonCacheManager.favuoriteKey)
    }
    
    func getAllFavourites() -> [Pokemon] {
        if let jsonData = UserDefaults.standard.value(forKey: PokemonCacheManager.favuoriteKey) as? Data {
            let array = try? JSONDecoder().decode([Pokemon].self, from: jsonData)
            return array ?? []
        }
        return []
    }
    
    func isFavourite(product:Pokemon) -> Bool {
        let array = self.getAllFavourites()
        return array.contains(where: { $0.identifier == product.identifier })
    }
    
    func removeAsFavourite(product: Pokemon) {
        var array = self.getAllFavourites()
        
        array.removeAll(where: { $0.identifier == product.identifier })
        
        let jsonData = try? JSONEncoder().encode(array)
        UserDefaults.standard.setValue(jsonData, forKey: PokemonCacheManager.favuoriteKey)
    }
}
