//
//  CodeFileView.swift
//  CodeEditModules/CodeFile
//
//  Created by Marco Carnevali on 17/03/22.
//

import Foundation
import SwiftUI
import CodeEditSourceEditor
import CodeEditTextView
import CodeEditLanguages
import Combine

/// CodeFileView is just a wrapper of the `CodeEditor` dependency
struct CodeFileView: View {
    @ObservedObject private var editorInstance: EditorInstance
    @ObservedObject private var codeFile: CodeFileDocument

    @State private var treeSitterClient: EnhancedTreeSitterClient = EnhancedTreeSitterClient()

    /// Any coordinators passed to the view.
    private var textViewCoordinators: [TextViewCoordinator]
    private var highlightProviders: [any HighlightProviding] = []

    @AppSettings(\.textEditing.defaultTabWidth)
    var defaultTabWidth
    @AppSettings(\.textEditing.indentOption)
    var indentOption
    @AppSettings(\.textEditing.lineHeightMultiple)
    var lineHeightMultiple
    @AppSettings(\.textEditing.wrapLinesToEditorWidth)
    var wrapLinesToEditorWidth
    @AppSettings(\.textEditing.overscroll)
    var overscroll
    @AppSettings(\.textEditing.font)
    var settingsFont
    @AppSettings(\.theme.useThemeBackground)
    var useThemeBackground
    @AppSettings(\.theme.matchAppearance)
    var matchAppearance
    @AppSettings(\.textEditing.letterSpacing)
    var letterSpacing
    @AppSettings(\.textEditing.bracketEmphasis)
    var bracketEmphasis
    @AppSettings(\.textEditing.useSystemCursor)
    var useSystemCursor
    @AppSettings(\.textEditing.showGutter)
    var showGutter
    @AppSettings(\.textEditing.showMinimap)
    var showMinimap
    @AppSettings(\.textEditing.showFoldingRibbon)
    var showFoldingRibbon
    @AppSettings(\.textEditing.reformatAtColumn)
    var reformatAtColumn
    @AppSettings(\.textEditing.showReformattingGuide)
    var showReformattingGuide
    @AppSettings(\.textEditing.invisibleCharacters)
    var invisibleCharactersConfiguration
    @AppSettings(\.textEditing.warningCharacters)
    var warningCharacters
    @AppSettings(\.textEditing.enableVimMode)
    var enableVimMode

    @Environment(\.colorScheme)
    private var colorScheme

    @EnvironmentObject var undoRegistration: UndoManagerRegistration

    @ObservedObject private var themeModel: ThemeModel = .shared

    private var cancellables = Set<AnyCancellable>()

    private let isEditable: Bool

    init(
        editorInstance: EditorInstance,
        codeFile: CodeFileDocument,
        textViewCoordinators: [TextViewCoordinator] = [],
        isEditable: Bool = true
    ) {
        self._editorInstance = .init(wrappedValue: editorInstance)
        self._codeFile = .init(wrappedValue: codeFile)

        self.textViewCoordinators = textViewCoordinators
            + [editorInstance.rangeTranslator]
            + [codeFile.contentCoordinator]
            + [codeFile.languageServerObjects.textCoordinator]
        self.isEditable = isEditable

        if let openOptions = codeFile.openOptions {
            codeFile.openOptions = nil
            editorInstance.cursorPositions = openOptions.cursorPositions
        }

        highlightProviders = [codeFile.languageServerObjects.highlightProvider] + [treeSitterClient]

        codeFile
            .contentCoordinator
            .textUpdatePublisher
            .sink { [weak codeFile] _ in
                codeFile?.updateChangeCount(.changeDone)
            }
            .store(in: &cancellables)
    }

    private func getBracketPairEmphasis() -> Any? {
        return nil
    }

    private var currentTheme: Theme {
        themeModel.selectedTheme ?? themeModel.themes.first!
    }

    @State private var font: NSFont = Settings[\.textEditing].font.current

    @Environment(\.edgeInsets)
    private var edgeInsets

