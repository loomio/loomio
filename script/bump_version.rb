#!/usr/bin/env ruby
require 'securerandom'

usage = <<-END
  Arguments:
    <version_type>: The part of the version we are bumping.
                    NB that test will create a unique hash for a patch value.
                    Valid values are major | minor | patch | test
    <action>:       Action to perform after making version changes.
                    Valid values are commit | no-commit
                    Default is no-commit

  Example:
    Bumping the version: (assuming the current version is 0.10.1)
    (All examples assume the current version is 0.10.1)
    ruby script/bump_version patch # => 0.10.2
    ruby script/bump_version minor # => 0.11.0
    ruby script/bump_version major # => 1.0.0
    ruby script/bump_version test  # => 0.10.sdfbs8897sd8d7s

    Commit changes to git repo:
    ruby script/bump_version patch commit
 END

if ARGV.length == 0 || ARGV.include?('--help')
 puts usage
 exit 1
end

version_type = ARGV[0] || 'patch'
action = ARGV[1] || 'no-commit'

if !%w(major minor patch test).include? version_type
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

next_version = if version_type == 'test'
  SecureRandom.hex(8)
else
  Loomio::Version.send(version_type.downcase).to_i + 1
end

case version_type
when 'major'
  write_version 'major', next_version
  write_version 'minor', 0
  write_version 'patch', 0
when 'minor'
  write_version 'minor', next_version
  write_version 'patch', 0
when 'patch', 'test'
  write_version 'patch', next_version
end

if action == 'commit'
  puts "Creating version bump commit..."
  `git add lib/version.rb`
  `git add lib/version`
  `git commit -m "Bump version to #{Loomio::Version.current}"`
end

puts "New version: #{Loomio::Version.current}"
