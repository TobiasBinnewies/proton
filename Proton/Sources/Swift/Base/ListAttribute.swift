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
    private var indentLvl: Int
    private var symbol: SequenceGenerator
    
    init(indentLvl: Int, symbol: SequenceGenerator) {
        self.indentLvl = indentLvl
        self.symbol = symbol
    }
    
    public var indent: Int {
        indentLvl
    }
    
    public var listSymbol: SequenceGenerator {
        symbol
    }
    
    func changeIndent(indentMode: Indentation) {
        switch indentMode {
        case .indent:
            indentLvl += 1
        case .outdent:
            indentLvl -= 1
        }
    }
}
