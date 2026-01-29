# CodeEdit

## Project Overview

CodeEdit is a native code editor for macOS, written entirely in Swift and SwiftUI. It aims to provide a lightweight, performant, and "Apple-native" experience similar to Xcode but for general-purpose development (supporting languages like Python, JS, Go, Rust, etc.). It is a community-driven open-source project.

## Technology Stack

*   **Language:** Swift
*   **UI Framework:** SwiftUI
*   **Platform:** macOS
*   **IDE:** Xcode
*   **Architecture:** Modular architecture with Feature-based organization (`CodeEdit/Features/...`). Uses a `ServiceContainer` for dependency injection.

## Key Directories

*   `CodeEdit/`: Main application source code.
    *   `Features/`: Contains feature-specific modules (e.g., `Editor`, `Search`, `Git`, `Settings`).
    *   `Utils/`: General utility classes and extensions.
    *   `Resources/`: App resources.
*   `CodeEditUI/`: Reusable UI components.
*   `CodeEdit.xcodeproj`: The Xcode project file.
*   `.github/`: GitHub Actions workflows and scripts.

## Build and Run

### Building
The project is built using Xcode. You can open `CodeEdit.xcodeproj` and build the `CodeEdit` scheme.

### Testing
Tests are run using `xcodebuild` via a helper script.

**Command:**
```bash
./.github/scripts/test_app.sh arm  # For Apple Silicon
# or
./.github/scripts/test_app.sh x86_64 # For Intel
```

### Linting
The project uses `SwiftLint` to enforce code style.

**Command:**
```bash
swiftlint --reporter github-actions-logging --strict
```

## Development Conventions

*   **Code Style:**
    *   Strict adherence to `SwiftLint` rules.
    *   **Spaces over Tabs** is enforced.
    *   No `TODO` comments allowed in committed code (disabled rule in `swiftlint.yml` but `remove_todos.sh` exists, and contributing guide warns about it).
    *   Resolve all Xcode `Violation` errors.
*   **Architecture:**
    *   Use `ServiceContainer` for registering singleton services (e.g., `LSPService`).
    *   Features are organized into folders within `CodeEdit/Features`.
*   **Contribution:**
    *   PRs must have a descriptive title, detailed description, screenshots/video for UI changes, and issue references.
    *   Mark PRs as "Draft" if work is in progress.
    *   Tests must pass before merging.

## Quick Start
1.  Open `CodeEdit.xcodeproj` in Xcode.
2.  Wait for Swift Package Manager to resolve dependencies.
3.  Select the `CodeEdit` scheme.
4.  Build and Run (Cmd + R).