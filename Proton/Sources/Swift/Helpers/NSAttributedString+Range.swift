//
//  NSAttributedStringExtensions.swift
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

public extension NSAttributedString {

    /// Full range of this attributed string.
    var fullRange: NSRange {
        return NSRange(location: 0, length: length)
    }

    /// Collection of all the attachments with containing ranges in this attributed string.
    var attachmentRanges: [(attachment: Attachment, range: NSRange)] {
        var ranges = [(Attachment, NSRange)]()

        let fullRange = NSRange(location: 0, length: self.length)
        self.enumerateAttribute(.attachment, in: fullRange) { value, range, _ in
            if let attachment = value as? Attachment {
                ranges.append((attachment, range))
            }
        }
        return ranges
    }

    /// Range of given attachment in this attributed string.
    /// - Parameter attachment: Attachment to find. Nil if given attachment does not exists in this attributed string.
    func rangeFor(attachment: Attachment) -> NSRange? {
        return attachmentRanges.reversed().first(where: { $0.attachment == attachment })?.range
    }

    /// Ranges of `CharacterSet` in this attributed string.
    /// - Parameter characterSet: CharacterSet to search.
    func rangesOf(characterSet: CharacterSet) -> [NSRange] {
        return string.rangesOf(characterSet: characterSet).map { string.makeNSRange(from: $0) }
    }

    /// Attributed substring in reverse direction.
    /// - Parameter range: Range for substring. Substring starts from location in range to number of characters towards beginning per length
    /// specified in range.
    func reverseAttributedSubstring(from range: NSRange) -> NSAttributedString? {
        guard length > 0,
              range.location + range.length < length
        else { return nil }
        
        return attributedSubstring(from: NSRange(location: range.location - range.length, length: range.length))
    }

    /// Gets the next range of attribute starting at the given location in direction based on reverse lookup flag
    /// - Parameters:
    ///   - attribute: Name of the attribute to look up
    ///   - location: Starting location
    ///   - reverseLookup: When true, look up is carried out in reverse direction. Default is false.
    func rangeOf(attribute: NSAttributedString.Key, startingLocation location: Int, reverseLookup: Bool = false) -> NSRange? {
        let range = reverseLookup ? NSRange(location: 0, length: location) : NSRange(location: location, length: length - location)
        let options = reverseLookup ? EnumerationOptions.reverse : []

        var attributeRange: NSRange? = nil
        enumerateAttribute(attribute, in: range, options: options) { val, attrRange, stop in
            if val != nil {
                attributeRange = attrRange
                stop.pointee = true
            }
        }

        return attributeRange
    }

    /// Gets the complete range of attribute at the given location. The attribute is looked up in both forward and
    /// reverse direction and a combined range is returned.  Nil if the attribute does not exist in the given location
    /// - Parameters:
    ///   - attribute: Attribute to search
    ///   - location: Location to inspect
    func rangeOf(attribute: NSAttributedString.Key, at location: Int) -> NSRange? {
        guard location < length,
              self.attribute(attribute, at: location, effectiveRange: nil) != nil
        else { return nil }

        var forwardRange = rangeOf(attribute: attribute, startingLocation: location, reverseLookup: false)
        var reverseRange = rangeOf(attribute: attribute, startingLocation: location, reverseLookup: true)

        if forwardRange?.contains(location) == false {
            forwardRange = nil
        }

        if let r = reverseRange,
           r.endLocation < location {
            reverseRange = nil
        }

        let range: NSRange?
        switch (reverseRange,  forwardRange) {
        case let (.some(r), .some(f)):
            range = NSRange(location: r.location, length: r.length + f.length)
        case let (.none, .some(f)):
            range = f
        case let (.some(r), .none):
            range = r
        default:
            range = nil
        }
        return range
    }

    /// Gets the value of attribute at the given location, if present.
    /// - Parameters:
    ///   - attributeKey: Name of the attribute
    ///   - location: Location to check
    func attributeValue<T>(for attributeKey: NSAttributedString.Key, at location: Int) -> T? {
        guard location < length else { return nil }
        return attribute(attributeKey, at: location, effectiveRange: nil) as? T
    }
    
