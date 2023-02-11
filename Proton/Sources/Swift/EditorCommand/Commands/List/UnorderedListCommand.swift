//
//  UnorderedListCommand.swift
//  Proton
//
//  Created by Tobias Binnewies on 05.02.23.
//  Copyright © 2023 Rajdeep Kwatra. All rights reserved.
//

import Foundation

public class UnorderedListCommand: ListCommand {
    
    /// Name of the command
    public override var name: CommandName {
        return CommandName("unorderedListCommand")
    }
    
    public override func execute(on editor: EditorView) {
        // remove list if existing
        if let line = editor.currentContentLine(from: editor.selectedRange.location), line.range.length > 0, line.text.attribute(.listItem, at: 0, effectiveRange: nil) != nil {
            self.attributeValue = nil
        } else {
            self.attributeValue = ListItem(indentLvl: 1, symbols: [SquareBulletSequenceGenerator()])
        }
        // create / remove list
        super.execute(on: editor)
    }
}
