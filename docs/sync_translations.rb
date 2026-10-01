#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "translate"

module Docs
  # Inspect every published page because a correction can arrive from an edit on
  # GitHub. Only pages needing translation or correction context reach the
  # translator, or every page when retranslating. Pages are independent, so
  # up to `jobs` of them are translated at once across all languages.
  class TranslationSync
    ROOT = Pathname(__dir__).freeze
    JOBS = 8

    def initialize(root: ROOT, locales: Localization.locales.select(&:published), translator: nil, retranslate: false,
      jobs: Integer(ENV.fetch("DOCS_TRANSLATION_JOBS", JOBS)))
      @root = root
      @locales = locales
      @retranslate = retranslate
      @jobs = jobs
      @translator = translator || ->(locale) { PageTranslator.new(locale, root: @root, retranslate: @retranslate) }
    end

    def paths
      @paths ||= @root.join("SUMMARY.md").read.scan(/\[([^\]]+)\]\(([^)]+\.md)\)/)
        .to_h { |title, path| [path, title] }.select { |path, _| Localization.translated?(path) }
    end

    def source_paths
      ["SUMMARY.md", "locales.yml", *paths.keys.map { |path| "en/#{path}" },
        *@locales.flat_map { |locale| paths.keys.map { |path| "#{locale.code}/#{path}" } }]
    end

    def update
      before = source_paths.to_h { |path| [path, contents(path)] }
      failures = translate(@locales.flat_map { |locale| pending_paths(locale).map { |path| [locale, path] } })
      raise "Manual translation failed:\n- #{failures.join("\n- ")}" if failures.any?
      validate!
      before.keys.select { |path| before.fetch(path) != contents(path) }.map { |path| "docs/#{path}" }
    end

    def pending_paths(locale)
      return paths.keys if @retranslate

      paths.filter_map do |path, title|
          english = Localization.parse(Localization.annotate(@root.join("en", path).read))
          file = @root.join(locale.code, path)
          target = file.file? ? Localization.parse(file.read) : Localization::Document.new(metadata: {}, body: "", sections: [])
          missing = english.sections.any? { |section| target.metadata.fetch("sections", {})[section.id] != section.text_hash }
          removed = target.by_id.keys - english.by_id.keys
          corrected = target.sections.any? { |section| target.corrected?(section.id) }
          title_changed = target.metadata["title_source"] != Localization.text_hash(title)
          path if missing || removed.any? || corrected || title_changed
      end
    end

    # Each worker takes the next page and translates it with its own
    # translator, so no translator state is shared between threads.
    def translate(jobs)
      queue = Queue.new
      jobs.each { |job| queue << job }
      queue.close
      failures = Queue.new
      Array.new([@jobs, jobs.size].min) do
        Thread.new do
          while (job = queue.pop)
            locale, path = job
            @translator.call(locale.code).translate([path]).each { |failure| failures << "#{locale.code}: #{failure}" }
          end
        end
      end.each(&:join)
      Array.new(failures.size) { failures.pop }
    end

    def validate!
      errors = @locales.flat_map do |locale|
        paths.flat_map do |path, title|
          file = @root.join(locale.code, path)
          target = file.file? ? Localization.parse(file.read) : Localization::Document.new(metadata: {}, body: "", sections: [])
          source = @root.join("en", path).read
          _, problems = Localization.assemble(locale.code, path, source)
          problems << "missing navigation title" if target.metadata["title"].to_s.empty?
          problems << "stale navigation title" if target.metadata["title_source"] != Localization.text_hash(title)
          problems.map { |problem| "#{locale.code}: #{path}: #{problem}" }
        end
      end
      raise "Manual translation validation failed:\n- #{errors.join("\n- ")}" if errors.any?
    end

    private

    def contents(path)
      file = @root.join(path)
      file.file? ? file.read : nil
    end
  end
end

if $PROGRAM_NAME == __FILE__
  begin
    raise "Usage: bundle exec ruby docs/sync_translations.rb [--check | --retranslate]" unless ARGV.empty? || ARGV == %w[--check] || ARGV == %w[--retranslate]
    sync = Docs::TranslationSync.new(retranslate: ARGV == ["--retranslate"])
    ARGV == ["--check"] ? sync.validate! : sync.update
    puts "Published manual translations are current and structurally valid."
  rescue StandardError => error
    abort error.message
  end
end
