//
//  SequenceGenerator.swift
//  Proton
//
//  Created by Rajdeep Kwatra on 27/5/20.
//  Copyright © 2020 Rajdeep Kwatra. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import UIKit

extension Int {
    var lowerLetter: String {
        if self < 1 {
            return "NIL"
        }
        if self == 1 {
            return "a"
        }
        if self > 702 {
            return ">zz"
        }
        let uniCodeA = UnicodeScalar("a")
//        let letterCnt: Int = (self-1) / 26

        var result: Int = self-1
        var remainders: [Int] = []
        while result != 0 {
            if remainders.count > 0 && result / 27 == 0 {
                remainders.append(result % 27)
                break
            }
            remainders.append(result % 26)
            result = result / 26
        }
        if remainders.count == 1 {
            return String(UnicodeScalar(uniCodeA.value + UInt32(remainders[0]))!)
        }
        var lowerLetter: String = String(UnicodeScalar(uniCodeA.value + UInt32(remainders.popLast()!) - UInt32(1))!)
        for remainder in remainders.reversed() {
            lowerLetter.append(String(UnicodeScalar(uniCodeA.value + UInt32(remainder))!))
        }
        return lowerLetter
    }
    
    var upperLetter: String {
        if self < 1 {
            return "NIL"
        }
        if self == 1 {
            return "A"
        }
        if self > 702 {
            return ">ZZ"
        }
        let uniCodeA = UnicodeScalar("A")

        var result: Int = self-1
        var remainders: [Int] = []
        while result != 0 {
            if remainders.count > 0 && result / 27 == 0 {
                remainders.append(result % 27)
                break
            }
            remainders.append(result % 26)
            result = result / 26
        }
        if remainders.count == 1 {
            return String(UnicodeScalar(uniCodeA.value + UInt32(remainders[0]))!)
        }
        var upperLetter: String = String(UnicodeScalar(uniCodeA.value + UInt32(remainders.popLast()!) - UInt32(1))!)
        for remainder in remainders.reversed() {
            upperLetter.append(String(UnicodeScalar(uniCodeA.value + UInt32(remainder))!))
        }
        return upperLetter
    }
    
    var upperRomanNumeral: String {
        if self < 1 {
            return "NIL"
        }
        if self > 3999 {
            return ">MMMCMXCIX"
        }
        var integerValue = self
        var numeralString = ""
        let mappingList: [(Int, String)] = [(1000, "M"), (900, "CM"), (500, "D"), (400, "CD"), (100, "C"), (90, "XC"), (50, "L"), (40, "XL"), (10, "X"), (9, "IX"), (5, "V"), (4, "IV"), (1, "I")]
        for i in mappingList {
            while (integerValue >= i.0) {
                integerValue -= i.0
                numeralString += i.1
            }
        }
        return numeralString
    }
    
    var lowerRomanNumeral: String {
        if self < 1 {
            return "NIL"
        }
        if self > 3999 {
            return ">mmmcmxcix"
        }
        var integerValue = self
        var numeralString = ""
        let mappingList: [(Int, String)] = [(1000, "m"), (900, "cm"), (500, "d"), (400, "cd"), (100, "c"), (90, "xc"), (50, "l"), (40, "xl"), (10, "x"), (9, "ix"), (5, "v"), (4, "iv"), (1, "i")]
        for i in mappingList {
            while (integerValue >= i.0) {
                integerValue -= i.0
                numeralString += i.1
            }
        }
        return numeralString
    }
}

/// Represents a Sequence generator that can return a value based on given index.
/// Besides other possible uses, this is used in Lists for generation of bullets/numbering.
public protocol SequenceGenerator {
    /// Returns a value representing the given index.
    /// - Parameter index: Index for which the value is being fetched.
    func value(at index: Int) -> ListLineMarker
}

