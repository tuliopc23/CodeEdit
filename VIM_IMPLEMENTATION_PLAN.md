# Vim Mode Implementation Plan for CodeEdit

This document outlines the architectural plan to implement a Neovim-like modal editing experience in CodeEdit, leveraging the existing `TextViewCoordinator` pattern and `NSEvent` monitoring.

## 1. Architecture Overview

The system will sit between the user's keyboard input and the underlying `CodeEditTextView`.

```mermaid
graph TD
    A[Keyboard Event (NSEvent)] --> B[VimCoordinator];
    B -->|Check Mode| C{VimState};
    C -->|Insert Mode| D[Pass to Editor];
    C -->|Normal/Visual| E[VimCommandProcessor];
    E -->|Calculate Motion| F[VimMotionEngine];
    E -->|Execute Action| G[TextViewController];
    G -->|Update UI| H[CodeFileView];
    C -->|Update Status| I[VimModeView (Modeline)];
```

### Core Components

1.  **VimState (`ObservableObject`)**
    *   **State:** `currentMode` (Normal, Insert, Visual, VisualLine, Replace).
    *   **Buffer:** `commandBuffer` (e.g., "d2" waiting for "w").
    *   **Registers:** Dictionary for yank/paste registers.
    *   **History:** Command history.

2.  **VimCoordinator (`TextViewCoordinator`)**
    *   **Role:** The bridge. Attaches to `CodeFileView`.
    *   **Mechanism:** Uses `NSEvent.addLocalMonitorForEvents` to intercept keys when the editor is focused.
    *   **Responsibility:** Routes keys to `VimCommandProcessor`.

3.  **VimCommandProcessor**
    *   **Role:** The parser.
    *   **Logic:** Decodes key sequences (e.g., `c`, `i`, `w` -> Change Inner Word).
    *   **Input:** Key events.
    *   **Output:** Actionable commands (Motion or Operator).

4.  **VimMotionEngine**
    *   **Role:** Text analysis.
    *   **Logic:** Calculates target `NSRange` for motions (e.g., "Move to next word end").
    *   **Helpers:** `findNextWord`, `findEndOfLine`, `findMatchingBracket`.

5.  **VimOperatorEngine**
    *   **Role:** Text mutation.
    *   **Logic:** Executes operators on ranges (Delete, Yank, Change, Indent).

## 2. Implementation Roadmap

### Phase 1: Foundation & Basic Navigation (Medium Effort)
*   **Goal:** Switch modes and move cursor.
*   **Tasks:**
    1.  Create `VimState` and `VimCoordinator`.
    2.  Implement key interception logic (swallow keys in Normal mode).
    3.  Implement basic motions:
        *   `h, j, k, l` (Left, Down, Up, Right)
        *   `w, b, e` (Word navigation)
        *   `gg, G` (File start/end)
        *   `0, $` (Line start/end)
    4.  Implement basic Insert mode toggle (`i`, `a`, `o`, `Esc`).
    5.  Inject into `CodeFileView`.

### Phase 2: Operators & Edits (Medium-High Effort)
*   **Goal:** Edit text using Vim grammar.
*   **Tasks:**
    1.  Implement `VimCommandProcessor` to handle Operator + Motion (e.g., `d` + `w`).
    2.  Implement Operators:
        *   `d` (Delete)
        *   `c` (Change - Delete + Enter Insert)
        *   `y` (Yank - Copy to clipboard/register)
        *   `p` (Paste)
        *   `u` (Undo - wrap `undoManager`)
    3.  Implement Repeat counts (e.g., `3j`, `d2w`).

### Phase 3: Visual Mode & Advanced Navigation (High Effort)
*   **Goal:** Select text and perform visual operations.
*   **Tasks:**
    1.  Implement `v` (Visual Character) and `V` (Visual Line).
    2.  Update cursor/selection rendering (if possible) or use native selection range.
    3.  Support Visual operators (`d`, `y`, `c` on selection).
    4.  Implement Text Objects (`iw`, `it`, `hp`, etc. - "Inner Word", "Inner Tag").

### Phase 4: Search & UI (Medium Effort)
*   **Goal:** Search and Status Bar integration.
*   **Tasks:**
    1.  Implement `/` command:
        *   Focus `EditorInstance.findText`.
        *   Intercept Enter to jump to match.
    2.  Implement `n / N` (Next/Prev match).
    3.  **Vim Modeline UI:**
        *   Create `VimModeView` (Pill shape).
        *   Overlay on `EditorAreaView` (bottom right or bottom center).
        *   Show Mode (NORMAL/INSERT) and pending keys.

## 3. Keybind Specifications (Neovim-like)

| Key | Action | Implementation Note |
| :--- | :--- | :--- |
| `Esc` | Normal Mode | Clear buffer, reset selection. |
| `i` | Insert (Before) | Pass through to editor. |
| `a` | Insert (After) | Move cursor right, then Insert. |
| `o` | Open Line Below | Insert newline, move down, Insert. |
| `O` | Open Line Above | Insert newline (start), move up, Insert. |
| `v` | Visual Mode | Start tracking selection anchor. |
| `/` | Search | Focus Find field. |
| `:` | Command Line | Open Command Palette (or custom input). |
| `u` | Undo | `undoManager?.undo()` |
| `Ctrl+r` | Redo | `undoManager?.redo()` |

## 4. Technical Constraints & Solutions

*   **Key Interception:** `NSEvent.addLocalMonitorForEvents` is global to the app. We must check `controller.view.window?.firstResponder` to ensure we only act when *this* editor is focused.
*   **Cursor Style:** Vim requires Block cursor in Normal mode.
    *   *Solution:* Check `CodeEditSourceEditor` config. If it exposes cursor style, bind it to `VimState.mode`. If not, we might need a PR to the package or overlay a fake cursor (complex).
*   **Scroll:** `j/k` at screen edges must scroll. `TextViewController.scrollToVisible` handles this.

## 5. Next Steps

1.  Scaffold the `Vim` feature directory.
2.  Implement `VimCoordinator` with basic `hjkl` support.
3.  Add the "Enable Vim Mode" toggle in Settings.
