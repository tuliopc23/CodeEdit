//
//  VimMotionEngine.swift
//  CodeEdit
//
//  Created by CodeEdit Assistant on 2026-02-05.
//

import Foundation
import CodeEditTextView

final class VimMotionEngine {
    enum Direction {
        case left, right, up, down
    }

    /// Moves the cursor in the specified direction using standard text view commands.
    /// Assumes the provided `textView` supports `moveLeft`, `moveRight`, `moveUp`, and `moveDown`.
    func moveCursor(direction: Direction, textView: TextView) {
        switch direction {
        case .left:
            textView.moveLeft(nil)
        case .right:
            textView.moveRight(nil)
        case .up:
            textView.moveUp(nil)
        case .down:
            textView.moveDown(nil)
        }
    }
}
