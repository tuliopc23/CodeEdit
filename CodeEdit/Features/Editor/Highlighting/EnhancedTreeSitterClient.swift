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
import SwiftTreeSitter

/// A normalized Tree-sitter client that enforces the TokenContract and supports
/// custom query loading for enhanced highlighting.
public class EnhancedTreeSitterClient: HighlightProviding, ObservableObject {

    private var textView: TextView?
    private var codeLanguage: CodeLanguage?
    private var cancellables: Set<AnyCancellable> = []

    private var parser: Parser?
    private var query: Query?
    private var tree: MutableTree?

    public init() {}

    public func setUp(textView: TextView, codeLanguage: CodeLanguage) {
        self.textView = textView
        self.codeLanguage = codeLanguage

        // Setup Parser
        self.parser = Parser()

        // Resolve Language
        guard let language = codeLanguage.language else { return }
        do {
             try self.parser?.setLanguage(language)
        } catch {
             print("Failed to set language: \(error)")
        }

        // Load Custom Queries
        loadQueries(for: codeLanguage)

        // Initial Parse
        let text = textView.string
        self.tree = parser?.parse(text)
    }

    private func loadQueries(for language: CodeLanguage) {
        // Normalize pipeline: Try to load from Resources first (overrides), then fallback to bundled

        // Logic to load swift.scm from Bundle.main (requires file to be added to Xcode project resources)
        if let url = Bundle.main.url(forResource: language.id.rawValue, withExtension: "scm"),
           let queryData = try? Data(contentsOf: url),
           let tsLanguage = language.language {
            self.query = try? Query(language: tsLanguage, data: queryData)
            print("Loaded custom \(language.id.rawValue).scm from bundle")
            return
        }

        // Fallback to CodeLanguage defaults
        if let queryURL = language.queryURL,
           let queryData = try? Data(contentsOf: queryURL),
           let tsLanguage = language.language {
            self.query = try? Query(language: tsLanguage, data: queryData)
            print("Loaded default query for \(language.id.rawValue)")
            return
        }

        print("Using default queries or failed to load \(language.id.rawValue).scm")
    }

    private func pointForLocation(_ location: Int) -> Point? {
        guard let textView = textView,
              let line = textView.layoutManager.textLineForOffset(location) else {
            return nil
        }
        let column = location - line.range.location
        return Point(row: UInt32(line.index), column: UInt32(column))
    }

    public func applyEdit(
        textView: TextView,
        range: NSRange,
        delta: Int,
        completion: @escaping @MainActor (Result<IndexSet, any Error>) -> Void
    ) {
        // Use self.textView to ensure we reference the correct editor instance
        guard let textView = self.textView else {
            completion(.success(IndexSet()))
            return
        }

        let startByte = UInt32(range.location)
        let oldEndByte = UInt32(range.location + range.length)
        let newEndByte = UInt32(range.location + range.length + delta)

        if let startPoint = pointForLocation(Int(startByte)),
           let oldEndPoint = pointForLocation(Int(oldEndByte)),
           let newEndPoint = pointForLocation(Int(newEndByte)) {

            let edit = InputEdit(
                startByte: startByte,
                oldEndByte: oldEndByte,
                newEndByte: newEndByte,
                startPoint: startPoint,
                oldEndPoint: oldEndPoint,
                newEndPoint: newEndPoint
            )

            if let parser = parser, let tree = tree {
                tree.edit(edit)
                self.tree = parser.parse(tree: tree, string: textView.string)
            }
        }

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

    public func queryHighlightsFor(
        textView: TextView,
        range: NSRange,
        completion: @escaping @MainActor (Result<[HighlightRange], any Error>) -> Void
    ) {
        guard let tree = tree, let query = query, let rootNode = tree.rootNode else {
            completion(.success([]))
            return
        }

        // Execute query
        let cursor = query.execute(node: rootNode, in: tree)
        cursor.setRange(range)

        var highlights: [HighlightRange] = []

        for match in cursor {
            for capture in match.captures {
                guard let captureNameString = capture.name else { continue }

                // Resolve CaptureName
                var captureName = CaptureName.fromString(captureNameString)
                if captureName == nil {
                    // Try splitting by dot (e.g. "keyword.control" -> "keyword")
                    let parts = captureNameString.split(separator: ".")
                    if let first = parts.first {
                        captureName = CaptureName.fromString(String(first))
                    }
                }

                guard let finalCaptureName = captureName else { continue }

                let range = capture.node.range

                // Map to HighlightRange
                highlights.append(HighlightRange(range: range, capture: finalCaptureName))
            }
        }

        completion(.success(highlights))
    }
}
