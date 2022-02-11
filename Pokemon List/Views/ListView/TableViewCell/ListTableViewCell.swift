//
//  ListTableViewCell.swift
//  Pokemon List
//
//  Created by Sajjad Zafar on 09/02/2022.
//

import UIKit

class ListTableViewCell: UITableViewCell, ReusableCell {

    //MARK: - Outlets
    @IBOutlet weak var pokemonImageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subtitleLbl: UILabel!
    @IBOutlet weak var selectionBtn: UIButton!
    @IBOutlet weak var checkboxBtn: UIButton!
    
    var checkboxBtnAction: ((Any) -> Void)?
    var editBtnAction: ((Any) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            selectionBtn.setImage(UIImage(named:Constants.Assets.checkboxActive), for: .normal)
        } else {
            selectionBtn.setImage(UIImage(named:Constants.Assets.checkbox), for: .normal)
        }
    }
    
    func configure(with pokemon: Pokemon?, indexPath: IndexPath) {
        guard let pokemon = pokemon else {
            return
        }
        titleLbl.text = pokemon.name?.capitalized
        subtitleLbl.text = "\(String(describing: indexPath.row))"
        checkboxBtn.tag = indexPath.row
    }
    
    @IBAction func checkboxDidToggle(_ sender: Any) {
        self.checkboxBtnAction?(sender)
    }
    
}
