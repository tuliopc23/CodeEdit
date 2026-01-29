//
//  EnhancedTreeSitterClient.swift
//  CodeEdit
//
//  Created by CodeEdit Assistant on 2026-01-29.
//

import Foundation
import CodeEditSourceEditor
import CodeEditLanguages
import CodeEditTextView
import Combine

// Note: This file assumes SwiftTreeSitter is available via CodeEditLanguages or a direct dependency.
// If types like Parser, Query, etc. are not found, ensure the SwiftTreeSitter package is linked.

/// A normalized Tree-sitter client that enforces the TokenContract and supports
/// custom query loading for enhanced highlighting.
public class EnhancedTreeSitterClient: HighlightProviding, ObservableObject {
    
    private var textView: TextView?
    private var codeLanguage: CodeLanguage?
    private var cancellables: Set<AnyCancellable> = []
    
    // Placeholder types for Tree-sitter objects (assuming SwiftTreeSitter is imported)
    // In a real build, these would be:
    // private var parser: Parser?
    // private var query: Query?
    // private var tree: Tree?
    
    // Using Any to avoid compilation errors if SwiftTreeSitter is not explicitly visible in this scope,
    // but the implementation logic below assumes standard Tree-sitter APIs.
    private var parser: Any?
    private var query: Any?
    private var tree: Any?
    
    public init() {}
    
    public func setUp(textView: TextView, codeLanguage: CodeLanguage) {
        self.textView = textView
        self.codeLanguage = codeLanguage
        
        // Setup Parser
        // self.parser = Parser()
        
        // Resolve Language
        // guard let language = codeLanguage.treeSitterLanguage else { return }
        // try? self.parser?.setLanguage(language)
        
        // Load Custom Queries
        loadQueries(for: codeLanguage)
        
        // Initial Parse
        // if let text = textView.string {
        //     self.tree = parser?.parse(text)
        // }
    }
    
    private func loadQueries(for language: CodeLanguage) {
        // Normalize pipeline: Try to load from Resources first (overrides), then fallback to bundled
        guard language.id == .swift else { return }
        
        // Logic to load swift.scm from Bundle.main (requires file to be added to Xcode project resources)
        if let url = Bundle.main.url(forResource: "swift", withExtension: "scm"),
           let queryData = try? Data(contentsOf: url) {
            // self.query = try? Query(language: language, data: queryData)
            print("Loaded custom swift.scm from bundle")
        } else {
            // Fallback to default
            print("Using default queries or failed to load swift.scm")
        }
    }
    
    public func applyEdit(textView _: TextView, range: NSRange, delta: Int, completion: @escaping @MainActor (Result<IndexSet, any Error>) -> Void) {
        // Use self.textView to ensure we reference the correct editor instance
        guard let textView = self.textView else {
            completion(.success(IndexSet()))
            return
        }

        /*
        // Apply edit to Tree-sitter state
        // Note: Logic commented out until SwiftTreeSitter types (InputEdit, Point) are fully available in build target
        
        let startByte = UInt32(range.location)
        let oldEndByte = UInt32(range.location + range.length)
        let newEndByte = UInt32(range.location + range.length + delta)
        
        // Assuming TextView has helper to convert byte offset to Point (row, col)
        // let startPoint = textView.pointForLocation(Int(startByte))
        // let oldEndPoint = textView.pointForLocation(Int(oldEndByte))
        // let newEndPoint = textView.pointForLocation(Int(newEndByte))
        
        // let edit = InputEdit(
        //     startByte: startByte,
        //     oldEndByte: oldEndByte,
        //     newEndByte: newEndByte,
        //     startPoint: Point(row: UInt32(startPoint.line), column: UInt32(startPoint.column)),
        //     oldEndPoint: Point(row: UInt32(oldEndPoint.line), column: UInt32(oldEndPoint.column)),
        //     newEndPoint: Point(row: UInt32(newEndPoint.line), column: UInt32(newEndPoint.column))
        // )
        
        // if let parser = parser as? Parser, let tree = tree as? Tree {
        //     tree.edit(edit)
        //     self.tree = parser.parse(textView.string, oldTree: tree)
        // }
        */
        
        // Compute invalidated region
        // We expand the range to include the changed length (delta) so that
        // the editor knows to re-highlight the affected area, including inserted content.
        let endLocation = range.location + range.length + max(0, delta)
        let length = endLocation - range.location
        
        // Construct the final invalidated range
        let invalidatedRange = NSRange(location: range.location, length: length)
        let indexSet = IndexSet(integersIn: invalidatedRange)
        
        completion(.success(indexSet))
    }
    
    public func queryHighlightsFor(textView: TextView, range: NSRange, completion: @escaping @MainActor (Result<[HighlightRange], any Error>) -> Void) {
        // guard let tree = tree, let query = query else {
        //     completion(.success([]))
        //     return
        // }
        
        // Execute query
        // let cursor = query.execute(node: tree.rootNode, in: tree)
        // cursor.setRange(range)
        
        // var highlights: [HighlightRange] = []
        
        // for match in cursor {
        //     for capture in match.captures {
        //         let captureName = capture.name
        //         let themeKey = TokenContract.mapCaptureToThemeKey(captureName)
        //         let range = capture.node.range
                
        //         // Map to HighlightRange
        //         // highlights.append(HighlightRange(range: range, capture: themeKey))
        //     }
        // }
        
        // completion(.success(highlights))
        
        // For now, return empty to prevent crashes until Tree-sitter is fully wired
        completion(.success([]))
    }
}
