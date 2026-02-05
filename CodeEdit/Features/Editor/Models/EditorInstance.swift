//
//  EditorInstance.swift
//  CodeEdit
//
//  Created by Khan Winter on 1/4/24.
//

import Foundation
import AppKit
import Combine
import CodeEditTextView
import CodeEditSourceEditor

/// A single instance of an editor in a group with a published ``EditorInstance/cursorPositions`` variable to publish
/// the user's current location in a file.
class EditorInstance: ObservableObject, Hashable {
    /// The file presented in this editor instance.
    let file: CEWorkspaceFile

    /// The Vim state for this editor instance.
    let vimState = VimState()

    /// A publisher for the user's current location in a file.
    @Published var cursorPositions: [CursorPosition]
    @Published var scrollPosition: CGPoint?

    @Published var findText: String?
    var findTextSubject: PassthroughSubject<String?, Never>

    @Published var replaceText: String?
    var replaceTextSubject: PassthroughSubject<String?, Never>

    var rangeTranslator: RangeTranslator = RangeTranslator()

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Init

    init(workspace: WorkspaceDocument?, file: CEWorkspaceFile, cursorPositions: [CursorPosition]? = nil) {
        self.file = file
        let url = file.url
        let editorState = EditorStateRestoration.shared?.restorationState(for: url)

        findText = workspace?.searchState?.searchQuery
        findTextSubject = PassthroughSubject()
        replaceText = workspace?.searchState?.replaceText
        replaceTextSubject = PassthroughSubject()

        self.cursorPositions = (
            cursorPositions ?? editorState?.editorCursorPositions ?? [CursorPosition(line: 1, column: 1)]
        )
        self.scrollPosition = editorState?.scrollPosition

        // Setup listeners

        Publishers.CombineLatest(
            $cursorPositions.removeDuplicates(),
            $scrollPosition
                .debounce(for: .seconds(0.1), scheduler: RunLoop.main) // This can trigger *very* often
                .removeDuplicates()
        )
        .sink { (cursorPositions, scrollPosition) in
            EditorStateRestoration.shared?.updateRestorationState(
                for: url,
                data: .init(cursorPositions: cursorPositions, scrollPosition: scrollPosition ?? .zero)
            )
        }
        .store(in: &cancellables)

        listenToFindText(workspace: workspace)
        listenToReplaceText(workspace: workspace)
    }

    func listenToFindText(workspace: WorkspaceDocument?) {
        workspace?.searchState?.$searchQuery
            .receive(on: RunLoop.main)
            .sink { [weak self] newQuery in
                if self?.findText != newQuery {
                    self?.findText = newQuery
                }
            }
            .store(in: &cancellables)
        findTextSubject
            .receive(on: RunLoop.main)
            .sink { [weak workspace, weak self] newFindText in
                if let newFindText, workspace?.searchState?.searchQuery != newFindText {
                    workspace?.searchState?.searchQuery = newFindText
                }
                self?.findText = workspace?.searchState?.searchQuery
            }
            .store(in: &cancellables)
    }

    func listenToReplaceText(workspace: WorkspaceDocument?) {
        workspace?.searchState?.$replaceText
            .receive(on: RunLoop.main)
            .sink { [weak self] newText in
                if self?.replaceText != newText {
                    self?.replaceText = newText
                }
            }
            .store(in: &cancellables)
        replaceTextSubject
            .receive(on: RunLoop.main)
            .sink { [weak workspace, weak self] newReplaceText in
                if let newReplaceText, workspace?.searchState?.replaceText != newReplaceText {
                    workspace?.searchState?.replaceText = newReplaceText
                }
                self?.replaceText = workspace?.searchState?.replaceText
            }
            .store(in: &cancellables)
    }

    // MARK: - Hashable

    static func == (lhs: EditorInstance, rhs: EditorInstance) -> Bool {
        lhs.file == rhs.file
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(file)
    }

    deinit {
        cancellables.forEach { $0.cancel() }
        rangeTranslator.destroy()
    }
}

/// A class that holds a strong reference to the text view controller.
class RangeTranslator: TextViewCoordinator {
    weak var textViewController: TextViewController?

    func textView(_ textView: TextView, didCheckForEvent event: NSEvent) -> Bool {
        return false
    }

    func prepareCoordinator(controller: TextViewController) {
        self.textViewController = controller
    }

    func controllerDidAppear(controller: TextViewController) {
        if controller.isEditable && controller.isSelectable {
            controller.view.window?.makeFirstResponder(controller.textView)
        }
    }

    func destroy() {
        self.textViewController = nil
    }

    func moveLinesUp() {
        guard let controller = textViewController else { return }
        controller.moveLinesUp()
    }

    func moveLinesDown() {
        guard let controller = textViewController else { return }
        controller.moveLinesDown()
    }

    /// Returns the number of lines contained within the given range in the current text view.
    /// Counts newline characters and adds one for non-empty selections.
    func linesInRange(_ range: NSRange) -> Int {
        guard let text = textViewController?.textView.string else { return 0 }
        guard let swiftRange = Range(range, in: text) else { return 0 }
        let substring = text[swiftRange]
        if substring.isEmpty { return 0 }
        let newlineCount = substring.reduce(0) { count, ch in ch == "\n" ? count + 1 : count }
        return newlineCount + 1
    }
}