    var body: some View {
        SourceEditor(
            codeFile.content ?? NSTextStorage(),
            language: codeFile.getLanguage(),
            configuration: SourceEditorConfiguration(
                appearance: .init(
                    theme: currentTheme.editor.editorTheme,
                    useThemeBackground: useThemeBackground,
                    font: font,
                    lineHeightMultiple: lineHeightMultiple,
                    letterSpacing: letterSpacing,
                    wrapLines: wrapLinesToEditorWidth,
                    useSystemCursor: useSystemCursor,
                    tabWidth: defaultTabWidth
                ),
                behavior: .init(
                    isEditable: isEditable,
                    indentOption: indentOption.textViewOption(),
                    reformatAtColumn: reformatAtColumn
                ),
                layout: .init(
                    editorOverscroll: overscroll.overscrollPercentage,
                    contentInsets: edgeInsets.nsEdgeInsets,
                    additionalTextInsets: NSEdgeInsets(top: 2, left: 0, bottom: 0, right: 0)
                ),
                peripherals: .init(
                    showGutter: showGutter,
                    showMinimap: showMinimap,
                    showReformattingGuide: showReformattingGuide,
                    showFoldingRibbon: showFoldingRibbon,
                    invisibleCharactersConfiguration: invisibleCharactersConfiguration.textViewOption(),
                    warningCharacters: Set(warningCharacters.characters.keys)
                )
            ),
            state: Binding(
                get: {
                    SourceEditorState(
                        cursorPositions: editorInstance.cursorPositions,
                        scrollPosition: editorInstance.scrollPosition,
                        findText: editorInstance.findText,
                        replaceText: editorInstance.replaceText
                    )
                },
                set: { newState in
                    editorInstance.cursorPositions = newState.cursorPositions ?? []
                    editorInstance.scrollPosition = newState.scrollPosition
                    editorInstance.findText = newState.findText
                    editorInstance.findTextSubject.send(newState.findText)
                    editorInstance.replaceText = newState.replaceText
                    editorInstance.replaceTextSubject.send(newState.replaceText)
                }
            ),
            highlightProviders: highlightProviders,
            undoManager: undoRegistration.manager(forFile: editorInstance.file),
            coordinators: textViewCoordinators + (enableVimMode ? [VimCoordinator(vimState: editorInstance.vimState)] : [])
        )
        // This view needs to refresh when the codefile changes. The file URL is too stable.
        .id(ObjectIdentifier(codeFile))
        .background {
            if colorScheme == .dark {
                EffectView(.underPageBackground)
            } else {
                EffectView(.contentBackground)
            }
        }
        .colorScheme(currentTheme.appearance == .dark ? .dark : .light)
        // minHeight zero fixes a bug where the app would freeze if the contents of the file are empty.
        .frame(minHeight: .zero, maxHeight: .infinity)
        .onChange(of: settingsFont) { _, newFontSetting in
            font = newFontSetting.current
        }
    }
}

private extension SettingsData.TextEditingSettings.IndentOption {
    func textViewOption() -> IndentOption {
        switch self.indentType {
        case .spaces:
            return IndentOption.spaces(count: spaceCount)
        case .tab:
            return IndentOption.tab
        }
    }
}

private extension SettingsData.TextEditingSettings.InvisibleCharactersConfig {
    func textViewOption() -> InvisibleCharactersConfiguration {
        guard self.enabled else { return .empty }
        var config = InvisibleCharactersConfiguration(
            showSpaces: self.showSpaces,
            showTabs: self.showTabs,
            showLineEndings: self.showLineEndings
        )

        config.spaceReplacement = self.spaceReplacement
        config.tabReplacement = self.tabReplacement
        config.carriageReturnReplacement = self.carriageReturnReplacement
        config.lineFeedReplacement = self.lineFeedReplacement
        config.paragraphSeparatorReplacement = self.paragraphSeparatorReplacement
        config.lineSeparatorReplacement = self.lineSeparatorReplacement

        return config
    }
}

// MARK: - Vim Implementation

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

