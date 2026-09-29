#!/usr/bin/env ruby
# frozen_string_literal: true

# Update missing or stale sections in docs/<locale>/<page>.md. Unchanged
# sections stay untouched. Customer corrections are detected from generated
# text hashes and supplied as context. Their correction notes travel with the section.
# Usage: bundle exec ruby docs/translate.rb LOCALE [PAGE.md...]

require "date"
require "fileutils"
require "json"
require "open3"
require "tempfile"
require_relative "corrections"

module Docs
  class PageTranslator
    ROOT = Pathname(__dir__)
    LOCALE_ROOT = ROOT.join("../config/locales")
    CHUNK_SECTIONS = 12

    # Each translator takes a prompt and returns the model's reply.
    TRANSLATORS = {
      "codex" => lambda do |prompt|
        Tempfile.create(["translation", ".json"]) do |output|
          command = [
            "codex", "exec",
            "-m", ENV.fetch("DOCS_TRANSLATOR_MODEL", "gpt-6.1-sol"),
            "-c", %(model_reasoning_effort="#{ENV.fetch("DOCS_TRANSLATOR_EFFORT", "low")}"),
            "-s", "read-only", "--ephemeral", "--skip-git-repo-check",
            "-C", ROOT.parent.to_s,
            "-o", output.path, "-"
          ]
          log, status = Open3.capture2e(*command, stdin_data: prompt)
          raise "codex exec failed:\n#{log.lines.last(20).join}" unless status.success?

          File.read(output.path)
        end
      end
    }.freeze

    def initialize(locale, translator: nil, root: ROOT)
      @root = root
      @previous_sources = {}
      @locale = Localization.locale(locale)
      raise "English is the translation source" if locale == "en"
      @translator_name = ENV.fetch("DOCS_TRANSLATOR", "codex")
      @translator = translator || TRANSLATORS.fetch(@translator_name)
    end

    def run(source_paths)
      source_paths = summary_titles.keys.select { |path| Localization.translated?(path) } if source_paths.empty?
      failures = source_paths.flat_map do |source_path|
        translate_page(source_path)
      rescue StandardError => error
        warn "#{@locale.code}: #{source_path}: #{error.message}"
        ["#{source_path}: #{error.message.lines.first.strip}"]
      end
      return if failures.empty?

      warn "\nTranslation updates requiring attention:\n- #{failures.join("\n- ")}"
      exit 1
    end

    private

    # Save validated updates by stable section ID. Preserve unchanged customer
    # text; use corrected sections and factual correction notes as context when
    # their English changes. A failed translation never replaces the old text.
    def translate_page(source_path)
      raise "Page is not translated: #{source_path}" unless Localization.translated?(source_path) && summary_titles.key?(source_path)
      source_file = @root.join("en", source_path)
      original_english = source_file.read
      english = Localization.annotate(original_english)
      source_file.write(english) unless english == original_english
      source = Localization.parse(english)
      target = Localization.load(@locale.code, source_path)
      @navigation_previous = target.metadata["title"]
      original = target.by_id
      stored = original.dup
      original.each_value do |section|
        next unless target.corrected?(section.id)
        comments = correction_comments(source_path, section, target)
        text = [*comments, section.text.gsub(Corrections::MARKER, "").strip].join("\n\n")
        stored[section.id] = section.with(text: text)
      end
      metadata = Marshal.load(Marshal.dump(target.metadata))
      metadata["sections"] ||= {}
      metadata["generated"] ||= {}
      notes = metadata.fetch("needs_review", {}).dup
      pending = source.sections.select { |section| !stored.key?(section.id) || metadata["sections"][section.id] != section.text_hash }
      removed = original.keys - source.by_id.keys
      failures = []
      glossary = glossary_for(english)
      title = summary_titles.fetch(source_path)
      title_changed = metadata["title_source"] != Localization.text_hash(title)
      if pending.empty? && removed.empty? && !title_changed
        if stored != original
          Localization.path(@locale.code, source_path).write(Localization.dump(metadata, source.sections.map { |section| stored.fetch(section.id) }))
          puts "#{@locale.code}: #{source_path}: recorded customer corrections"
        else
          puts "#{@locale.code}: #{source_path}: up to date"
        end
        return []
      end
      revision = source_revision

      removed.each do |id|
        stored.delete(id)
        metadata["sections"].delete(id)
        metadata["generated"].delete(id)
        notes.delete(id)
      end
      if pending.empty? && !title_changed
        notes.empty? ? metadata.delete("needs_review") : metadata["needs_review"] = notes
        Localization.path(@locale.code, source_path).write(Localization.dump(metadata, source.sections.map { |section| stored.fetch(section.id) }))
        puts "#{@locale.code}: #{source_path}: removed deleted sections"
        return []
      end
      chunks = pending.each_slice(CHUNK_SECTIONS).to_a
      chunks = [[]] if chunks.empty?
      chunks.each do |chunk|
        corrections = chunk.to_h do |section|
          old = stored[section.id]
          comments = old ? old.text.scan(Corrections::MARKER).map { |json| "<!-- translation-correction: #{json.first} -->" } : []
          [section.id, comments]
        end
        previous = chunk.to_h do |section|
          [section.id, {"english" => previous_english(target, source_path, section.id), "translation" => original[section.id]&.text,
            "corrections" => corrections.fetch(section.id).flat_map { |comment| Corrections.notes(comment) }}]
        end
        reply = request(english, title, chunk, glossary, previous, {})
        results, problems, warnings = check(chunk, reply, glossary)
        if problems.any? || warnings.any?
          retry_ids = (problems.keys + warnings.keys).uniq
          retry_sections = chunk.select { |section| retry_ids.include?(section.id) }
          retried, problems, retry_warnings = check(retry_sections, request(english, title, retry_sections, glossary, previous, problems.merge(warnings)), glossary)
          results.merge!(retried)
          warnings = retry_warnings
        end
        if title_changed && reply["navigation_title"].is_a?(String) && !reply["navigation_title"].strip.empty?
          metadata["title"] = reply["navigation_title"].strip
          metadata["title_source"] = Localization.text_hash(title)
          metadata["title_generated"] = Localization.text_hash(metadata["title"])
          title_changed = false
        end
        results.each do |id, text|
          # Comments are managed here rather than rewritten by the model.
          text = text.gsub(Corrections::MARKER, "").strip
          text = [*corrections.fetch(id), text].join("\n\n")
          stored[id] = Localization::Section.new(id: id, text: text)
          metadata["sections"][id] = source.by_id.fetch(id).text_hash
          metadata["generated"][id] = stored.fetch(id).text_hash
          notes.delete(id)
        end
        notes.merge!(warnings.transform_values { |values| values.join("; ") })
        failures.concat(problems.map { |id, errors| "#{source_path} #{id}: #{errors.join("; ")}" })
        # Page provenance changes only when all sections are current. A partial
        # run retains the old Git revision for outstanding section comparisons.
        if source.sections.all? { |section| metadata["sections"][section.id] == section.text_hash }
          current_path = "docs/en/#{source_path}"
          if Corrections.git_file(@root, revision, current_path)
            metadata["source_revision"] = revision
            metadata["source_file"] = current_path
          end
        end
        metadata["translated"] = {"provider" => provider_name, "on" => Date.today.iso8601}
        notes.empty? ? metadata.delete("needs_review") : metadata["needs_review"] = notes
        sections = source.sections.filter_map { |section| stored[section.id] }
        destination = Localization.path(@locale.code, source_path)
        FileUtils.mkdir_p(destination.dirname)
        destination.write(Localization.dump(metadata, sections))
      end
      failures << "#{source_path}: missing navigation title" if title_changed
      failures
    end

    def source_revision
      revision, status = Open3.capture2("git", "rev-parse", "HEAD", chdir: @root.parent.to_s)
      raise "Cannot read English source revision" unless status.success?
      revision.strip
    end

    def correction_comments(source_path, section, target)
      comments = section.text.scan(Corrections::MARKER).map { |json| "<!-- translation-correction: #{json.first} -->" }
      baseline = generated_text(source_path, section, target.metadata.fetch("generated", {})[section.id])
      if baseline
        note = Corrections.record(baseline.gsub(Corrections::MARKER, "").strip, section.text.gsub(Corrections::MARKER, "").strip)
        comments << note if note
      else
        # A local correction may precede the first commit of its generated
        # version. Preserve the preferred wording even without a Git baseline.
        note = JSON.generate({"preferred" => section.text.gsub(Corrections::MARKER, "").strip})
          .gsub("<", "\\u003c").gsub(">", "\\u003e").gsub("--", "\\u002d\\u002d")
        comments << "<!-- translation-correction: #{note} -->"
      end
      comments.uniq
    end

    def generated_text(source_path, section, fingerprint)
      Corrections.generated_text(@root, @locale.code, source_path, section, fingerprint)
    end

    def previous_english(target, source_path, id)
      revision = target.metadata["source_revision"]
      return nil unless revision
      unless @previous_sources.key?(source_path)
        file = target.metadata.fetch("source_file", "docs/en/#{source_path}")
        text, status = Open3.capture2("git", "show", "#{revision}:#{file}", chdir: @root.parent.to_s, err: File::NULL)
        @previous_sources[source_path] = status.success? ? Localization.parse(Localization.annotate(text)).by_id : {}
      end
      section = @previous_sources.fetch(source_path)[id]
      # A source edit may be translated before it is committed. Only describe
      # a Git snapshot as the previous English when its fingerprint matches.
      section.text if section && section.text_hash == target.metadata.fetch("sections").fetch(id)
    end

    def provider_name
      @translator_name == "codex" ? "codex/#{ENV.fetch("DOCS_TRANSLATOR_MODEL", "gpt-6.1-sol")}" : @translator_name
    end

    def locale_corrections
      @root.join(@locale.code).glob("**/*.md").flat_map do |path|
        document = Localization.parse(path.read)
        document.sections.filter_map do |section|
          notes = Corrections.notes(section.text)
          {"page" => path.relative_path_from(@root.join(@locale.code)).to_s, "section" => section.id, "notes" => notes} if notes.any?
        end
      end
    end

    def request(english, title, sections, glossary, previous, problems)
      # The model receives parsed HTML for each named section. Code, URLs and
      # markup are immutable contracts checked again after Markdown conversion.
      renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML, MARKDOWN_OPTIONS)
      prompt = <<~PROMPT
        Translate Loomio documentation into #{@locale.name} (#{@locale.code}).
        Reply only with JSON: {"navigation_title": "translated title", "sections": {"section-id": "translated Markdown"}}.
        #{@locale.style}
        Use plain factual language and Loomio's terminology from config/locales/client.#{@locale.app_locale}.yml.
        Read config/locales/translation_corrections.md for known terminology mistakes.
        Preserve heading levels, lists, tables, alerts, HTML tags, link and image targets, and all code exactly.
        Translate link text, image alt text, and seo-description comments. Return Markdown, with one line per prose paragraph.
        Bold interface labels should follow this glossary; grammatical inflections are allowed when necessary:
        #{JSON.pretty_generate(glossary)}
        Preserve customer corrections and apply the recorded correction notes wherever English still has the same meaning.
        Later correction notes supersede earlier wording when they conflict.
        Retain terminology, spelling and register improvements. Do not return translation-section or translation-correction comments.
        Do not modify files.
        Navigation title: #{title}
        Previous translated navigation title: #{@navigation_previous}
        Whole English page as HTML, for context:
        #{renderer.render(english)}
        Sections to translate (HTML, with the original seo-description comment):
        #{JSON.pretty_generate(sections.to_h { |section| [section.id, renderer.render(section.text)] })}
        Previous English and translated sections, where available:
        #{JSON.pretty_generate(previous)}
        Corrections from other pages in this language, as examples of preferred wording where relevant.
        Current section corrections take precedence over older examples:
        #{JSON.pretty_generate(locale_corrections)}
        Validation problems to resolve:
        #{JSON.pretty_generate(problems)}
      PROMPT
      attempts = 0
      begin
        attempts += 1
        response = @translator.call(prompt).strip.sub(/\A```(?:json)?\s*/, "").sub(/\s*```\z/, "")
        reply = JSON.parse(response)
        raise "Translator response must be an object" unless reply.is_a?(Hash)
        reply
      rescue StandardError
        retry if attempts < 2
        raise
      end
    end

    def check(sections, reply, glossary)
      translations = reply.fetch("sections", {})
      results, problems, warnings = {}, {}, {}
      sections.each do |section|
        text = translations[section.id]
        unless text.is_a?(String) && !text.strip.empty?
          problems[section.id] = ["missing translation"]
          next
        end
        errors = Markdown.errors(section.text, text)
        Localization.lines_outside_fences(text) do |line, _index|
          errors << "unexpected translation-section comment" if Localization::MARKER.match?(line)
        end
        unless errors.empty?
          problems[section.id] = errors
          next
        end
        results[section.id] = text.strip
        labels = label_errors(section.text, text, glossary)
        warnings[section.id] = labels if labels.any?
      end
      [results, problems, warnings]
    end

    def label_errors(english, translation, glossary)
      english.scan(/\*\*([^*]+)\*\*/).flatten.filter_map do |label|
        expected = glossary[label]
        next unless expected.is_a?(String)
        %(check the interface label "**#{expected}**" for "**#{label}**") unless translation.include?("**#{expected}**")
      end
    end

    # Maps each bold label on the page to the locale's translation of the
    # interface string with that exact English text. Labels with several
    # different translations list them all; unknown labels are omitted.
    def glossary_for(markdown)
      labels = markdown.scan(/\*\*([^*]+)\*\*/).flatten.uniq
      labels.each_with_object({}) do |label, glossary|
        values = english_strings.fetch(label, []).filter_map { |key| locale_strings[key] }.uniq
        next if values.empty?

        glossary[label] = values.length == 1 ? values.first : values
      end
    end

    def english_strings
      @english_strings ||= flatten_locale("en").each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |(key, value), index|
        index[value] << key if value.is_a?(String)
      end
    end

    def locale_strings
      @locale_strings ||= flatten_locale(@locale.app_locale)
    end

    def flatten_locale(code)
      %w[client server].each_with_object({}) do |kind, strings|
        data = YAML.safe_load_file(LOCALE_ROOT.join("#{kind}.#{code}.yml"), aliases: true).fetch(code)
        flatten(data, kind, strings)
      end
    end

    def flatten(value, prefix, output)
      value.each do |key, child|
        path = "#{prefix}.#{key}"
        child.is_a?(Hash) ? flatten(child, path, output) : output[path] = child
      end
      output
    end

    def summary_titles
      @summary_titles ||= @root.join("SUMMARY.md").read.scan(/\[([^\]]+)\]\(([^)]+\.md)\)/).to_h { |title, path| [path, title] }
    end
  end
end

if $PROGRAM_NAME == __FILE__
  locale, *source_paths = ARGV
  abort "Usage: bundle exec ruby docs/translate.rb LOCALE [PAGE.md...]" unless locale
  Docs::PageTranslator.new(locale).run(source_paths)
end
