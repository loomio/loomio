#!/usr/bin/env ruby
# frozen_string_literal: true

# Translate user manual pages into one language, updating
# docs/translations/<locale>/.
#
# Usage:
#   bundle exec ruby docs/translate.rb fr
#   bundle exec ruby docs/translate.rb fr user_manual/discussions/templates/index.md
#
# For each page, English blocks without a stored translation are sent to the
# translator together with the whole English page for context and a glossary
# of the page's interface labels taken from Loomio's locale files. Each
# returned block is checked against its English source: links, images, inline
# code, heading level, list and table shape, and glossary labels must match.
# Blocks that fail are retried once with the problems listed, then reported
# and left untranslated. Translations of blocks the English page no longer has
# are removed. Large pages are sent in chunks of blocks, and each chunk is saved
# as it completes. A page whose request fails is reported and the run
# continues; rerunning resumes where it stopped.
#
# The translator is chosen with DOCS_TRANSLATOR (default: codex).

require "date"
require "fileutils"
require "json"
require "open3"
require "tempfile"
require "yaml"
require_relative "localization"

module Docs
  class PageTranslator
    SOURCE_ROOT = Pathname(__dir__)
    CHUNK_BLOCKS = 40
    LOCALE_ROOT = SOURCE_ROOT.join("../config/locales")

    # Each translator takes a prompt and returns the model's reply.
    TRANSLATORS = {
      "codex" => lambda do |prompt|
        Tempfile.create(["translation", ".json"]) do |output|
          command = [
            "codex", "exec",
            "-m", ENV.fetch("DOCS_TRANSLATOR_MODEL", "gpt-6-sol"),
            "-c", %(model_reasoning_effort="#{ENV.fetch("DOCS_TRANSLATOR_EFFORT", "low")}"),
            "-s", "read-only", "--ephemeral", "--skip-git-repo-check",
            "-C", SOURCE_ROOT.parent.to_s,
            "-o", output.path, "-"
          ]
          log, status = Open3.capture2e(*command, stdin_data: prompt)
          raise "codex exec failed:\n#{log.lines.last(20).join}" unless status.success?

          File.read(output.path)
        end
      end
    }.freeze

    def initialize(locale)
      @locale = Localization.locales.to_h { |item| [item.code, item] }.fetch(locale) { abort "Unknown locale #{locale}; see docs/locales.yml" }
      @translator_name = ENV.fetch("DOCS_TRANSLATOR", "codex")
      @translator = TRANSLATORS.fetch(@translator_name) { abort "Unknown translator #{@translator_name}" }
    end

    def run(source_paths)
      source_paths = all_source_paths if source_paths.empty?
      failures = source_paths.flat_map do |source_path|
        translate_page(source_path)
      rescue StandardError => error
        warn "#{@locale.code}: #{source_path}: #{error.message}"
        ["#{source_path}: #{error.message.lines.first.strip}"]
      end
      return if failures.empty?

      warn "\nUntranslated blocks:\n- #{failures.join("\n- ")}"
      exit 1
    end

    private

    def all_source_paths
      SOURCE_ROOT.join("SUMMARY.md").read.scan(/\]\(([^)]+\.md)\)/).flatten.select { |path| Localization.translated?(path) }
    end

    def translate_page(source_path)
      english = SOURCE_ROOT.join(source_path).read
      blocks = Localization.blocks(english).select(&:translatable?)
      stored = Localization.load(@locale.code, source_path)
      stored_blocks = stored.fetch("blocks")
      navigation_title = stored["navigation_title"]
      english_title = summary_titles.fetch(source_path)

      glossary = glossary_for(english)
      # A machine translation that no longer contains the app's current label
      # is retranslated, so the manual follows changes to interface wording.
      # Reviewed and flagged blocks are left for people to update.
      pending = blocks.uniq(&:hash).select do |block|
        stored = stored_blocks[block.hash]
        stored.nil? || (stored["status"] == "machine" && block_errors(block.text, stored["translation"], glossary).last.any?)
      end
      pending.each { |block| stored_blocks.delete(block.hash) if stored_blocks.dig(block.hash, "status") == "machine" }
      failures = []

      if pending.empty? && !navigation_title.to_s.empty?
        puts "#{@locale.code}: #{source_path}: up to date"
        write(source_path, navigation_title, blocks, stored_blocks)
        return failures
      end

      puts "#{@locale.code}: #{source_path}: translating #{pending.length} blocks"

      # Each chunk is saved as soon as it is checked, so a failure part way
      # through a long page keeps the work already done.
      (pending.any? ? pending.each_slice(CHUNK_BLOCKS).to_a : [[]]).each do |chunk|
        reply = request(english, english_title, chunk, glossary, {})
        navigation_title = reply["navigation_title"] if navigation_title.to_s.empty?
        results, problems = check(chunk, reply, glossary)

        if problems.any?
          retry_blocks = chunk.select { |block| problems.key?(block.hash) }
          retried, problems = check(retry_blocks, request(english, english_title, retry_blocks, glossary, problems), glossary, final: true)
          results.merge!(retried)
        end

        results.each do |hash, result|
          stored_blocks[hash] = result.merge("provider" => provider_name, "translated_on" => Date.today.iso8601)
        end
        failures += problems.map { |hash, errors| "#{source_path} #{hash}: #{errors.join("; ")}" }
        write(source_path, navigation_title, blocks, stored_blocks)
      end

      failures
    end

    def provider_name
      @translator_name == "codex" ? "codex/#{ENV.fetch("DOCS_TRANSLATOR_MODEL", "gpt-6-sol")}" : @translator_name
    end

    # Stores blocks in English page order with the English text beside each
    # translation, so reviewers can read the file on its own.
    def write(source_path, navigation_title, blocks, stored_blocks)
      ordered = blocks.uniq(&:hash).filter_map do |block|
        next unless stored_blocks.key?(block.hash)

        [block.hash, {"english" => block.text}.merge(stored_blocks[block.hash].except("english"))]
      end
      path = Localization.path(@locale.code, source_path)
      FileUtils.mkdir_p(path.dirname)
      path.write({"navigation_title" => navigation_title, "blocks" => ordered.to_h}.to_yaml(line_width: -1))
    end

    def request(english, english_title, blocks, glossary, problems)
      prompt = <<~PROMPT
        Translate blocks of a Loomio user manual page from English into #{@locale.name} (`#{@locale.code}`).

        Reply with only a JSON object, no code fences:
        {"navigation_title": "<translation of the page's navigation title>", "blocks": {"<id>": "<translated Markdown>"}}

        Rules:
        - #{@locale.style}
        - Keep Markdown structure exactly: heading levels, list items, table rows and columns, blockquote and alert markers like [!NOTE], line breaks.
        - Keep link targets, image paths, #anchors, URLs, HTML tags and `inline code` exactly as in the English. Translate link text and image alt text.
        - Bold text names interface controls. Where the glossary gives a label, use exactly that label inside the bold markers. Where it lists options, choose the one that fits. Otherwise translate the label naturally.
        - Keep the meaning, not the English sentence structure. Use plain, calm, factual language with short sentences. No exclamation marks.
        - Use Loomio's established terminology for #{@locale.name} from config/locales/client.#{@locale.app_locale}.yml, for example discussion, thread, poll, proposal, outcome, template, group, member and admin. Read config/locales/translation_corrections.md for known mistakes to avoid.
        - Translate the seo-description text inside an HTML comment, keeping the comment markers.
        - Do not modify any files.

        Navigation title: #{english_title}

        Glossary (English label → #{@locale.name} interface label):
        #{JSON.pretty_generate(glossary)}

        Whole English page, for context:
        <<<PAGE
        #{english}
        PAGE

        Blocks to translate:
        #{JSON.pretty_generate(blocks.to_h { |block| [block.hash, block.text] })}
      PROMPT
      if problems.any?
        prompt += "\nA previous translation of these blocks failed these checks. Fix them:\n#{JSON.pretty_generate(problems)}\n"
      end

      attempts = 0
      begin
        attempts += 1
        reply = @translator.call(prompt).strip.sub(/\A```(?:json)?\s*/, "").sub(/\s*```\z/, "")
        JSON.parse(reply)
      rescue StandardError => error
        retry if attempts < 2
        raise "translator failed after #{attempts} attempts: #{error.message}"
      end
    end

    # Returns accepted translations and the problems of the rest. Bold labels
    # sometimes need inflecting to fit the sentence, which an exact glossary
    # match cannot allow. On the final attempt, a block whose only problem is a
    # glossary label is accepted and marked for review instead of being lost.
    def check(blocks, reply, glossary, final: false)
      translations = reply.fetch("blocks", {})
      results = {}
      problems = {}

      blocks.each do |block|
        translation = translations[block.hash]
        unless translation.is_a?(String) && !translation.strip.empty?
          problems[block.hash] = ["missing translation"]
          next
        end

        structural, labels = block_errors(block.text, translation, glossary)
        if structural.empty? && labels.empty?
          results[block.hash] = {"translation" => translation.strip, "status" => "machine"}
        elsif structural.empty? && final
          results[block.hash] = {"translation" => translation.strip, "status" => "needs_review", "note" => labels.join("; ")}
        else
          problems[block.hash] = structural + labels
        end
      end

      [results, problems]
    end

    def block_errors(english, translation, glossary)
      structural = []
      {
        "link and image targets" => ->(text) { text.scan(/\]\(([^)]*)\)/).flatten },
        "inline code" => ->(text) { text.scan(/`[^`]+`/) },
        "HTML tags" => ->(text) { text.scan(/<\/?[a-z][^>]*>/i) },
        "alert markers" => ->(text) { text.scan(/\[![A-Z]+\]/) }
      }.each do |name, extract|
        missing = multiset_difference(extract.call(english), extract.call(translation))
        extra = multiset_difference(extract.call(translation), extract.call(english))
        next if missing.empty? && extra.empty?

        details = []
        details << "missing #{missing.join(", ")}" if missing.any?
        details << "unexpected #{extra.join(", ")}" if extra.any?
        structural << "#{name} must match the English exactly: #{details.join("; ")}"
      end
      {
        "heading level" => ->(text) { text[/\A#+ /] },
        "number of list items" => ->(text) { text.scan(/^\s*(?:[-*+]|\d+\.) /).length },
        "number of table rows" => ->(text) { text.scan(/^\|/).length },
        "comment markers" => ->(text) { [text.include?("<!--"), text.include?("-->")] }
      }.each do |name, extract|
        structural << "#{name} differs from the English" unless extract.call(english) == extract.call(translation)
      end

      labels = english.scan(/\*\*([^*]+)\*\*/).flatten.filter_map do |label|
        expected = glossary[label]
        next unless expected.is_a?(String)

        %(use the interface label "**#{expected}**" for "**#{label}**") unless translation.include?("**#{expected}**")
      end
      [structural, labels]
    end

    def multiset_difference(items, others)
      remaining = others.tally
      items.reject { |item| remaining[item].to_i.positive? && (remaining[item] -= 1) }
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
      @summary_titles ||= SOURCE_ROOT.join("SUMMARY.md").read.scan(/\[([^\]]+)\]\(([^)]+\.md)\)/).to_h { |title, path| [path, title] }
    end
  end
end

if $PROGRAM_NAME == __FILE__
  locale, *source_paths = ARGV
  abort "Usage: bundle exec ruby docs/translate.rb LOCALE [PAGE.md...]" unless locale
  Docs::PageTranslator.new(locale).run(source_paths)
end
