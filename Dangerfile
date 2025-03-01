# Dangerfile for Swift project
# Sometimes it's a README fix, or something like that - which isn't relevant for
# including in a project's CHANGELOG for example
declared_trivial = github.pr_title.include? "#trivial"

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 500

# SwiftLint
swiftlint.config_file = '.vscode/.swiftlint.yml'
swiftlint.lint_files inline_mode: true

# Check for TODOs and FIXMEs left in the code
warn("TODOs should not be left in the code") if git.modified_files.any? { |file| file.end_with?('.swift') && `grep -l "TODO" #{file}`.length > 0 }
warn("FIXMEs should not be left in the code") if git.modified_files.any? { |file| file.end_with?('.swift') && `grep -l "FIXME" #{file}`.length > 0 }

# Encourage writing up some changelog entries
if git.lines_of_code > 50 && !github.pr_body.include?("## Changelog")
  warn("Please add a changelog entry for your changes.")
end

# Check for changes in the project structure
if git.modified_files.include?("Clean Architecture.xcodeproj/project.pbxproj")
  warn("Project structure changes detected. Make sure these changes are intentional.")
end