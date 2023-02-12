//
//  ListAttribute.swift
//  Proton
//
//  Created by Tobias Binnewies on 06.02.23.
//  Copyright © 2023 Rajdeep Kwatra. All rights reserved.
//

import Foundation
import UIKit

public class ListItem: NSObject, NSSecureCoding {
    public static var supportsSecureCoding: Bool = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(indentLvl, forKey: Key.indentLvl.rawValue)
        coder.encode(nextItem, forKey: Key.nextItem.rawValue)
        coder.encode(symbols, forKey: Key.symbols.rawValue)
    }
    
    enum Key: String {
        case symbols = "symbols"
        case indentLvl = "indentLvl"
        case nextItem = "nextItem"
    }
    
    required convenience public init?(coder: NSCoder) {
        let indentLvl = coder.decodeInteger(forKey: Key.indentLvl.rawValue)
        let nextItem = coder.decodeObject(of: ListItem.self, forKey: Key.nextItem.rawValue)
        let symbols = coder.decodeObject(of: [NSArray.self, SequenceGenerator.self], forKey: Key.symbols.rawValue) as! [SequenceGenerator]
        
        self.init(indentLvl: indentLvl, symbols: symbols, nextItem: nextItem)

    }
    
    var indentLvl: Int
    var symbols: [SequenceGenerator]
    var nextItem: ListItem?
    
    init(indentLvl: Int, symbols: [SequenceGenerator], nextItem: ListItem? = nil) {
        self.indentLvl = indentLvl
        self.symbols = symbols
        self.nextItem = nextItem
    }
    
    var symbol: SequenceGenerator {
        symbols[((indentLvl-1) % symbols.count)]
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
