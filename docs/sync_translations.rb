#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "translate"

module Docs
  # Inspect every published page because a GitHub correction can arrive without
  # running a local hook. Only pages needing translation or correction context
  # reach the translator. A push must contain the resulting files in a commit.
  class TranslationSync
    ROOT = Pathname(__dir__).freeze

    def initialize(root: ROOT, locales: Localization.locales.select(&:published), translator: nil)
      @root = root
      @locales = locales
      @translator = translator || ->(locale) { PageTranslator.new(locale, root: @root) }
    end

    def paths
      @paths ||= @root.join("SUMMARY.md").read.scan(/\[([^\]]+)\]\(([^)]+\.md)\)/)
        .to_h { |title, path| [path, title] }.select { |path, _| Localization.translated?(path) }
    end

    def source_paths
      ["SUMMARY.md", "locales.yml", *paths.keys.map { |path| "en/#{path}" },
        *@locales.flat_map { |locale| paths.keys.map { |path| "#{locale.code}/#{path}" } }]
    end

    def uncommitted_paths
      tracked, status = Open3.capture2("git", "diff", "--name-only", "-z", "HEAD", "--", "docs", chdir: @root.parent.to_s)
      raise "Cannot inspect committed manual sources" unless status.success?
      untracked, status = Open3.capture2("git", "ls-files", "--others", "--exclude-standard", "-z", "--", "docs", chdir: @root.parent.to_s)
      raise "Cannot inspect new manual sources" unless status.success?
      relevant = source_paths.map { |path| "docs/#{path}" }
      (tracked.split("\0") + untracked.split("\0")).uniq & relevant
    end

    def update
      before = source_paths.to_h { |path| [path, contents(path)] }
      @locales.each do |locale|
        pending = paths.filter_map do |path, title|
          english = Localization.parse(Localization.annotate(@root.join("en", path).read))
          file = @root.join(locale.code, path)
          target = file.file? ? Localization.parse(file.read) : Localization::Document.new(metadata: {}, body: "", sections: [])
          missing = english.sections.any? { |section| target.metadata.fetch("sections", {})[section.id] != section.text_hash }
          removed = target.by_id.keys - english.by_id.keys
          corrected = target.sections.any? { |section| target.corrected?(section.id) }
          title_changed = target.metadata["title_source"] != Localization.text_hash(title)
          path if missing || removed.any? || corrected || title_changed
        end
        @translator.call(locale.code).run(pending) unless pending.empty?
      end
      validate!
      before.keys.select { |path| before.fetch(path) != contents(path) }.map { |path| "docs/#{path}" }
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
    raise "Usage: bundle exec ruby docs/sync_translations.rb [--check | --before-push]" unless ARGV.empty? || [%w[--check], %w[--before-push]].include?(ARGV)
    sync = Docs::TranslationSync.new
    if ARGV == ["--check"]
      sync.validate!
    else
      if ARGV == ["--before-push"] && (dirty = sync.uncommitted_paths).any?
        abort "Commit manual source edits before pushing:\n- #{dirty.join("\n- ")}"
      end
      changed = sync.update
      if ARGV == ["--before-push"] && changed.any?
        abort "Manual translations were updated. Review and commit these files, then push again:\n- #{changed.join("\n- ")}"
      end
    end
    puts "Published manual translations are current and structurally valid."
  rescue StandardError => error
    abort error.message
  end
end
