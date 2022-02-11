//
//  HomeCollectionViewCell.swift
//  Pokemon List
//
//  Created by Sajjad Zafar on 08/02/2022.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell, ReusableCell {

    //MARK: - Outlets
    @IBOutlet weak var pokemonImageView: UIImageView!
    @IBOutlet weak var pokemonNameLbl: UILabel!
    //MARK: - Properties
    var pokemon: Pokemon? {
        didSet {
            guard let pokemon = pokemon else {
                return
            }
            pokemonNameLbl.text = pokemon.name?.capitalized
            pokemonImageView.image = UIImage(named: "")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.systemBackground
    }
}
