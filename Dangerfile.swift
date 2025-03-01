import Danger
import DangerSwiftLint

let danger = Danger()

// MARK: - Core Checks

// 1. Check for CHANGELOG updates
let hasChangelog = danger.git.modifiedFiles.contains("CHANGELOG.md")
let isTrivial = (danger.github.pullRequest.title + (danger.github.pullRequest.body ?? "")).contains("#trivial")

if !hasChangelog && !isTrivial {
    warn("Please add a CHANGELOG entry.")
}

// 2. PR Size Check
let lineCount = (danger.github.pullRequest.additions ?? 0) + (danger.github.pullRequest.deletions ?? 0)
if lineCount > 500 {
    warn("PR is too big. Consider splitting into smaller PRs. (\(lineCount) lines)")
}

// 3. WIP Check
if danger.github.pullRequest.title.lowercased().contains("wip") {
    warn("PR is marked as Work in Progress.")
}

// 4. Documentation Check
let docsModified = danger.git.modifiedFiles.contains { $0.hasPrefix("Documentation/") }
let sourceModified = danger.git.modifiedFiles.contains { $0.hasPrefix("Sources/") }
if sourceModified && !docsModified {
    message("Consider updating documentation for these changes.")
}

// Prevent force unwrapping
let forbiddenPatterns = ["!", "?"]
for file in danger.git.modifiedFiles {
    let diff = danger.utils.diffForFile(file)
    if let content = diff?.content {
        for pattern in forbiddenPatterns {
            if content.contains(" \(pattern)") {
                fail("Force unwrapping (\(pattern)) found in \(file)")
            }
        }
    }
}

// Check for TODOs
let todos = danger.git.modifiedFiles.filter { file in
    let content = danger.utils.readFile(file)
    return content?.contains("TODO:") ?? false
}

if !todos.isEmpty {
    warn("TODOs found in modified files: \(todos.joined(separator: ", "))")
}

SwiftLint.lint(
    inline: true,
    configFile: ".swiftlint.yml",
    lintAllFiles: false,
    directory: "Sources"
)