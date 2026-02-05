import ProjectDescription

let project = Project(
    name: "CodeEdit",
    organizationName: "CodeEditApp",
    options: .options(
        automaticSchemesOptions: .enabled(
            targetSchemesGrouping: .singleScheme,
            codeCoverageEnabled: true,
            testingOptions: .parallelizable
        ),
        developmentRegion: "en",
        disableBundleAccessors: true,
        disableSynthesizedResourceAccessors: true
    ),
    settings: .settings(
        configurations: [
            .debug(name: "Debug", xcconfig: "Configs/Debug.xcconfig"),
            .release(name: "Release", xcconfig: "Configs/Release.xcconfig"),
            .release(name: "Alpha", xcconfig: "Configs/Alpha.xcconfig"),
            .release(name: "Beta", xcconfig: "Configs/Beta.xcconfig"),
            .release(name: "Pre", xcconfig: "Configs/Pre.xcconfig")
        ]
    ),
    targets: [
        .target(
            name: "CodeEdit",
            destinations: .macOS,
            product: .app,
            bundleId: "app.codeedit.CodeEdit",
            deploymentTargets: .macOS("26.0"),
            infoPlist: .file(path: "CodeEdit/Info.plist"),
            sources: ["CodeEdit/**"],
            resources: [
                "CodeEdit/Resources/**",
                "CodeEdit/Assets.xcassets/**",
                "CodeEdit/Preview Content/**"
            ],
            entitlements: "CodeEdit/CodeEdit.entitlements",
            dependencies: [
                .external(name: "AboutWindow"),
                .external(name: "AnyCodable"),
                .external(name: "CodeEditKit"),
                .external(name: "CodeEditLanguages"),
                .external(name: "CodeEditSourceEditor"),
                .external(name: "CodeEditSymbols"),
                .external(name: "CodeEditTextView"),
                .external(name: "CollectionConcurrencyKit"),
                .external(name: "ConcurrencyPlus"),
                .external(name: "FSEventsWrapper"),
                .external(name: "GRDB"),
                .external(name: "JSONRPC"),
                .external(name: "LanguageClient"),
                .external(name: "LanguageServerProtocol"),
                .external(name: "LogStream"),
                .external(name: "ProcessEnv"),
                .external(name: "Queue"),
                .external(name: "Rearrange"),
                .external(name: "Semaphore"),
                .external(name: "Sparkle"),
                .external(name: "AsyncAlgorithms"),
                .external(name: "Collections"),
                .external(name: "Glob"),
                .external(name: "SnapshotTesting"),
                .external(name: "SwiftSyntax"),
                .external(name: "SwiftLint"),
                .external(name: "SwiftTreeSitter"),
                .external(name: "SwiftUIIntrospect"),
                .external(name: "TextFormation"),
                .external(name: "TextStory"),
                .external(name: "TreeSitter"),
                .external(name: "WelcomeWindow"),
                .external(name: "ZIPFoundation")
            ],
            settings: .settings(
                base: [
                    "ENABLE_HARDENED_RUNTIME": "YES",
                    "PRODUCT_NAME": "CodeEdit",
                    "OTHER_SWIFT_FLAGS": "$(inherited) -strict-concurrency=complete",
                    "ARCHS": "arm64"
                ]
            )
        ),
        .target(
            name: "CodeEditTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "app.codeedit.CodeEditTests",
            deploymentTargets: .macOS("14.0"),
            infoPlist: .default,
            sources: ["CodeEditTests/**"],
            dependencies: [
                .target(name: "CodeEdit"),
                .external(name: "SnapshotTesting")
            ]
        ),
        .target(
            name: "CodeEditUITests",
            destinations: .macOS,
            product: .uiTests,
            bundleId: "app.codeedit.CodeEditUITests",
            deploymentTargets: .macOS("14.0"),
            infoPlist: .default,
            sources: ["CodeEditUITests/**"],
            dependencies: [
                .target(name: "CodeEdit")
            ]
        )
    ]
)
