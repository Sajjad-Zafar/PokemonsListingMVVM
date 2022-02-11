//
//  PokemonListViewModel.swift
//  Pokemon List
//
//  Created by Sajjad Zafar on 08/02/2022.
//

import Foundation
import Combine

final class PokemonListViewModel {
    
    var apiService: APIService
    var dataSource: [Pokemon]?
    var model: PokemonModel?
    var selectedPokemons: Set<Pokemon>?
    @Published var isFetchInProgress = false
    
    var pokemonCount: Int {
        return self.dataSource?.count ?? 0
    }
    
    var totalCount: Int {
        return model?.count ?? 0
    }
    
    init(service: APIService) {
        self.apiService = service
        selectedPokemons = []
        dataSource = []
    }
    
    func updateDataSource(list: PokemonModel?) {
        guard let list = list, let results = list.results else {
            return
        }
        self.dataSource?.append(contentsOf: results)
        self.model = list
        _ = PokemonCacheManager.shared.getAllFavourites().map({ self.selectedPokemons?.insert($0) })
    }
    
    func appendDataSource(list: PokemonModel?) {
        guard let list = list else {
            return
        }
        self.dataSource?.append(contentsOf: list.results ?? [])
    }
    
    func fetchPokemons() {
        guard !isFetchInProgress else {
            return
        }
        self.isFetchInProgress = true
        let cancellable = self.getPokemonsList().sink(receiveCompletion: { result in
            self.isFetchInProgress = false
            switch result {
                case .finished:
                    break
                case .failure(let error):
                    self.apiService.decodeErrors(error)
            }
        }, receiveValue: { model in
            self.updateDataSource(list: model)
            self.isFetchInProgress = false
        })
        self.apiService.cancellables.insert(cancellable)
    }
    
    private func getPokemonsList() -> AnyPublisher<PokemonModel, NetworkingError> {
        if self.dataSource?.count ?? 0 <= self.totalCount {
            let url = (self.dataSource != nil && self.model?.next != nil) ? self.model?.next : "\(BASE_URL)\(GET_POKEMONS_LIST_URL)"
            let completeURL = "\(String(describing: url ?? ""))"
            return apiService.get(completeURL, query: nil, headers: nil, body: nil)
        }
        return Fail(error: NetworkingError(httpStatusCode: NetworkingError.Status.wrongURL.rawValue)).eraseToAnyPublisher()
    }
    
    func pokemon(at indexPath:IndexPath) -> Pokemon? {
        return self.dataSource?[indexPath.row]
    }
    
    func getSelectedPokemon(pokemon: Pokemon?) -> Bool {
        guard let pokemon = pokemon else {
            return false
        }
        return self.selectedPokemons?.filter({ $0 == pokemon }).count ?? 0 > 0
    }
    
    func toggleSelection(pokemon: Pokemon?, status: Bool) {
        guard let pokemon = pokemon else {
            return
        }
        if status {
            self.selectedPokemons?.insert(pokemon)
        } else {
            if let index = self.selectedPokemons?.firstIndex(where: { $0 == pokemon }) {
                self.selectedPokemons?.remove(at: index)
            }
        }
    }
    
    func getSelectedProducts() -> Set<Pokemon>? {
        return self.selectedPokemons
    }
}
