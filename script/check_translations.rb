#!/usr/bin/env ruby
# Fails if any English key newly added in this PR is missing from a translated locale file.
#
# Usage:
#   ruby script/check_translations.rb <base_ref> <dir:prefix> [<dir:prefix> ...]
#   ruby script/check_translations.rb origin/master config/locales:server config/locales:client
#
# For each <dir:prefix>, compares <dir>/<prefix>.en.yml against <base_ref> and then
# verifies every newly-added leaf path is present in <dir>/<prefix>.<locale>.yml for
# every other locale file that already exists.

require 'yaml'

def list_paths(hash, prefixes = [])
  paths = []
  hash.each do |key, value|
    if value.is_a?(Hash)
      paths.concat list_paths(value, prefixes + [key])
    else
      paths << (prefixes + [key]).join('.')
    end
  end
  paths
end

def parse_locale(content, locale)
  return {} if content.nil? || content.empty?
  data = YAML.safe_load(content, aliases: true) || {}
  data[locale] || {}
end

base_ref = ARGV[0] or abort "usage: ruby script/check_translations.rb <base_ref> <dir:prefix> [<dir:prefix> ...]"
sources = ARGV[1..].map { |arg| arg.split(':', 2) }
abort "at least one <dir:prefix> source is required" if sources.empty?

supported = YAML.load_file(File.expand_path('../config/locales.yml', __dir__))['supported']

missing = []

sources.each do |dir, prefix|
  en_file = "#{dir}/#{prefix}.en.yml"
  unless File.exist?(en_file)
    warn "skipping #{en_file}: does not exist"
    next
  end

  current_paths = list_paths(parse_locale(File.read(en_file), 'en'))
  base_content  = `git show #{base_ref}:#{en_file} 2>/dev/null`
  base_paths    = list_paths(parse_locale(base_content, 'en'))

  new_paths = current_paths - base_paths
  next if new_paths.empty?

  puts "#{en_file}: #{new_paths.size} newly-added English key(s)"

  supported.each do |locale|
    next if locale == 'en'
    file = "#{dir}/#{prefix}.#{locale}.yml"
    next unless File.exist?(file)

    existing = list_paths(parse_locale(File.read(file), locale))
    new_paths.each do |path|
      missing << "#{file}: missing '#{path}'" unless existing.include?(path)
    end
  end
end

if missing.any?
  puts
  puts "Missing translations for newly-added English keys:"
  missing.each { |m| puts "  #{m}" }
  puts
  puts "Run `bin/rake loomio:translate_strings` and commit the updated locale files."
  exit 1
else
  puts "All new English keys are present in every translated locale."
end
