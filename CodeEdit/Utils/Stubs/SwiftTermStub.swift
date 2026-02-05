//
//  SwiftTermStub.swift
//  CodeEdit
//
//  Created by CodeEdit Assistant on 2026-02-05.
//

import AppKit
import Foundation

// MARK: - SwiftTerm Stub

// Define a namespace for SwiftTerm.Color
struct SwiftTerm {
    struct Color {
        var swiftColor: NSColor = .black
        init(hex: String) {
            self.swiftColor = NSColor(hex: hex)
        }
    }
}

// Helpers for the Color stub
extension NSColor {
    convenience init(hex: String) {
        self.init(red: 0, green: 0, blue: 0, alpha: 1) // Dummy implementation
    }
}

class TerminalView: NSView {
    var terminal: Terminal = Terminal()
    var font: NSFont?
    var caretColor: NSColor = .black
    var caretTextColor: NSColor = .white
    var selectedTextBackgroundColor: NSColor = .blue
    var nativeForegroundColor: NSColor = .black
    var nativeBackgroundColor: NSColor = .white
    var optionAsMetaKey: Bool = false
    var terminalDelegate: TerminalDelegate?
    
    // appearance is handled by NSView

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func installColors(_ colors: [SwiftTerm.Color]) {}
    func cursorStyleChanged(source: Terminal, newStyle: CursorStyle) {}
    func feed(text: String) {}
    func feed(byteArray: ArraySlice<UInt8>) {}
    func getTerminal() -> Terminal { return terminal }
    
    // Helper to allow `super.frame` access if needed in subclasses (though they override it)
}

protocol TerminalViewDelegate: AnyObject {
    func sizeChanged(source: TerminalView, newCols: Int, newRows: Int)
    func setTerminalTitle(source: TerminalView, title: String)
    func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?)
    func processTerminated(source: TerminalView, exitCode: Int32?)
}

class Terminal {
    struct WindowSize {
         var x: Int = 0
         var y: Int = 0
    }
    var delegate: TerminalDelegate?
    var cols: Int = 80
    var rows: Int = 24
    var buffer: WindowSize = WindowSize()
    var silentLog: Bool = false
    
    init(delegate: TerminalDelegate? = nil, options: TerminalOptions = TerminalOptions()) {}
    static func getEnvironmentVariables() -> [String] { return [] }
    func resetToInitialState() {}
    func feed(text: String) {}
    func getText(start: Position, end: Position) -> String { return "" }
    func getTopVisibleRow() -> Int { return 0 }
    func softReset() {}
}

struct TerminalOptions {
    init(scrollback: Int = 1000) {}
}

struct Position {
    var col: Int
    var row: Int
}

enum CursorStyle {
    case blinkBlock, steadyBlock, blinkUnderline, steadyUnderline, blinkBar, steadyBar
}

// Re-definition of winsize since it's used in protocols
struct winsize {
    var ws_row: UInt16 = 0
    var ws_col: UInt16 = 0
    var ws_xpixel: UInt16 = 0
    var ws_ypixel: UInt16 = 0
}

class LocalProcess {
    var delegate: LocalProcessDelegate?
    var childfd: Int32 = 0
    var shellPid: Int32 = 0
    var running: Bool = false
    init(delegate: LocalProcessDelegate) { self.delegate = delegate }
    func startProcess(executable: String, args: [String], environment: [String]?, execName: String?, currentDirectory: String?) {}
    func send(data: ArraySlice<UInt8>) {}
}

protocol LocalProcessDelegate: AnyObject {
    func processTerminated(_ source: LocalProcess, exitCode: Int32?)
    func dataReceived(slice: ArraySlice<UInt8>)
    func getWindowSize() -> winsize
}

protocol TerminalDelegate: AnyObject {
    func sizeChanged(source: TerminalView, newCols: Int, newRows: Int)
    func setTerminalTitle(source: TerminalView, title: String)
    func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?)
    func scrolled(source: TerminalView, position: Double)
    func rangeChanged(source: TerminalView, startY: Int, endY: Int)
    func clipboardCopy(source: TerminalView, content: Data)
}

class PseudoTerminalHelpers {
    static func setWinSize(masterPtyDescriptor: Int32, windowSize: inout winsize) -> Int32 { return 0 }
}
