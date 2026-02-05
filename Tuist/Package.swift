// swift-tools-version: 6.2
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [
            "CodeEditSymbols": .framework,
            "Sparkle": .framework,
            "SnapshotTesting": .framework,
            "Collections": .framework,
            "CollectionConcurrencyKit": .framework,
            "GRDB": .framework,
            "LogStream": .framework,
            "CodeEditKit": .framework,
            "SwiftUIIntrospect": .framework,
            "LanguageClient": .framework,
            "LanguageServerProtocol": .framework,
            "AsyncAlgorithms": .framework,
            "ZIPFoundation": .framework,
            "WelcomeWindow": .framework,
            "AboutWindow": .framework,
            "CodeEditSourceEditor": .framework,
            "AnyCodable": .framework,
            "CodeEditLanguages": .framework,
            "CodeEditTextView": .framework,
            "ConcurrencyPlus": .framework,
            "FSEventsWrapper": .framework,
            "JSONRPC": .framework,
            "ProcessEnv": .framework,
            "Queue": .framework,
            "Rearrange": .framework,
            "Semaphore": .framework,
            "Glob": .framework,
            "SwiftSyntax": .framework,
            "SwiftLint": .framework,
            "SwiftTreeSitter": .framework,

            "TextFormation": .framework,
            "TextStory": .framework,
            "TreeSitter": .framework
        ]
    )
#endif

let package = Package(
    name: "CodeEdit",
    platforms: [
        .macOS("26.0")
    ],
    dependencies: [
        .package(url: "https://github.com/CodeEditApp/AboutWindow", exact: "1.0.0"),
        .package(url: "https://github.com/Flight-School/AnyCodable", exact: "0.6.7"),
        .package(url: "https://github.com/CodeEditApp/CodeEditKit.git", exact: "0.1.2"),
        .package(url: "https://github.com/CodeEditApp/CodeEditLanguages.git", exact: "0.1.20"),
        .package(url: "https://github.com/CodeEditApp/CodeEditSourceEditor", exact: "0.15.1"),
        .package(url: "https://github.com/CodeEditApp/CodeEditSymbols", exact: "0.2.3"),
        .package(url: "https://github.com/CodeEditApp/CodeEditTextView.git", exact: "0.12.1"),
        .package(url: "https://github.com/johnsundell/collectionconcurrencykit", exact: "0.2.0"),
        .package(url: "https://github.com/ChimeHQ/ConcurrencyPlus", exact: "0.4.2"),
        .package(url: "https://github.com/Frizlab/FSEventsWrapper", exact: "2.1.0"),
        .package(url: "https://github.com/groue/GRDB.swift.git", exact: "6.29.3"),
        .package(url: "https://github.com/ChimeHQ/JSONRPC", exact: "0.9.0"),
        .package(url: "https://github.com/ChimeHQ/LanguageClient", exact: "0.8.2"),
        .package(url: "https://github.com/ChimeHQ/LanguageServerProtocol", exact: "0.14.0"),
        .package(url: "https://github.com/Wouter01/LogStream", exact: "1.3.0"),
        .package(url: "https://github.com/ChimeHQ/ProcessEnv", exact: "1.0.0"),
        .package(url: "https://github.com/mattmassicotte/Queue", exact: "0.1.4"),
        .package(url: "https://github.com/ChimeHQ/Rearrange", exact: "2.0.0"),
        .package(url: "https://github.com/groue/Semaphore", exact: "0.1.0"),
        .package(url: "https://github.com/sparkle-project/Sparkle.git", exact: "2.3.0"),
        .package(url: "https://github.com/apple/swift-async-algorithms.git", exact: "1.0.1"),
        .package(url: "https://github.com/apple/swift-collections.git", exact: "1.1.3"),
        .package(url: "https://github.com/davbeck/swift-glob", exact: "0.2.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", exact: "1.14.2"),
        .package(url: "https://github.com/apple/swift-syntax.git", exact: "509.1.1"),
        .package(url: "https://github.com/lukepistrol/SwiftLintPlugin", exact: "0.59.1"),
        .package(url: "https://github.com/ChimeHQ/SwiftTreeSitter.git", exact: "0.25.0"),
        .package(url: "https://github.com/siteline/SwiftUI-Introspect.git", exact: "1.3.0"),
        .package(url: "https://github.com/ChimeHQ/TextFormation", exact: "0.9.0"),
        .package(url: "https://github.com/ChimeHQ/TextStory", exact: "0.9.1"),
        .package(url: "https://github.com/tree-sitter/tree-sitter", exact: "0.25.8"),
        .package(url: "https://github.com/CodeEditApp/WelcomeWindow", exact: "1.1.0"),
        .package(url: "https://github.com/weichsel/ZIPFoundation", exact: "0.9.19")
    ]
)
