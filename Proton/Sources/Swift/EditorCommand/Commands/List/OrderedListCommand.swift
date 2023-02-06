//
//  OrderedListCommand.swift
//  Proton
//
//  Created by Tobias Binnewies on 05.02.23.
//  Copyright © 2023 Rajdeep Kwatra. All rights reserved.
//

import Foundation

public class OrderedListCommand: ListCommand {
    
    /// Name of the command
    public override var name: CommandName {
        return CommandName("orderedListCommand")
    }
    
    public override func execute(on editor: EditorView) {
        // remove list if existing
        if editor.contentLength > 0,
           editor.attributedText.attribute(.listItem, at: min(editor.contentLength - 1, editor.selectedRange.location), effectiveRange: nil) != nil {
            self.attributeValue = nil
        } else {
            self.attributeValue = "listItemValue"
        }
        // create / remove list
        super.execute(on: editor)
    }
}