    /// Alternative to `attributedSubstring(from:_).string`
    /// Avoids allocating `NSAttributedString` and all the attributes for that range, only to ignore the range.
    func substring(from range: NSRange) -> String {
        guard range.upperBound <= length else {
            assertionFailure("Substring is out of bounds")
            return ""
        }
        return (string as NSString).substring(with: range)
    }
    
    /// Gets all Attributes that are present through the whole range
    /// - Parameter range: the range
    /// - Returns: the attributes
    func getActiveAttributes(inRange: NSRange? = nil) -> [Key: Any]? {
        let range = inRange ?? NSRange(location: 0, length: self.length)
        if range.isEmpty || range.location < 0 || self.length < range.endLocation {
            return nil
        }
        var activeAttributes: [Key: Any] = [:]
        var deletedAttributes: [Key] = []
        var idx: Int = 0
//        var isBold = true
//        var isItalic = true
//        var occouringFontStyles: Set<UIFont.TextStyle?> = []
        self.enumerateAttributes(in: range) { currAttributes, _, _ in
            for attr in currAttributes {
                if !deletedAttributes.contains(attr.key) {
                    if idx == 0 {
                        activeAttributes[attr.key] = attr.value
                        continue
                    }
                    if attr.key == .font {
                        let currFont = attr.value as! UIFont
                        let activeFont = activeAttributes[.font]! as! UIFont
                        let intersectingTraits = activeFont.traits.intersection(currFont.traits)
                        let differentTraits = activeFont.traits.symmetricDifference(currFont.traits)
                        
                        
                        if currFont.getStyle() != activeFont.getStyle() || !differentTraits.isEmpty {
                            activeAttributes[.font] = UIFont.systemFont(ofSize: 16).withTraints(traits: intersectingTraits)
                            continue
                        }
                        activeAttributes[.font] = activeFont.withTraints(traits: intersectingTraits)
                        continue
                    }
                    if activeAttributes.keys.contains(attr.key), anyEquals(activeAttributes[attr.key]!, attr.value) {
                        continue
                    }
                    deletedAttributes.append(attr.key)
                    activeAttributes.removeValue(forKey: attr.key)
                }
            }
            activeAttributes.forEach { attr in
                if !currAttributes.keys.contains(attr.key) {
                    deletedAttributes.append(attr.key)
                    activeAttributes.removeValue(forKey: attr.key)
                }
            }
            idx += 1
        }
        return activeAttributes
    }
    
    /// Gets all Traints  that are present in the font through the whole range
    /// - Parameter range: the range
    /// - Returns: the traints
    func getActiveTraits(inRange: NSRange? = nil) -> [UIFontDescriptor.SymbolicTraits]? {
        let range = inRange ?? NSRange(location: 0, length: self.length)
        if range.isEmpty || range.location < 0 || self.length < range.endLocation {
            return nil
        }
        var trains: [UIFontDescriptor.SymbolicTraits: Bool] = {
            var traits: [UIFontDescriptor.SymbolicTraits: Bool] = [:]
            for traint in UIFontDescriptor.SymbolicTraits.allTrains {
                traits[traint] = true
            }
            return traits
        }()
        
        self.enumerateAttributes(in: range) { currAttributes, _, _ in
            guard let font = currAttributes[.font] as? UIFont else { return }
            for traint in UIFontDescriptor.SymbolicTraits.allTrains {
                    if font != font.adding(trait: traint) {
                        trains[traint] = false
                    }
            }
        }
        return trains.filter({ $0.value == true }).map({ $0.key })
    }
}

func anyEquals(_ x : Any, _ y : Any) -> Bool {
    guard x is AnyHashable else {
        return false
        
    }
    guard y is AnyHashable else {
        return false
        
    }
    let isEqual = (x as! AnyHashable) == (y as! AnyHashable)
    return isEqual
}
