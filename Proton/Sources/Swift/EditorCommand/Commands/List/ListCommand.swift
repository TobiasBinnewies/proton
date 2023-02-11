//
//  ListCommand.swift
//  Proton
//
//  Created by Rajdeep Kwatra on 28/5/20.
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

enum Indentation {
    case indent
    case outdent
}

/// Describes the formatting of a line of text. While general purpose in nature, this is
/// used by `EditorListFormattingProvider` for providing formatting for lists.
public struct LineFormatting {

    /// Indentation of line
    public let indentation: CGFloat

    /// Vertical spacing before the line
    public let spacingBefore: CGFloat

    /// Initializes
    /// - Parameters:
    ///   - indentation: Indentation for each line of text
    ///   - spacingBefore: Vertical spacing before line of text
    public init(indentation: CGFloat, spacingBefore: CGFloat) {
        self.indentation = indentation
        self.spacingBefore = spacingBefore
    }
}

/// Command that can be used to toggle list attributes of selected range of text.
/// If the length of selected range of text is 0, the attributes are applied on the current line of text.
public class ListCommand: EditorCommand {
    public init() { }

    /// Name of the command
    public var name: CommandName {
        return CommandName("listCommand")
    }

    /// Value to be set for attribute `.listItem` when applying to a range of text.
    /// This value is returned back by `ListFormattingProvider` when querying list marker for a given index.
    /// This may be used to store info that helps generate appropriate markers for e.g. storing context related
    /// to bullet vs ordered lists.
    /// - Note:
    /// When set to nil before running `execute`, it removes list formatting from the selected range of text.
    var attributeValue: ListItem?
    
    public func execute(on editor: EditorView, symbols: [SequenceGenerator]) {
        // remove list if existing
        if let line = editor.currentContentLine(from: editor.selectedRange.location), line.range.length > 0, line.text.attribute(.listItem, at: 0, effectiveRange: nil) != nil {
            self.attributeValue = nil
        } else {
            self.attributeValue = ListItem(indentLvl: 1, symbols: symbols)
        }
        // create / remove list
        execute(on: editor)
    }

    /// Executes the command with value of `attributeValue` for `.listItem` attribute. If the `attributeValue` is nil, executing
    /// removed list formatting from the selected range of text.
    /// - Parameter editor: Editor to execute the command on.
    func execute(on editor: EditorView) {
        var selectedRange = editor.selectedRange.fitInRange(editor.contentLength)
        // Adjust to span entire line range if the selection starts in the middle of the line
        if let currentLine = editor.currentContentLine(from: selectedRange.location),
           currentLine.range.length > 0 {
            let location = currentLine.range.location
            var length = max(currentLine.range.length, selectedRange.length + (selectedRange.location - currentLine.range.location))
            let range = NSRange(location: location, length: length)
            if editor.contentLength > range.endLocation,
               editor.attributedText.substring(from: NSRange(location: range.endLocation, length: 1)) == "\n" {
                length += 1
            }
            selectedRange = NSRange(location: location, length: length)
        }
        
        ListTextProcessor().createListItem(editor: editor, editedRange: selectedRange, attributeValue: attributeValue)
        
        editor.setSelection()
//        return

//        guard selectedRange.length > 0 else {
//            ListTextProcessor().createListItem(editor: editor, editedRange: selectedRange, attributeValue: attributeValue)
//            return
//        }
//
//        guard let attrValue = attributeValue else {
////            let paragraphStyle = editor.paragraphStyle
////            editor.addAttributes([
////                .paragraphStyle: paragraphStyle
////            ], at: selectedRange)
//            editor.removeAttribute(.listItem, at: selectedRange)
//            let blankCharPositions = editor.attributedText.substring(from: selectedRange)[Character.blankLineFiller]
//            for pos in blankCharPositions {
//                let charLocation = selectedRange.location + pos
//                editor.replaceCharacters(in: NSRange(location: charLocation, length: 1), with: "")
//            }
//            return
//        }
//
//        // Fix the list attribute on the trailing `\n` in previous line, if previous line has a listItem attribute applied
//        if let previousLine = editor.previousContentLine(from: selectedRange.location),
//           // TODO: May produce error if previous line length = 0
//           let listValue = editor.attributedText.attribute(.listItem, at: previousLine.range.endLocation - 1, effectiveRange: nil),
//           editor.attributedText.attribute(.listItem, at: previousLine.range.endLocation, effectiveRange: nil) == nil {
//            editor.addAttribute(.listItem, value: listValue, at: NSRange(location: previousLine.range.endLocation, length: 1))
//        }
//
////        editor.attributedText.enumerateAttribute(.paragraphStyle, in: selectedRange, options: []) { (value, range, _) in
////            let paraStyle = value as? NSParagraphStyle
////            let mutableStyle = ListTextProcessor().updatedParagraphStyle(paraStyle: paraStyle, listLineFormatting: editor.listLineFormatting, indentMode: .indent)
////            editor.addAttribute(.paragraphStyle, value: mutableStyle ?? editor.paragraphStyle, at: range)
////        }
//        editor.addAttribute(.listItem, value: attrValue, at: selectedRange)
//        attributeValue = nil
    }
}
