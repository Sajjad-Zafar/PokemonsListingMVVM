//
//  ReusableCell.swift
//  Pokemon List
//
//  Created by Sajjad Zafar on 08/02/2022.
//

import UIKit

protocol ReusableCell {
    static var reuseIdentifier: String { get }
    static var nib: UINib { get }
}

extension ReusableCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
}
