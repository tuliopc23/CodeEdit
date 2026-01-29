//
//  TokenContract.swift
//  CodeEdit
//
//  Created by CodeEdit Assistant on 2026-01-29.
//

import Foundation
import CodeEditSourceEditor

/// Defines the standardized token capture names for syntax highlighting in CodeEdit.
/// This contract ensures consistency between Tree-sitter queries and the Theme engine.
///
/// The contract maps semantic concepts (e.g., "function declaration") to standard capture names
/// that align with `Theme.EditorColors`.
public enum TokenContract {
    // MARK: - Core Tokens (Mapped to Theme.EditorColors)
    
    /// Keywords (e.g., `if`, `else`, `return`, `func`, `class`)
    /// Maps to: `theme.editor.keywords`
    public static let keyword = "keyword"
    
    /// Function and method calls/definitions
    /// Maps to: `theme.editor.commands`
    public static let function = "function"
    public static let method = "method"
    
    /// Type declarations and references (Classes, Structs, Enums, Protocols)
    /// Maps to: `theme.editor.types`
    public static let type = "type"
    public static let typeBuiltin = "type.builtin"
    
    /// Attributes and decorators (e.g., `@Published`, `@IBOutlet`)
    /// Maps to: `theme.editor.attributes`
    public static let attribute = "attribute"
    public static let property = "property" // Sometimes mapped to attributes or variables depending on context
    
    /// Variables and parameters
    /// Maps to: `theme.editor.variables`
    public static let variable = "variable"
    public static let variableBuiltin = "variable.builtin"
    public static let parameter = "parameter"
    
    /// Values and constants
    /// Maps to: `theme.editor.values`
    public static let number = "number"
    public static let boolean = "boolean"
    public static let constant = "constant"
    public static let constantBuiltin = "constant.builtin"
    
    /// String literals
    /// Maps to: `theme.editor.strings`
    public static let string = "string"
    public static let escape = "string.escape"
    
    /// Characters (if distinct from strings)
    /// Maps to: `theme.editor.characters`
    public static let character = "character"
    
    /// Comments
    /// Maps to: `theme.editor.comments`
    public static let comment = "comment"
    
    /// Operators and Punctuation (often uncolored or mapped to text)
    /// Maps to: `theme.editor.text` or specific operator color if available
    public static let `operator` = "operator"
    public static let punctuation = "punctuation"
    public static let punctuationBracket = "punctuation.bracket"
    public static let punctuationDelimiter = "punctuation.delimiter"
    
    // MARK: - Mapping Logic
    
    /// Returns the mapping from a capture name to a Theme attribute key.
    /// This function serves as the reference implementation for the contract.
    public static func mapCaptureToThemeKey(_ capture: String) -> String {
        switch capture {
        case keyword, "keyword.control", "keyword.operator", "include", "repeat", "conditional":
            return "keywords"
        case function, method, "constructor", "function.macro":
            return "commands"
        case type, typeBuiltin, "class", "struct", "enum", "protocol":
            return "types"
        case attribute, "decorator":
            return "attributes"
        case variable, variableBuiltin, parameter, property, "field":
            return "variables"
        case number, boolean, constant, constantBuiltin:
            return "values" // Or "numbers" if we want to be specific, but "values" is safer for general constants
        case string, escape:
            return "strings"
        case character:
            return "characters"
        case comment, "comment.block", "comment.line":
            return "comments"
        default:
            return "text"
        }
    }
}
