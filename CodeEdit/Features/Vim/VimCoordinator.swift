//
//  VimCoordinator.swift
//  CodeEdit
//
//  Created by CodeEdit Assistant on 2026-02-05.
//

import Foundation
import CodeEditTextView
import AppKit

final class VimCoordinator: TextViewCoordinator {
    var vimState: VimState
    var commandProcessor: VimCommandProcessor

    init(vimState: VimState) {
        self.vimState = vimState
        self.commandProcessor = VimCommandProcessor(state: vimState)
    }

    func prepareCoordinator(controller: TextViewController) { }

    func destroy() { }

    func textView(_ textView: TextView, didCheckForEvent event: NSEvent) -> Bool {
        guard vimState.mode != .insert else {
            // Check for Esc to exit insert mode
            if event.keyCode == 53 { // Esc
                vimState.enterNormalMode()
                return true // Swallow Esc
            }
            return false // Pass through to editor
        }

        // In Normal/Visual mode, intercept keys
        if event.type == .keyDown {
            return commandProcessor.handle(event: event, textView: textView)
        }

        return false
    }
}
