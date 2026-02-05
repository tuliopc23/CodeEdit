//
//  VimState.swift
//  CodeEdit
//
//  Created by CodeEdit Assistant on 2026-02-05.
//

import Foundation
import Combine

final class VimState: ObservableObject {
    enum Mode: String {
        case normal = "NORMAL"
        case insert = "INSERT"
        case visual = "VISUAL"
        case visualLine = "VISUAL LINE"
        case replace = "REPLACE"
    }

    @Published var mode: Mode = .normal
    @Published var commandBuffer: String = ""

    // For future phases
    // var registers: [String: String] = [:]
    // var history: [String] = []

    func enterInsertMode() {
        mode = .insert
        commandBuffer = ""
    }

    func enterNormalMode() {
        mode = .normal
        commandBuffer = ""
    }
}
