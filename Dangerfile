# Dangerfile for Swift project
# Sometimes it's a README fix, or something like that - which isn't relevant for
# including in a project's CHANGELOG for example
declared_trivial = github.pr_title.include? "#trivial"

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Warn when there is a big PR
warn("Big PR, consider splitting into smaller PRs for easier code review") if git.lines_of_code > 500

# SwiftLint
swiftlint.config_file = '.vscode/.swiftlint.yml'
swiftlint.lint_files inline_mode: true
swiftlint.verbose = true

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

# Ensure tests are added/modified when production code changes
has_app_changes = !git.modified_files.grep(/Clean Architecture\/(?!Info.plist|SceneDelegate.swift|AppDelegate.swift).*\.swift/).empty?
has_test_changes = !git.modified_files.grep(/Tests\/.*\.swift/).empty?

if has_app_changes && !has_test_changes && !declared_trivial
  warn("Any changes to production code should be accompanied by unit tests.")
end

# Check for file length
git.modified_files.each do |file|
  next unless file.end_with?(".swift")
  
  lines = File.readlines(file).count
  if lines > 300
    warn("#{file} has #{lines} lines of code. Consider refactoring to improve maintainability.")
  end
end

# Check if there's a risk that the developer has accidentally left debugging code
git.modified_files.each do |file|
  next unless file.end_with?(".swift")
  
  File.readlines(file).each_with_index do |line, index|
    if line.include?("print(") && !declared_trivial
      warn("Debugging code found in #{file}:#{index+1}. Make sure this is intentional.")
    end
  end
end

# Check for missing documentation in public interfaces
modified_swift_files = git.modified_files.select { |file| file.end_with?(".swift") }
modified_swift_files.each do |file|
  next if file.include?("Tests/")
  
  File.readlines(file).each_with_index do |line, index|
    # Check for public/open declarations without preceding documentation
    if (line.match(/\s*(public|open)\s+(class|struct|enum|protocol|func|var|let)/) || 
        line.match(/\s*(class|struct|enum|protocol)\s+\w+/)) && 
        index > 0 && !File.readlines(file)[index-1].include?("///")
      warn("Consider adding documentation for public interface in #{file}:#{index+1}")
    end
  end
end

# Encourage using Swift best practices
message("This PR will be checked for Swift best practices.")

# Fail if certain dangerous code patterns are found
fail("Force unwrapping is used, consider using safe unwrapping") if git.modified_files.any? { |file| file.end_with?('.swift') && `grep -l "\\w\\!" #{file}`.length > 0 }