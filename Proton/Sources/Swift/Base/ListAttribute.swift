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
    var indentLvl: Int
    var symbols: [SequenceGenerator]
    var nextItem: ListItem?
    
    init(indentLvl: Int, symbols: [SequenceGenerator], nextItem: ListItem? = nil) {
        self.indentLvl = indentLvl
        self.symbols = symbols
        self.nextItem = nextItem
    }
    
    var symbol: SequenceGenerator {
        symbols[indentLvl % symbols.count]
    }
    
    func changeIndent(indentMode: Indentation) {
        switch indentMode {
        case .indent:
            indentLvl += 1
        case .outdent:
            indentLvl -= 1
        }
    }
    
    func deepCopy() -> ListItem {
        ListItem(indentLvl: self.indentLvl, symbols: self.symbols, nextItem: self.nextItem)
    }
    
//    var mutableCopy: MutableListItem {
//        MutableListItem(indentLvl: self.indentLvl, symbol: self.symbol)
//    }
//
//    var nextListItem: ListItem? {
//        nextItem
//    }
//
//    public var indent: Int {
//        indentLvl
//    }
//
//    public var listSymbol: SequenceGenerator {
//        symbol
//    }
}

//class MutableListItem: ListItem {
//
//    func changeIndent(indentMode: Indentation) {
//        switch indentMode {
//        case .indent:
//            indentLvl += 1
//        case .outdent:
//            indentLvl -= 1
//        }
//    }
//
//    func setSymbol(_ symbol: SequenceGenerator) {
//        self.symbol = symbol
//    }
//
//    func setNextListItem(_ listItem: ListItem?) {
//        self.nextItem = listItem
//    }
//}
