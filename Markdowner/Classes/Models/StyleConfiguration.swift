//
//  StyleConfiguration.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/22/18.
//

import Foundation

/// Object used to provide a common look and feel to the markdown text.
open class StylesConfiguration {
    
    /// Base font that will be used to display the markdown content.
    public let baseFont: UIFont
    
    /// Default color for the markdown text.
    public let textColor: UIColor
    
    /// Color that will be used to display the markdown symbols.
    public let symbolsColor: UIColor
    
    public init(baseFont: UIFont, textColor: UIColor, symbolsColor: UIColor) {
        self.baseFont = baseFont
        self.textColor = textColor
        self.symbolsColor = symbolsColor
    }
}
