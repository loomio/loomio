# frozen_string_literal: true

require "date"
require "digest"
require "pathname"
require "yaml"

module Docs
  # Translated manual pages are stored as Markdown blocks keyed by a hash of
  # the English block they translate. English stays canonical: a page is
  # assembled by walking its current English blocks and looking up each hash.
  # When an English block changes its hash changes, so the translation is
  # missing until the block is retranslated. Nothing falls back to English.
  module Localization
    ROOT = Pathname(__dir__).join("translations").freeze
    LOCALES_FILE = Pathname(__dir__).join("locales.yml").freeze

    # Only these top-level sections are translated. Policy pages and the
    # changelog stay in English.
    TRANSLATED_ROOTS = %w[user_manual guides].freeze

    Block = Data.define(:text, :hash) do
      # Fenced code, and images or HTML comments with nothing to translate, are
      # copied unchanged. The seo-description comment is the page's summary, so
      # it is translated.
      def translatable?
        return false if text.start_with?("```")
        return false if text.match?(/\A!\[\]\([^)]*\)\z/)
        return text.match?(/\A<!--\s*seo-description:/) if text.start_with?("<!--")

        true
      end
    end

    # `code` is the URL directory; `hreflang` the HTML language tag; and
    # `app_locale` the config/locales name for interface labels.
    Locale = Data.define(:code, :name, :published, :style, :hreflang, :app_locale, :dir)

    def self.locales
      YAML.safe_load_file(LOCALES_FILE).map do |code, config|
        Locale.new(
          code: code,
          name: config.fetch("name"),
          published: config.fetch("published"),
          style: config.fetch("style"),
          hreflang: config.fetch("hreflang", code),
          app_locale: config.fetch("app_locale", code),
          dir: config.fetch("dir", "ltr")
        )
      end
    end

    def self.translated?(source_path)
      TRANSLATED_ROOTS.include?(source_path.split("/").first) && !source_path.start_with?("user_manual/changelog/")
    end

    # Split on blank lines, keeping fenced code blocks whole. Joining the blocks
    # with blank lines produces equivalent Markdown.
    def self.blocks(markdown)
      blocks = []
      current = []
      fenced = false

      markdown.each_line(chomp: true) do |line|
        fenced = !fenced if line.start_with?("```")
        if line.strip.empty? && !fenced
          blocks << current.join("\n") if current.any?
          current = []
        else
          current << line
        end
      end
      blocks << current.join("\n") if current.any?

      blocks.map { |text| Block.new(text: text, hash: block_hash(text)) }
    end

    def self.block_hash(text)
      Digest::SHA256.hexdigest(text)[0, 16]
    end

    def self.path(locale, source_path)
      ROOT.join(locale, source_path.sub(/\.md\z/, ".yml"))
    end

    def self.load(locale, source_path)
      file = path(locale, source_path)
      return {"navigation_title" => nil, "blocks" => {}} unless file.file?

      YAML.safe_load_file(file, permitted_classes: [Date])
    end

    ENGLISH = Locale.new(code: "en", name: "English", published: true, style: nil, hreflang: "en", app_locale: "en", dir: "ltr")

    def self.locale(code)
      return ENGLISH if code == "en"

      locales.find { |locale| locale.code == code } or raise "Unknown docs locale #{code}"
    end

    def self.site_strings(locale)
      YAML.safe_load_file(ROOT.join(locale, "_site.yml"))
    end

    # Returns the translated Markdown, or nil with the hashes of the English
    # blocks that have no translation yet.
    def self.assemble(locale, source_path, markdown)
      stored = load(locale, source_path).fetch("blocks")
      missing = []
      parts = blocks(markdown).map do |block|
        next block.text unless block.translatable?

        translation = stored.dig(block.hash, "translation")
        missing << block.hash unless translation
        translation
      end

      missing.empty? ? [parts.join("\n\n") + "\n", []] : [nil, missing]
    end
  end
end
