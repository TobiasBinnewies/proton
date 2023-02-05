//
//  FontStyleCommand.swift
//  Proton
//
//  Created by Tobias Binnewies on 05.02.23.
//  Copyright © 2023 Rajdeep Kwatra. All rights reserved.
//

import Foundation
import UIKit

public class FontStyleCommand: AttributesToggleCommand {
    public init(style: UIFont.TextStyle) {
        super.init(name: CommandName("_Font-\(style.rawValue)-StyleCommand"),
                   attributes: [.font: UIFont.preferredFont(forTextStyle: style)])
    }
}
