# frozen_string_literal: true

require "json"
require "open3"
require_relative "localization"

module Docs
  # Correction notes are factual differences from a known generated version,
  # found by its stored fingerprint in Git. They travel with the section and
  # become translation context, without asking contributors to edit metadata.
  module Corrections
    MARKER = /<!-- translation-correction: (.*?) -->/m

    def self.notes(text)
      text.scan(MARKER).flatten.map { |json| JSON.parse(json) }
    end

    def self.record(before, after)
      return nil if before == after
      source = before.chars
      target = after.chars
      first = 0
      first += 1 while first < source.length && first < target.length && source[first] == target[first]
      last = 0
      last += 1 while last < source.length - first && last < target.length - first && source[-last - 1] == target[-last - 1]
      # Include nearby text so a small spelling correction has useful context.
      start = [first - 30, 0].max
      note = {
        "before" => source[start...[source.length - last + 30, source.length].min].join,
        "after" => target[start...[target.length - last + 30, target.length].min].join
      }
      json = JSON.generate(note).gsub("<", "\\u003c").gsub(">", "\\u003e").gsub("--", "\\u002d\\u002d")
      "<!-- translation-correction: #{json} -->"
    end

    def self.generated_text(root, locale, source_path, section, fingerprint)
      current_path = "docs/#{locale}/#{source_path}"
      legacy_path = "docs/translations/#{locale}/#{source_path.sub(/\.md\z/, '.yml')}"
      commits, status = Open3.capture2("git", "log", "--format=%H", "--", current_path, legacy_path, chdir: root.parent.to_s)
      raise "Cannot read translation history" unless status.success?
      commits.lines.map(&:strip).each do |revision|
        text = git_file(root, revision, current_path)
        if text
          candidate = Localization.parse(text).by_id[section.id]
          return candidate.text if candidate && candidate.text_hash == fingerprint
          next
        end
        # Recover the generated baseline before the YAML-to-Markdown migration.
        legacy = git_file(root, revision, legacy_path)
        next unless legacy
        english = git_file(root, revision, "docs/#{source_path}")
        next unless english
        stored = YAML.safe_load(legacy, permitted_classes: [Date]).fetch("blocks")
        original = Localization.parse(Localization.annotate(english)).by_id[section.id]
        next unless original
        blocks = original.text.split(/\n\s*\n/).map do |block|
          entry = stored.values.find { |value| value.fetch("english").strip == block.strip }
          entry ? entry.fetch("translation") : block
        end
        candidate = blocks.join("\n\n")
        return candidate if Localization.text_hash(candidate) == fingerprint
        candidate = Markdown.prose_unwrap(candidate)
        return candidate if Localization.text_hash(candidate) == fingerprint
      end
      nil
    end

    def self.git_file(root, revision, path)
      text, status = Open3.capture2("git", "show", "#{revision}:#{path}", chdir: root.parent.to_s, err: File::NULL)
      status.success? ? text : nil
    end
  end
end
