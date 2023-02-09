//
//  ListAttribute.swift
//  Proton
//
//  Created by Tobias Binnewies on 06.02.23.
//  Copyright © 2023 Rajdeep Kwatra. All rights reserved.
//

import Foundation
import UIKit

class ListItem: NSObject {
    fileprivate var indentLvl: Int
    fileprivate var symbol: SequenceGenerator
    fileprivate var nextItem: ListItem?
    
    init(indentLvl: Int, symbol: SequenceGenerator) {
        self.indentLvl = indentLvl
        self.symbol = symbol
    }
    
    var mutableCopy: MutableListItem {
        MutableListItem(indentLvl: self.indentLvl, symbol: self.symbol)
    }
    
    var nextListItem: ListItem? {
        nextItem
    }
    
    public var indent: Int {
        indentLvl
    }
    
    public var listSymbol: SequenceGenerator {
        symbol
    }
}

class MutableListItem: ListItem {
    
    func changeIndent(indentMode: Indentation) {
        switch indentMode {
        case .indent:
            indentLvl += 1
        case .outdent:
            indentLvl -= 1
        }
    }
    
    func setSymbol(_ symbol: SequenceGenerator) {
        self.symbol = symbol
    }
    
    func setNextListItem(_ listItem: ListItem?) {
        self.nextItem = listItem
    }
}