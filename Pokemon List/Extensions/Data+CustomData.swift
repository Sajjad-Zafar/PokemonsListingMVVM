//
//  Data+CustomData.swift
//  Pokemon List
//
//  Created by Sajjad Zafar on 11/02/2022.
//

import Foundation

extension Data {
    func printString() {
        let jsonString = String(data: self, encoding: .utf8)!
        print(jsonString)
    }
}