/// Simple numeric sequence generator.
public struct NumericSequenceGenerator: SequenceGenerator {
    let withBraces: Bool
    public init(withBraces: Bool = false) {
        self.withBraces = withBraces
    }
    public func value(at index: Int) -> ListLineMarker {
        let font = UIFont.preferredFont(forTextStyle: .body)
        let text = "\(withBraces ? "(" : "")\((index + 1))\(withBraces ? ")" : ".")"
        return .string(NSAttributedString(string: text, attributes: [.font: font]))
    }
}

public struct UpperLetterSequenceGenerator: SequenceGenerator {
    let count: Int
    let withBraces: Bool
    public init(count: Int = 1, withBraces: Bool = false) {
        self.count = count
        self.withBraces = withBraces
    }
    public func value(at index: Int) -> ListLineMarker {
        let font = UIFont.preferredFont(forTextStyle: .body)
        var marker = ""
        for _ in 0..<count {
            marker.append("\((index + 1).upperLetter)")
        }
        let text = "\(withBraces ? "(" : "")\(marker)\(withBraces ? ")" : ".")"
        return .string(NSAttributedString(string: text, attributes: [.font: font]))
    }
}

public struct LowerLetterSequenceGenerator: SequenceGenerator {
    var count: Int
    let withBraces: Bool
    public init(count: Int = 1, withBraces: Bool = false) {
        self.count = count
        self.withBraces = withBraces
    }
    public func value(at index: Int) -> ListLineMarker {
        let font = UIFont.preferredFont(forTextStyle: .body)
        var marker = ""
        for _ in 0..<count {
            marker.append("\((index + 1).lowerLetter)")
        }
        let text = "\(withBraces ? "(" : "")\(marker)\(withBraces ? ")" : ".")"
        return .string(NSAttributedString(string: text, attributes: [.font: font]))
    }
}

public struct UpperRomanSequenceGenerator: SequenceGenerator {
    let withBraces: Bool
    public init(withBraces: Bool = false) {
        self.withBraces = withBraces
    }
    public func value(at index: Int) -> ListLineMarker {
        let font = UIFont.preferredFont(forTextStyle: .body)
        let text = "\(withBraces ? "(" : "")\((index + 1).upperRomanNumeral)\(withBraces ? ")" : ".")"
        return .string(NSAttributedString(string: text, attributes: [.font: font]))
    }
}

public struct LowerRomanSequenceGenerator: SequenceGenerator {
    let withBraces: Bool
    public init(withBraces: Bool = false) {
        self.withBraces = withBraces
    }
    public func value(at index: Int) -> ListLineMarker {
        let font = UIFont.preferredFont(forTextStyle: .body)
        let text = "\(withBraces ? "(" : "")\((index + 1).lowerRomanNumeral)\(withBraces ? ")" : ".")"
        return .string(NSAttributedString(string: text, attributes: [.font: font]))
    }
}

/// Simple bullet sequence generator that returns a diamond symbol.
public struct DiamondBulletSequenceGenerator: SequenceGenerator {
    public init() { }
    public func value(at index: Int) -> ListLineMarker {
        let font = UIFont.preferredFont(forTextStyle: .body)
        let text = "◈"
        return .string(NSAttributedString(string: text, attributes: [.font: font]))
    }
}

/// Simple bullet sequence generator that returns a square symbol.
public struct SquareBulletSequenceGenerator: SequenceGenerator {
    public init() { }
    public func value(at index: Int) -> ListLineMarker {
        let font = UIFont.preferredFont(forTextStyle: .body)
        let text = "▣"
        return .string(NSAttributedString(string: text, attributes: [.font: font]))
    }
}

public struct DotBulletSequenceGenerator: SequenceGenerator {
    public init() { }
    public func value(at index: Int) -> ListLineMarker {
        let font = UIFont.preferredFont(forTextStyle: .body)
        let text = "◉"
        return .string(NSAttributedString(string: text, attributes: [.font: font]))
    }
}

//TODO: Erweitern!!
