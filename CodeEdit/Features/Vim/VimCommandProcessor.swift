//
//  VimCommandProcessor.swift
//  CodeEdit
//
//  Created by CodeEdit Assistant on 2026-02-05.
//

import Foundation
import CodeEditTextView
import AppKit

final class VimCommandProcessor {
    unowned var state: VimState
    var motionEngine: VimMotionEngine

    init(state: VimState) {
        self.state = state
        self.motionEngine = VimMotionEngine()
    }

    func handle(event: NSEvent, textView: TextView) -> Bool {
        // Pass through commands (Cmd+C, Cmd+S, etc.)
        if event.modifierFlags.contains(.command) {
            return false
        }

        // Handle Escape
        if event.keyCode == 53 {
            state.enterNormalMode()
            return true
        }

        guard let char = event.characters?.first else { return false }

        // Clear command buffer if not continuing a sequence (e.g. "gg")
        if char != "g" {
            state.commandBuffer = ""
        }

        // Basic Navigation (hjkl)
        switch char {
        case "h":
            motionEngine.moveCursor(direction: .left, textView: textView)
            return true
        case "j":
            motionEngine.moveCursor(direction: .down, textView: textView)
            return true
        case "k":
            motionEngine.moveCursor(direction: .up, textView: textView)
            return true
        case "l":
            motionEngine.moveCursor(direction: .right, textView: textView)
            return true
        case "i":
            state.enterInsertMode()
            return true
        case "a":
             motionEngine.moveCursor(direction: .right, textView: textView)
             state.enterInsertMode()
             return true
        case "o":
            textView.moveToEndOfLine(nil)
            textView.insertNewline(nil)
            state.enterInsertMode()
            return true
        case "A":
            textView.moveToEndOfLine(nil)
            state.enterInsertMode()
            return true
        case "I":
            textView.moveToBeginningOfLine(nil)
            state.enterInsertMode()
            return true
        case "0":
            textView.moveToBeginningOfLine(nil)
            return true
        case "$":
            textView.moveToEndOfLine(nil)
            return true
        case "g":
            // Handle gg (needs buffer state)
            // For now, simple g to top
             if state.commandBuffer == "g" {
                 textView.moveToBeginningOfDocument(nil)
                 state.commandBuffer = ""
                 return true
             } else {
                 state.commandBuffer = "g"
                 return true
             }
        case "G":
            textView.moveToEndOfDocument(nil)
            return true
        default:
            break
        }

        return true // Swallow other keys in normal mode for now
    }
}
