//
//  UIFont+CustomFont.swift
//  Pokemon List
//
//  Created by Sajjad Zafar on 08/02/2022.
//

import UIKit

struct AppFontName {
    static let light = "Montserrat-Medium"
    static let regular = "Montserrat-Light"
    static let medium = "Montserrat-Regular"
}

extension UIFont {
    static func lightSystemFont(ofSize size: CGFloat) -> UIFont {
        guard let lightFont = UIFont(name: AppFontName.light, size: size) else {
            return UIFont.systemFont(ofSize: size, weight: .light)
        }
        return lightFont
    }
    
    static func regularSystemFont(ofSize size: CGFloat) -> UIFont {
        guard let font = UIFont(name: AppFontName.regular, size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
    
    static func mediumSystemFont(ofSize size: CGFloat) -> UIFont {
        guard let mediumFont = UIFont(name: AppFontName.medium, size: size) else {
            return UIFont.systemFont(ofSize: size, weight: .medium)
        }
        return mediumFont
    }
}
