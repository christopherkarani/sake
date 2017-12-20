import Foundation
import SakefileDescription
import SakefileUtils

// MARK: - Tasks

enum Task: String, CustomStringConvertible {
    case documentation = "docs"
    case continuousIntegration = "ci"
    case release = "release"
    case updateFormula = "update_formula"
    var description: String {
        switch self {
        case .documentation:
            return "Generates the project documentation"
        case .continuousIntegration:
            return "Runs the the operations that are executed on CI"
        case .release:
            return "Releases a new version of the Sake"
        case .updateFormula:
            return "Updates the Homebrew formula version"
        }
    }
}

func generateDocs(utils: Utils) throws {
    try utils.shell.runAndPrint(bash: "swift package generate-xcodeproj")
    try utils.shell.runAndPrint(bash: "bundle exec jazzy --clean --sdk macosx --xcodebuild-arguments -scheme,sake --skip-undocumented")
}

func createVersion(version: String, branch: String, utils: Utils) throws {
    try utils.git.createBranch(branch)
    print("> Building the project")
    try utils.shell.runAndPrint(bash: "swift build")
    print("> Generating docs")
    try generateDocs(utils: utils)
    try utils.git.addAll()
    try utils.git.commitAll(message: "[\(branch)] Bump version")
    try utils.git.tag(version)
    try utils.git.push(remote: "origin", branch: branch, tags: true)
}

func updateFormula(version: String, branch: String, utils: Utils) throws {
    let formulaPath = "Formula/sake.rb"
    print("> Updating formula to \(version)")
    let archiveURL = "https://github.com/xcodeswift/sake/archive/\(version).tar.gz"
    try utils.shell.runAndPrint(bash: "curl -LSs \(archiveURL) -o sake.tar.gz")
    let sha = try utils.shell.run(bash: "shasum -a 256 sake.tar.gz | awk '{printf $1}'")
    _ = try utils.shell.run(bash: "sed -i \"\" 's|version .*$|version \"\(version)\"|' \(formulaPath)")
    _ = try utils.shell.run(bash: "sed -i \"\" 's|sha256 .*$|sha256 \"\(sha)\"|' \(formulaPath)")
    try utils.shell.runAndPrint(bash: "rm sake.tar.gz")
    print("> Commiting and pushing the changes to release/\(version)")
    try utils.git.add(paths: formulaPath)
    try utils.git.commit(message: "[\(branch)] Update formula")
    try utils.git.push(remote: "origin", branch: branch)
}

Sake<Task> {
    try $0.task(.documentation) { (utils) in
        try generateDocs(utils: utils)
    }
    try $0.task(.continuousIntegration) { utils in
        print("> Linting the project")
        try utils.shell.runAndPrint(bash: "swiftlint")
        print("> Building the project")
        try utils.shell.runAndPrint(bash: "swift build")
        print("> Testing the project")
        try utils.shell.runAndPrint(bash: "swift test")
    }
    try $0.task(.release) { (utils) in
        if try utils.git.anyChanges() { throw "Commit all your changes before starting the release" }
        if try utils.git.branch() != "master" { throw "The release process should be initialized from master" }
        let nextVersion = try Version(utils.git.lastTag()).bumpingMinor()
        let branch = "release/\(nextVersion.string)"
        try createVersion(version: nextVersion.string, branch: branch, utils: utils)
        try updateFormula(version: nextVersion.string, branch: branch, utils: utils)
    }
}


