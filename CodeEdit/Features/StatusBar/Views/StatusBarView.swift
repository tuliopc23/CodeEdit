//
//  StatusBarView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 19.03.22.
//

import SwiftUI
import Combine
import CodeEditTextView
import CodeEditSourceEditor

/// # StatusBarView
///
/// A View that lives on the bottom of the window and offers information
/// about compilation errors/warnings, git,  cursor position in text,
/// indentation width (in spaces), text encoding and linebreak.
///
/// Also information about the file size and dimensions, if available.
///
/// Additionally it offers a togglable/resizable drawer which can
/// host a terminal or additional debug information
///
struct StatusBarView: View {
    @Environment(\.controlActiveState)
    private var controlActive

    static let height = 28.0

    @Environment(\.colorScheme)
    private var colorScheme

    var proxy: SplitViewProxy

    static let statusbarID = "statusbarID"

    /// The actual status bar
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
//            StatusBarBreakpointButton()
//            StatusBarDivider()
            StatusBarVimModeView()
            Spacer()
            StatusBarFileInfoView()
            StatusBarCursorPositionLabel()
            StatusBarDivider()
            StatusBarToggleUtilityAreaButton()
        }
        .padding(.horizontal, 10)
        .cursor(.resizeUpDown)
        .frame(height: Self.height)
        .background(.ultraThinMaterial)
        .gesture(dragGesture)
        .disabled(controlActive == .inactive)
    }

    /// A drag gesture to resize the drawer beneath the status bar
    private var dragGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                proxy.setPosition(of: 0, position: value.location.y + Self.height / 2)
            }
    }
}

struct StatusBarDivider: View {
    var body: some View {
        Divider()
            .frame(maxHeight: 12)
//            .padding(.horizontal, 7)
    }
}

extension View {
    func cursor(_ cursor: NSCursor) -> some View {
        onHover {
            if $0 {
                cursor.push()
            } else {
                cursor.pop()
            }
        }
    }
}

struct StatusBarVimModeView: View {
    @EnvironmentObject private var editorManager: EditorManager
    @AppSettings(\.textEditing.enableVimMode) var enableVimMode

    var body: some View {
        if enableVimMode, let vimState = editorManager.activeEditor.selectedTab?.vimState {
            VimModeLabel(vimState: vimState)
        }
    }

    struct VimModeLabel: View {
        @ObservedObject var vimState: VimState

        var body: some View {
            HStack(spacing: 8) {
                // Mode Display
                HStack(spacing: 4) {
                    Text(vimState.mode.rawValue)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(modeColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(modeColor.opacity(0.1))
                        .cornerRadius(4)
                }

                // Command Buffer (if any)
                if !vimState.commandBuffer.isEmpty {
                    Text(vimState.commandBuffer)
                        .font(.caption)
                        .monospaced()
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 5)
        }

        var modeColor: Color {
            switch vimState.mode {
            case .normal: return .blue
            case .insert: return .green
            case .visual, .visualLine: return .orange
            case .replace: return .red
            }
        }
    }
}
