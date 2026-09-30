# frozen_string_literal: true

require "date"
require "digest"
require "pathname"
require "yaml"
require_relative "markdown"

module Docs
  # English and translated pages share paths under docs/<locale>/. Stable
  # section comments survive paragraph splits and heading renames. Source
  # hashes track freshness; generated hashes protect customer corrections
  # without requiring people to edit the frontmatter.
  module Localization
    ROOT = Pathname(__dir__).freeze
    LOCALES_FILE = ROOT.join("locales.yml").freeze
    TRANSLATED_ROOTS = %w[user_manual guides].freeze
    MARKER = /\A<!-- translation-section: ([a-z0-9][a-z0-9_-]*) -->\s*\z/
    Section = Data.define(:id, :text) do
      def text_hash
        Localization.text_hash(text)
      end
    end
    Document = Data.define(:metadata, :body, :sections) do
      def by_id
        sections.to_h { |section| [section.id, section] }
      end

      def corrected?(id)
        generated = metadata.fetch("generated", {})[id]
        generated.nil? || generated != by_id.fetch(id).text_hash
      end
    end
    Locale = Data.define(:code, :name, :published, :style, :hreflang, :app_locale, :dir)
    ENGLISH = Locale.new(code: "en", name: "English", published: true, style: nil, hreflang: "en", app_locale: "en", dir: "ltr")

    def self.locales
      YAML.safe_load_file(LOCALES_FILE).map do |code, config|
        Locale.new(code: code, name: config.fetch("name"), published: config.fetch("published"),
          style: config.fetch("style"), hreflang: config.fetch("hreflang", code),
          app_locale: config.fetch("app_locale", code), dir: config.fetch("dir", "ltr"))
      end
    end

    def self.locale(code)
      return ENGLISH if code == "en"

      locales.find { |locale| locale.code == code } or raise "Unknown docs locale #{code}"
    end

    def self.translated?(source_path)
      TRANSLATED_ROOTS.include?(source_path.split("/").first) && !source_path.start_with?("user_manual/changelog/")
    end

    def self.path(locale, source_path)
      ROOT.join(locale, source_path)
    end

    def self.load(locale, source_path)
      file = path(locale, source_path)
      file.file? ? parse(file.read) : Document.new(metadata: {}, body: "", sections: [])
    end

    def self.text_hash(text)
      Digest::SHA256.hexdigest(text.strip)[0, 16]
    end

    # Fence tracking keeps examples containing headings or section comments
    # literal. Closing fences must match the opener's character and length.
    def self.lines_outside_fences(markdown)
      fence = nil
      markdown.each_line.with_index do |line, index|
        if fence
          fence = nil if line.match?(/\A {0,3}#{Regexp.escape(fence[0])}{#{fence.length},}\s*\z/)
          next
        end
        if (opening = line.match(/\A {0,3}(`{3,}|~{3,})/))
          fence = opening[1]
          next
        end
        yield line, index
      end
    end

    def self.parse(markdown)
      metadata = {}
      body = markdown
      if markdown.start_with?("---\n")
        header = markdown.match(/\A---\n(.*?)\n---(?:\n|\z)/m) or raise "Unclosed translation frontmatter"
        metadata = YAML.safe_load(header[1], permitted_classes: [Date])
        raise "Translation frontmatter must be a mapping" unless metadata.is_a?(Hash)
        body = markdown[header[0].length..].lstrip
      end
      lines = body.lines
      markers = []
      lines_outside_fences(body) { |line, index| markers << [index, MARKER.match(line)[1]] if MARKER.match?(line) }
      if markers.any? && !lines[0...markers.first[0]].join.strip.empty?
        raise "Content precedes the first translation section"
      end
      ids = markers.map(&:last)
      raise "Duplicate translation section IDs" unless ids.uniq == ids
      sections = markers.each_with_index.map do |(start, id), index|
        finish = markers[index + 1]&.first || lines.length
        Section.new(id: id, text: lines[(start + 1)...finish].join.strip)
      end
      Document.new(metadata: metadata, body: body, sections: sections)
    end

    # Seed readable IDs once. Existing markers are never regenerated from
    # heading text: renaming a heading must not rename its translation unit.
    def self.annotate(markdown)
      return markdown if parse(markdown).sections.any?

      headings = []
      lines_outside_fences(markdown) do |line, index|
        heading = line.match(/\A {0,3}\#{1,6}\s+(.+?)\s*#*\s*\z/)
        headings << [index, heading[1]] if heading
      end
      boundaries = {0 => "introduction"}
      used = ["introduction"]
      headings.drop(1).each do |index, title|
        id = title.downcase.unicode_normalize(:nfkd).gsub(/\p{Mn}/, "").gsub(/[^a-z0-9]+/, "-").gsub(/\A-+|-+\z/, "")
        id = "section" if id.empty?
        base = id
        suffix = 2
        while used.include?(id)
          id = "#{base}-#{suffix}"
          suffix += 1
        end
        used << id
        boundaries[index] = id
      end
      markdown.lines.each_with_index.map do |line, index|
        boundaries.key?(index) ? "<!-- translation-section: #{boundaries.fetch(index)} -->\n\n#{line}" : line
      end.join
    end

    def self.dump(metadata, sections)
      header = metadata.to_yaml(line_width: -1).delete_prefix("---\n")
      body = sections.map { |section| "<!-- translation-section: #{section.id} -->\n\n#{section.text.strip}" }.join("\n\n")
      "---\n#{header}---\n\n#{body}\n"
    end

    def self.site_strings(locale)
      YAML.safe_load_file(ROOT.join(locale, "_site.yml"))
    end

    # Stale content remains editable, but cannot be silently published. A
    # customer correction is accepted without review-status bookkeeping.
    def self.assemble(locale, source_path, markdown)
      source = parse(markdown)
      target = load(locale, source_path)
      source_ids = source.sections.map(&:id)
      target_ids = target.sections.map(&:id)
      problems = source_ids - target_ids
      problems += (target_ids - source_ids).map { |id| "unexpected section #{id}" }
      problems << "section order" unless target_ids == source_ids || target_ids.empty?
      translated_sections = target.by_id
      source.sections.each do |section|
        translated = translated_sections[section.id]
        next unless translated
        if target.metadata.fetch("sections", {})[section.id] != section.text_hash
          problems << "stale section #{section.id}"
          next
        end
        problems.concat(Markdown.errors(section.text, translated.text).map { |error| "#{section.id}: #{error}" })
      end
      raise "#{source_path}: English page has no translation sections" if source.sections.empty?

      problems.empty? ? [target.body, []] : [nil, problems]
    end
  end
end
