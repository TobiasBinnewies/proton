//
//  NSRangeExtensions.swift
//  Proton
//
//  Created by Rajdeep Kwatra on 3/1/20.
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

public extension NSRange {
    
    init(location: Int, endLocation: Int) {
        self.init(location: location, length: endLocation-location)
    }

    /// Range with 0 location and length
    static var zero: NSRange {
        return NSRange(location: 0, length: 0)
    }

    var firstCharacterRange: NSRange {
        return NSRange(location: location, length: 1)
    }

    var lastCharacterRange: NSRange {
        return NSRange(location: location + length, length: 1)
    }

    var nextPosition: NSRange {
        return NSRange(location: location + 1, length: 0)
    }

    var endLocation: Int {
        return location + length
    }
    
    var isEmpty: Bool {
        return self.upperBound == self.lowerBound
    }

    /// Converts the range to `UITextRange` in given `UITextInput`. Returns nil if the range is invalid in the `UITextInput`.
    /// - Parameter textInput: UITextInput to convert the range in.
    func toTextRange(textInput: UITextInput) -> UITextRange? {
        guard let rangeStart = textInput.position(from: textInput.beginningOfDocument, offset: location),
              let rangeEnd = textInput.position(from: rangeStart, offset: length)
        else { return nil }
        
        return textInput.textRange(from: rangeStart, to: rangeEnd)
    }

    /// Checks if the range is valid in given `UITextInput`
    /// - Parameter textInput: UITextInput to validate the range in.
    func isValidIn(_ textInput: UITextInput) -> Bool {
        guard location > 0 else { return false }
        let end = location + length
        let contentLength = textInput.offset(from: textInput.beginningOfDocument, to: textInput.endOfDocument)
        return end < contentLength
    }

    /// Shifts the range with given shift value
    /// - Parameter shift: Int value to shift range by.
    /// - Returns: Shifted range with same length.
    /// - Important: The shifted range may or may not be valid in a given string. Validity of shifted range must always be checked at the usage site.
    func shiftedBy(_ shift: Int) -> NSRange {
        return NSRange(location: self.location + shift, length: length)
    }
    
    /// Returns all ranges not included in the given ranges within the current range
    func oppositeRanges(ranges: [NSRange]) -> [NSRange] {
        guard ranges.count > 0 else { return [self] }
        var oppositeRanges = [NSRange]()
        let sortedRanges = ranges.sorted(by: { $0.location < $1.location })
        var currentLocation = sortedRanges[0].location
        let firstOppRange = NSRange(location: self.location, endLocation: currentLocation)
        if firstOppRange.length > 0 {
            oppositeRanges.append(firstOppRange)
        }
        for range in sortedRanges {
            if currentLocation < range.location {
                let rangeToAppend = NSRange(location: min(currentLocation, self.endLocation), endLocation: min(range.location, self.endLocation))
                if rangeToAppend.length == 0 {
                    break
                }
                oppositeRanges.append(rangeToAppend)
            }
            currentLocation = range.endLocation
        }
        let newLastOppRange = NSRange(location: currentLocation, endLocation: self.endLocation)
        if newLastOppRange.length > 0 {
            oppositeRanges.append(newLastOppRange)
        }
        return oppositeRanges
    }
}
