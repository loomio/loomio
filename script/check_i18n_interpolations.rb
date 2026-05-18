#!/usr/bin/env ruby
# Fails if any non-English locale file uses an interpolation variable
# (e.g. %{when}) that isn't present in the English source for the same key.
# Catches translator-mangled placeholders — the bug that caused LOOMIO-COM-246
# (German "Die Abstimmung endet %{wenn}." for "Voting closes %{when}.").

require "yaml"

INTERPOLATION_RE = /%\{([^}]+)\}/

def collect(hash, path = [], out = {})
  hash.each do |k, v|
    case v
    when Hash then collect(v, path + [k.to_s], out)
    when String
      vars = v.scan(INTERPOLATION_RE).flatten
      out[path + [k.to_s]] = vars unless vars.empty?
    end
  end
  out
end

def locale_tree(path)
  YAML.load_file(path).values.first
end

errors = []
Dir["config/locales/*.en.yml"].sort.each do |en_path|
  en_vars = collect(locale_tree(en_path))
  stem = File.basename(en_path).sub(".en.yml", "")
  Dir["config/locales/#{stem}.*.yml"].sort.each do |other|
    next if other == en_path
    collect(locale_tree(other)).each do |key, vars|
      expected = en_vars[key] or next
      extra = vars - expected
      next if extra.empty?
      errors << "#{other} #{key.join('.')}: has %{#{extra.join('}, %{')}}, expected %{#{expected.join('}, %{')}}"
    end
  end
end

if errors.any?
  warn "i18n interpolation check failed:"
  errors.each { |e| warn "  #{e}" }
  exit 1
end
