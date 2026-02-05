import ProjectDescription

let tuist = Tuist(
    fullHandle: "codeedit/codeedit",
    url: "https://cloud.tuist.io",
    project: .tuist(
        generationOptions: .options(
            optionalAuthentication: true
        )
    )
)
