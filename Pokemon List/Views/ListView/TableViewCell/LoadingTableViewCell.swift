//
//  LoadingTableViewCell.swift
//  Pokemon List
//
//  Created by Sajjad Zafar on 11/02/2022.
//

import UIKit

class LoadingTableViewCell: UITableViewCell, ReusableCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
        activityIndicator.color = UIColor.black
    }
}
