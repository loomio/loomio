#!/usr/bin/env ruby

usage = <<-END
  Arguments:
    <version_type>: The part of the version we are bumping.
                    Valid values are major | minor | patch
    <action>:       Action to perform after making version changes.
                    Valid values are commit | no-commit
                    Default is no-commit

  Example:
    Bumping the version: (assuming the current version is 0.10.1)
    (All examples assume the current version is 0.10.1)
    ruby script/bump_version patch # => 0.10.2
    ruby script/bump_version minor # => 0.11.0
    ruby script/bump_version major # => 1.0.0

    Commit changes to git repo:
    ruby script/bump_version patch commit
 END

if ARGV.length == 0 || ARGV.include?('--help')
 puts usage
 exit 1
end

version_type = ARGV[0] || 'patch'
action = ARGV[1] || 'no-commit'

if !%w(major minor patch).include? version_type
  puts "Invalid version_type; use the --help option for usage info."
  exit 0
end

if !%w(no-commit commit).include? action
  puts "Invalid action; use the --help option for usage info."
  exit 0
end

require_relative '../lib/version'

puts "Current version: #{Loomio::Version.current}"

def write_version(type, value)
  file_path = File.expand_path "../../lib/version/#{type.downcase}", __FILE__
  File.open(file_path, 'w+') { |file| file.write value }
end

write_version version_type, Loomio::Version.send(version_type.downcase).to_i + 1
write_version 'minor', 0 if %w(major).include? version_type
write_version 'patch', 0 if %w(major minor).include? version_type

if action == 'commit'
  puts "Creating version bump commit..."
  `git add lib/version.rb`
  `git add lib/version`
  `git commit -m "Bump version to #{Loomio::Version.current}"`
end

puts "New version: #{Loomio::Version.current}"
