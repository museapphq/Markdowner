//
//  MarkdownTextStorage.swift
//  Markdowner
//
//  Created by Reynaldo Aguilar on 7/21/18.
//

import Foundation

/// Custom `NSTextStorage` subclass that will render text as markdown.
public class MarkdownTextStorage: NSTextStorage {
    public var stylesConfiguration: StylesConfiguration {
        didSet {
            self.refreshContent()
        }
    }
    
    private var markdownParser: MarkdownParser
    
    private let backingString = NSMutableAttributedString()
    
    private var defaultAttributes: [NSAttributedStringKey: Any] {
        let baseFont = stylesConfiguration.baseFont
        let font = stylesConfiguration.useDynamicType ? baseFont.dynamic() : baseFont
        
        return [
            .font: font,
            .foregroundColor: stylesConfiguration.textColor
        ]
    }
    
    private var defaultElements: [MarkdownElement] {
        let boldElement = BoldElement(symbolsColor: stylesConfiguration.symbolsColor)
        let italicElement = ItalicElement(symbolsColor: stylesConfiguration.symbolsColor)
        let strikeElement = StrikethroughElement(symbolsColor: stylesConfiguration.symbolsColor)
        
        guard let monospaceFont = UIFont(name: "Menlo-Regular", size: stylesConfiguration.baseFont.pointSize) else {
            fatalError()
        }
        
        let inlineCodeElement = InlineCodeElement(
            symbolsColor: stylesConfiguration.symbolsColor,
            font: monospaceFont,
            useDynamicType: stylesConfiguration.useDynamicType
        )
        
        let linkElement = LinkElement(
            symbolsColor: stylesConfiguration.symbolsColor,
            font: stylesConfiguration.baseFont,
            linksColor: UIColor.lightGray
        )
        
        let bulletElement = BulletElement(
            symbolsColor: stylesConfiguration.symbolsColor,
            textColor: stylesConfiguration.textColor,
            font: stylesConfiguration.baseFont,
            useDynamicType: stylesConfiguration.useDynamicType
        )

        return [boldElement, italicElement, strikeElement, inlineCodeElement,
                linkElement, bulletElement]
    }
    
    public override init() {
        self.stylesConfiguration = StylesConfiguration(
            baseFont: UIFont.systemFont(ofSize: 14),
            textColor: .black,
            symbolsColor: .blue,
            useDynamicType: true
        )
        
        markdownParser = MarkdownParser(markdownElements: [])

        super.init()
        
        self.use(elements: defaultElements)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Indicates to the storage the set of markdown elements that will be used to process the text.
    ///
    /// - Parameter elements: Markdown elements to use (they can be custom elements or the default ones).
    public func use(elements: [MarkdownElement]) {
        self.markdownParser = MarkdownParser(markdownElements: elements)
        self.refreshContent()
    }
    
    /// Retrieves an attributted string containing a preview of the content inside this storage.
    ///
    /// - Parameter removingMarkdownSymbols: If equal to `true`, markdown symbols will be removed
    ///   from the resultant preview.
    /// - Returns: Preview of the markdown content in the storage.
    public func attributedString(removingMarkdownSymbols: Bool = true) -> NSAttributedString {
        guard removingMarkdownSymbols else { return self }
        
        let rangesToRemove = markdownParser.replacementRanges(forString: string as NSString)
        
        let originalString = NSMutableAttributedString(attributedString: self)
        
        for replacementRange in rangesToRemove.reversed() {
            originalString.replaceCharacters(
                in: replacementRange.range,
                with: replacementRange.replacementValue
            )
        }
        
        return originalString
    }
    
    // MARK: NSTextStorage subclass
    
    override public var string: String {
        return backingString.string
    }
    
    override public func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedStringKey : Any] {
        return backingString.attributes(at: location, effectiveRange: range)
    }
    
    override public func replaceCharacters(in range: NSRange, with str: String) {
        backingString.replaceCharacters(in: range, with: str)
        
        self.edited(.editedCharacters, range: range, changeInLength: str.utf16.count - range.length)
    }
    
    override public func setAttributes(_ attrs: [NSAttributedStringKey : Any]?, range: NSRange) {
        backingString.setAttributes(attrs, range: range)
        self.edited(.editedAttributes, range: range, changeInLength: 0)
    }
    
    override public func processEditing() {
        let string = self.string as NSString
        var paragraphRange = string.paragraphRange(for: editedRange)
        
        let lastParagraphIndex = paragraphRange.location + paragraphRange.length - 1
        let lastEditedIndex = max(
            editedRange.location,
            editedRange.location + editedRange.length - 1
        )
        
        let changedParagraphTrailingBorder = lastParagraphIndex <= lastEditedIndex
        let nextParagraphExists = lastParagraphIndex < string.length - 1
        let nextParagraphShouldBeProcessed = changedParagraphTrailingBorder && nextParagraphExists
        
        if nextParagraphShouldBeProcessed {
            // We need to process the next paragraph when the user press the enter key at the middle
            // of a line. Since the paragraph for the edit is the one corresponding to the first
            // half of the line, we also need to re-compute the styles for the second half to fix
            // its styles. For instance, if the line is a header, we need to remove the header
            // styles from the second line.
            paragraphRange = string.paragraphRange(
                for: NSRange(location: paragraphRange.location, length: paragraphRange.length + 1)
            )
        }
        
        self.setAttributes(defaultAttributes, range: paragraphRange)
        
        let styles = markdownParser.styles(forString: string, atRange: paragraphRange)
        
        for style in styles {
            if style.attributeKey == .fontTraits {
                guard let fontTraits = style.value as? UIFontDescriptorSymbolicTraits else {
                    fatalError("Attribute `fontTraints` should have a value of type `UIFontDescriptorSymbolicTraits`")
                }
                
                let currentAttrs = self.attributes(at: style.startIndex, effectiveRange: nil)
                
                guard let currentFont = currentAttrs[.font] as? UIFont else {
                    fatalError("Unable to retrieve font for position \(style.startIndex)")
                }
                
                let newFont = currentFont.adding(traits: fontTraits)
                
                self.addAttribute(.font, value: newFont, range: style.range)
            }
            else {
                self.addAttribute(style.attributeKey, value: style.value, range: style.range)
            }
        }
        
        super.processEditing()
    }
    
    private func refreshContent() {
        let newMarkdowElements = markdownParser.markdownElements
            .map { $0.applying(stylesConfiguration: stylesConfiguration) }
        
        markdownParser = MarkdownParser(markdownElements: newMarkdowElements)
        
        let fullRange = NSRange(location: 0, length: string.utf16.count)
        
        self.edited(.editedAttributes, range: fullRange, changeInLength: 0)
    }
}
